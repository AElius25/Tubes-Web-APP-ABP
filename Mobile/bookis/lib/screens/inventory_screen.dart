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
  final fmt =
      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

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
            FilterChip(
              label: const Text(
                'Stok Rendah',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1208),
                ),
              ),
              selected: false,
              onSelected: (_) {},
              avatar: const Icon(Icons.warning_amber,
                  size: 14, color: Color(0xFFE65100)),
              backgroundColor: const Color(0xFFFAF6F0),
              side: BorderSide(color: const Color(0xFF3D2B1F).withOpacity(0.2)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ]),
        ),
        if (books.error != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              Expanded(
                  child: Text('Error: ${books.error}',
                      style: const TextStyle(color: Colors.red, fontSize: 12))),
            ]),
          ),
        if (books.isLoading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else
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
        onSave: (b) async {
          try {
            if (book == null) {
              await ctx.read<BookProvider>().addBook(b);
            } else {
              await ctx.read<BookProvider>().updateBook(b);
            }
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text(book == null
                    ? '"${b.title}" berhasil ditambahkan'
                    : '"${b.title}" berhasil diperbarui'),
                backgroundColor: Colors.green,
              ));
            }
          } catch (e) {
            if (ctx.mounted) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                content: Text('Gagal menyimpan: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ));
            }
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hapus "${book.title}" dari inventori?'),
            const SizedBox(height: 12),
            // Info peringatan FK constraint
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.amber),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Buku yang sudah pernah terjual tidak bisa dihapus '
                      'karena masih ada di riwayat transaksi.\n\n'
                      'Sebagai alternatif, set stok ke 0 agar tidak muncul di kasir.',
                      style: TextStyle(fontSize: 11, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          // Tombol set stok 0 sebagai alternatif hapus
          OutlinedButton.icon(
            icon: const Icon(Icons.inventory_2_outlined, size: 16),
            label: const Text('Set Stok = 0'),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final updated = book.copyWith(stock: 0);
                await ctx.read<BookProvider>().updateBook(updated);
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Stok berhasil diset ke 0'),
                    backgroundColor: Colors.orange,
                  ));
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('Gagal: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            },
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('Hapus'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ctx.read<BookProvider>().deleteBook(book.id);
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('"${book.title}" berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ));
                }
              } catch (e) {
                if (ctx.mounted) {
                  // Tangani FK violation dengan pesan yang lebih ramah
                  final isFkError = e.toString().contains('23503') ||
                      e.toString().contains('foreign key');
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text(
                      isFkError
                          ? 'Tidak bisa dihapus: buku ini ada di riwayat transaksi. '
                            'Gunakan "Set Stok = 0" sebagai gantinya.'
                          : 'Gagal menghapus: $e',
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                    action: isFkError
                        ? SnackBarAction(
                            label: 'Set Stok 0',
                            textColor: Colors.white,
                            onPressed: () async {
                              final updated = book.copyWith(stock: 0);
                              await ctx.read<BookProvider>().updateBook(updated);
                            },
                          )
                        : null,
                  ));
                }
              }
            },
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
    required this.book,
    required this.fmt,
    required this.onEdit,
    required this.onDelete,
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
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book, size: 22),
            ],
          ),
        ),
        title: Text(book.title,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(book.author, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(book.category,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 6),
            Text(fmt.format(book.price),
                style: TextStyle(
                    fontSize: 11,
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
                style: TextStyle(
                    color: stockColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero)),
              PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                      leading: Icon(Icons.delete_outline, color: Colors.red),
                      title: Text('Hapus', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero)),
            ],
          ),
        ]),
      ),
    );
  }
}
