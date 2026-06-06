import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/book_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/book.dart';
import '../models/transaction.dart';
import '../widgets/book_card.dart';
import 'payment_screen.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final TextEditingController _searchController = TextEditingController();
  final fmt = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final books = context.watch<BookProvider>();
    final cart = context.watch<CartProvider>();
    final isWide = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          const Icon(Icons.point_of_sale, size: 20),
          const SizedBox(width: 8),
          const Text('Kasir'),
          if (cart.itemCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${cart.itemCount}',
                style: const TextStyle(fontSize: 12, color: Colors.black87,
                  fontWeight: FontWeight.bold)),
            ),
          ],
        ]),
        actions: [
          if (cart.itemCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Kosongkan keranjang',
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: isWide
          ? Row(children: [
              Expanded(flex: 5, child: _BookGrid(
                  books: books, searchController: _searchController,
                  fmt: fmt, onAddToCart: _addToCart)),
              const VerticalDivider(width: 1),
              SizedBox(width: 360, child: _CartPanel(fmt: fmt)),
            ])
          : Column(children: [
              Expanded(child: _BookGrid(
                  books: books, searchController: _searchController,
                  fmt: fmt, onAddToCart: _addToCart)),
              _CartSummaryBar(fmt: fmt),
            ]),
    );
  }

  void _addToCart(BuildContext ctx, Book book) {
    final cart = ctx.read<CartProvider>();
    if (book.isOutOfStock) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(content: Text('"${book.title}" stok habis'),
          backgroundColor: Theme.of(ctx).colorScheme.error),
      );
      return;
    }
    cart.addBook(book);
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('"${book.title}" ditambahkan'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(ctx).colorScheme.primary,
      ),
    );
  }

  void _confirmClear(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Kosongkan Keranjang?'),
        content: const Text('Semua item akan dihapus dari keranjang.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ctx.read<CartProvider>().clear();
              Navigator.pop(ctx);
            },
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );
  }
}

class _BookGrid extends StatelessWidget {
  final BookProvider books;
  final TextEditingController searchController;
  final NumberFormat fmt;
  final Function(BuildContext, Book) onAddToCart;

  const _BookGrid({
    required this.books,
    required this.searchController,
    required this.fmt,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: searchController,
                onChanged: books.setSearch,
                decoration: const InputDecoration(
                  hintText: 'Cari judul, pengarang, ISBN...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _CategoryFilter(books: books),
          ]),
        ),
        Expanded(
          child: books.books.isEmpty
              ? const Center(child: Text('Tidak ada buku ditemukan'))
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: books.books.length,
                  itemBuilder: (ctx, i) {
                    final book = books.books[i];
                    return BookCard(
                      book: book,
                      fmt: fmt,
                      onTap: () => onAddToCart(ctx, book),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final BookProvider books;
  const _CategoryFilter({required this.books});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: books.selectedCategory,
      onSelected: books.setCategory,
      itemBuilder: (_) => books.categories.map((cat) =>
        PopupMenuItem(value: cat, child: Text(cat))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.filter_list, size: 18),
          const SizedBox(width: 4),
          Text(books.selectedCategory,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

class _CartPanel extends StatelessWidget {
  final NumberFormat fmt;
  const _CartPanel({required this.fmt});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primary,
          child: Row(children: [
            const Icon(Icons.shopping_cart, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Keranjang (${cart.itemCount})',
              style: const TextStyle(color: Colors.white,
                fontWeight: FontWeight.w600, fontSize: 15)),
          ]),
        ),
        Expanded(
          child: cart.isEmpty
              ? const Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 48,
                        color: Colors.grey),
                    SizedBox(height: 12),
                    Text('Keranjang kosong', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 4),
                    Text('Pilih buku dari katalog', style: TextStyle(
                        color: Colors.grey, fontSize: 12)),
                  ],
                ))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final item = cart.items[i];
                    return _CartItemTile(item: item, fmt: fmt);
                  },
                ),
        ),
        // Order summary
        if (!cart.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8, offset: const Offset(0, -2)
              )],
            ),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Subtotal'),
                    Text(fmt.format(cart.subtotal)),
                  ]),
                if (cart.globalDiscount > 0) ...[
                  const SizedBox(height: 4),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Diskon (${cart.globalDiscount.toStringAsFixed(0)}%)',
                        style: const TextStyle(color: Colors.green)),
                      Text('- ${fmt.format(cart.discountAmount)}',
                        style: const TextStyle(color: Colors.green)),
                    ]),
                ],
                const Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('TOTAL', style: Theme.of(context).textTheme.titleMedium?.
                      copyWith(fontWeight: FontWeight.w700)),
                    Text(fmt.format(cart.total),
                      style: Theme.of(context).textTheme.titleMedium?.
                        copyWith(fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary)),
                  ]),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _goToPayment(context),
                    icon: const Icon(Icons.payment),
                    label: Text('Bayar ${fmt.format(cart.total)}'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _goToPayment(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => const PaymentScreen(),
    ));
  }
}

class _CartItemTile extends StatelessWidget {
  final dynamic item;
  final NumberFormat fmt;
  const _CartItemTile({required this.item, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.book.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 13),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            Text(item.book.author,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
            Text(fmt.format(item.book.price),
              style: TextStyle(color: Theme.of(context).colorScheme.primary,
                fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Row(children: [
            _QtyBtn(icon: Icons.remove, onTap: () =>
                cart.decrementQty(item.book.id)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('${item.quantity}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            _QtyBtn(icon: Icons.add, onTap: () =>
                cart.incrementQty(item.book.id)),
          ]),
          const SizedBox(height: 4),
          Text(fmt.format(item.subtotal),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ]),
      ]),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }
}

class _CartSummaryBar extends StatelessWidget {
  final NumberFormat fmt;
  const _CartSummaryBar({required this.fmt});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12 + MediaQuery.of(context).padding.bottom / 2),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12, offset: const Offset(0, -3)
        )],
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${cart.totalQuantity} item', style: Theme.of(context).textTheme.bodyMedium),
          Text(fmt.format(cart.total),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700)),
        ]),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PaymentScreen())),
          icon: const Icon(Icons.payment, size: 18),
          label: const Text('Bayar'),
        ),
      ]),
    );
  }
}
