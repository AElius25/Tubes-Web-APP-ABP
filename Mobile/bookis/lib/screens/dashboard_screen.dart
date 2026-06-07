import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/book_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/revenue_chart.dart';
import 'pos_screen.dart';
import 'inventory_screen.dart';
import 'transaction_history_screen.dart';
import '../widgets/book_form.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // Expose a method to switch tab from child widgets
  void switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load data dari Supabase saat app pertama dibuka
      await context.read<BookProvider>().loadBooks();
      await context.read<TransactionProvider>().loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardHome(onNavigate: switchTab),
          const POSScreen(),
          const InventoryScreen(),
          const TransactionHistoryScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Kasir',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Stok',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final void Function(int) onNavigate;
  const _DashboardHome({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final tx = context.watch<TransactionProvider>();
    final books = context.watch<BookProvider>();
    final fmt = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);
    final dateStr = DateFormat('EEEE, d MMMM yyyy', 'id').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_stories, size: 22),
            SizedBox(width: 8),
            Text('Kedai Buku'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(dateStr,
                  style: const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text('Selamat Datang!',
                style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 4),
              Text('Ringkasan penjualan hari ini',
                style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),

              // Stats Row
              Row(children: [
                Expanded(child: StatCard(
                  title: 'Pendapatan',
                  value: fmt.format(tx.todayRevenue),
                  icon: Icons.trending_up,
                  color: const Color(0xFF2E7D32),
                )),
                const SizedBox(width: 12),
                Expanded(child: StatCard(
                  title: 'Transaksi',
                  value: '${tx.todayTransactionCount}',
                  icon: Icons.receipt,
                  color: const Color(0xFF1565C0),
                )),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: StatCard(
                  title: 'Buku Terjual',
                  value: '${tx.todayItemsSold}',
                  icon: Icons.menu_book,
                  color: const Color(0xFFE65100),
                )),
                const SizedBox(width: 12),
                Expanded(child: StatCard(
                  title: 'Stok Rendah',
                  value: '${books.lowStockBooks.length}',
                  icon: Icons.warning_amber,
                  color: books.lowStockBooks.isNotEmpty
                      ? const Color(0xFFC62828)
                      : const Color(0xFF558B2F),
                )),
              ]),
              const SizedBox(height: 24),

              // Revenue Chart
              Text('Penjualan 7 Hari',
                style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              const RevenueChart(),
              const SizedBox(height: 24),

              // Quick Actions — now with real navigation
              Text('Menu Cepat',
                style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 12),
              Row(children: [
                _QuickAction(
                  icon: Icons.add_shopping_cart,
                  label: 'Transaksi Baru',
                  color: Theme.of(context).colorScheme.primary,
                  onTap: () => onNavigate(1), // → Kasir
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.add_box_outlined,
                  label: 'Tambah Buku',
                  color: const Color(0xFF1565C0),
                  onTap: () => _showAddBookForm(context),
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.bar_chart,
                  label: 'Riwayat',
                  color: const Color(0xFF2E7D32),
                  onTap: () => onNavigate(3), // → Riwayat
                ),
              ]),
              const SizedBox(height: 24),

              // Low Stock Alert
              if (books.lowStockBooks.isNotEmpty) ...[
                Text('Peringatan Stok',
                  style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: books.lowStockBooks.take(5).map((book) =>
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: book.isOutOfStock
                                ? const Color(0xFFFFEBEE)
                                : const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            book.isOutOfStock ? Icons.remove_shopping_cart : Icons.warning_amber,
                            color: book.isOutOfStock
                                ? const Color(0xFFC62828)
                                : const Color(0xFFE65100),
                            size: 20,
                          ),
                        ),
                        title: Text(book.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                        subtitle: Text(book.author),
                        trailing: Chip(
                          label: Text(
                            book.isOutOfStock ? 'Habis' : '${book.stock} sisa',
                            style: TextStyle(
                              fontSize: 11,
                              color: book.isOutOfStock
                                  ? const Color(0xFFC62828)
                                  : const Color(0xFFE65100),
                            ),
                          ),
                          backgroundColor: book.isOutOfStock
                              ? const Color(0xFFFFEBEE)
                              : const Color(0xFFFFF8E1),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showAddBookForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookForm(
        book: null,
        onSave: (b) => context.read<BookProvider>().addBook(b),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
