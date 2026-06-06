import 'dart:io';
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
              // Cover: file lokal → URL jaringan → placeholder
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12)),
                  child: _buildCover(),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          height: 1.2,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(book.author,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
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
                                color: Colors.orange,
                                fontWeight: FontWeight.w600)),
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

  Widget _buildCover() {
    // 1. File lokal (dari image_picker)
    if (book.coverPath != null && book.coverPath!.isNotEmpty) {
      final file = File(book.coverPath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _CoverPlaceholder(book: book),
        );
      }
    }

    // 2. URL jaringan (data lama / fallback)
    if (book.coverUrl != null && book.coverUrl!.isNotEmpty) {
      return Image.network(
        book.coverUrl!,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _CoverPlaceholder(book: book),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _CoverPlaceholder(book: book),
      );
    }

    // 3. Placeholder
    return _CoverPlaceholder(book: book);
  }
}

class _CoverPlaceholder extends StatelessWidget {
  final Book book;
  const _CoverPlaceholder({required this.book});

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(book.category);
    return Container(
      width: double.infinity,
      color: color.withOpacity(0.12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 36, color: color),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(book.category,
              style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Fiksi': return const Color(0xFF6A1B9A);
      case 'Sosial': return const Color(0xFF0D47A1);
      case 'Produktivitas': return const Color(0xFF2E7D32);
      case 'Sejarah': return const Color(0xFFE65100);
      case 'Keuangan': return const Color(0xFF1565C0);
      case 'Bisnis': return const Color(0xFF4E342E);
      default: return const Color(0xFF3D2B1F);
    }
  }
}
