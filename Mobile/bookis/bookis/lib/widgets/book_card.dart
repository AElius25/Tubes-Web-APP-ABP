import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final NumberFormat fmt;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.fmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnavailable = book.isOutOfStock;
    return InkWell(
      onTap: isUnavailable ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: isUnavailable ? 0.5 : 1.0,
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover placeholder
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _categoryColor(book.category).withOpacity(0.12),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book,
                        size: 36,
                        color: _categoryColor(book.category)),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(book.category,
                          style: TextStyle(
                            fontSize: 9,
                            color: _categoryColor(book.category),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Info
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(book.author,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              fmt.format(book.price),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (book.isOutOfStock)
                            const Text('Habis',
                              style: TextStyle(fontSize: 9, color: Colors.red,
                                fontWeight: FontWeight.w600))
                          else if (book.isLowStock)
                            Text('Sisa ${book.stock}',
                              style: const TextStyle(fontSize: 9,
                                color: Colors.orange, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Fiksi': return const Color(0xFF6A1B9A);
      case 'Fiksi Sejarah': return const Color(0xFF0D47A1);
      case 'Pengembangan Diri': return const Color(0xFF2E7D32);
      case 'Sejarah': return const Color(0xFFE65100);
      case 'Keuangan': return const Color(0xFF1565C0);
      case 'Bisnis': return const Color(0xFF4E342E);
      default: return const Color(0xFF3D2B1F);
    }
  }
}
