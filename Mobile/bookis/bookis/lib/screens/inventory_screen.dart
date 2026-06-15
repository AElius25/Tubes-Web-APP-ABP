import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/book_provider.dart';
import '../models/book.dart';
import '../widgets/book_form.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _searchCtrl = TextEditingController();
  final fmt = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final books = context.watch<BookProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Stok'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Buku',
            onPressed: () => _showBookForm(context, null),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _searchCtrl,
                onChanged: books.setSearch,
                decoration: const InputDecoration(
                  hintText: 'Cari buku...',
                  prefixIcon: Icon(Icons.search),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Filter by low stock
            FilterChip(
              label: const Text('Stok Rendah'),
              selected: false,
              onSelected: (_) {},
              avatar: const Icon(Icons.warning_amber, size: 14),
            ),
          ]),
        ),
        Expanded(
          child: books.books.isEmpty
              ? const Center(child: Text('Tidak ada buku'))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: books.books.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (ctx, i) {
                    final book = books.books[i];
                    return _InventoryBookTile(
                      book: book,
                      fmt: fmt,
                      onEdit: () => _showBookForm(ctx, book),
                      onDelete: () => _confirmDelete(ctx, book),
                    );
                  },
                ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Buku'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showBookForm(BuildContext ctx, Book? book) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BookForm(
        book: book,
        onSave: (b) {
          if (book == null) {
            ctx.read<BookProvider>().addBook(b);
          } else {
            ctx.read<BookProvider>().updateBook(b);
          }
        },
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, Book book) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Buku?'),
        content: Text('Hapus "${book.title}" dari inventori?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ctx.read<BookProvider>().deleteBook(book.id);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _InventoryBookTile extends StatelessWidget {
  final Book book;
  final NumberFormat fmt;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InventoryBookTile({
    required this.book, required this.fmt,
    required this.onEdit, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color stockColor = Colors.green;
    String stockLabel = '${book.stock} stok';
    if (book.isOutOfStock) {
      stockColor = Colors.red;
      stockLabel = 'Habis';
    } else if (book.isLowStock) {
      stockColor = Colors.orange;
    }

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 46,
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.menu_book, size: 22),
            ],
          ),
        ),
        title: Text(book.title,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(book.author, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(book.category,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 6),
            Text(fmt.format(book.price),
              style: TextStyle(fontSize: 11,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600)),
          ]),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: stockColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: stockColor.withOpacity(0.3)),
            ),
            child: Text(stockLabel,
              style: TextStyle(color: stockColor, fontSize: 11,
                fontWeight: FontWeight.w600)),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit',
                child: ListTile(leading: Icon(Icons.edit_outlined),
                  title: Text('Edit'), contentPadding: EdgeInsets.zero)),
              PopupMenuItem(value: 'delete',
                child: ListTile(leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Hapus', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero)),
            ],
          ),
        ]),
      ),
    );
  }
}
