import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../providers/books_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<BooksProvider, CartProvider>(
      builder: (context, books, cart, _) {
        return Scaffold(
          backgroundColor: KedaiBukuTheme.surface,
          appBar: AppBar(
            title: const Text('Kasir'),
            actions: [
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CartScreen()),
                    ),
                  ),
                  if (cart.totalItems > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: KedaiBukuTheme.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.totalItems}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: books.setSearch,
                  decoration: const InputDecoration(
                    hintText: 'Cari judul, penulis, ISBN...',
                    prefixIcon: Icon(Icons.search, color: KedaiBukuTheme.textLight),
                    suffixIcon: null,
                  ),
                ),
              ),

              // Category Filter
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: bookCategories.length,
                  itemBuilder: (context, index) {
                    final cat = bookCategories[index];
                    final isSelected = books.selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (_) => books.setCategory(cat),
                        backgroundColor: KedaiBukuTheme.cardBg,
                        selectedColor: KedaiBukuTheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : KedaiBukuTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? KedaiBukuTheme.primary
                              : KedaiBukuTheme.divider,
                        ),
                        showCheckmark: false,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // Book Grid
              Expanded(
                child: books.books.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        title: 'Buku tidak ditemukan',
                        subtitle:
                            'Coba kata kunci lain atau pilih kategori berbeda',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.58,
                        ),
                        itemCount: books.books.length,
                        itemBuilder: (context, index) {
                          final book = books.books[index];
                          return BookCard(
                            title: book.title,
                            author: book.author,
                            category: book.category,
                            price: book.price,
                            stock: book.stock,
                            onAddToCart: () {
                              cart.addBook(book);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '"${book.title}" ditambahkan ke keranjang'),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor: KedaiBukuTheme.success,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: cart.totalItems > 0
              ? FloatingActionButton.extended(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ),
                  backgroundColor: KedaiBukuTheme.primary,
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  label: Text(
                    '${cart.totalItems} item · lihat keranjang',
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              : null,
        );
      },
    );
  }
}
