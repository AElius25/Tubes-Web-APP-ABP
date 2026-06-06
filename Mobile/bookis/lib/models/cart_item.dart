import 'book.dart';

class CartItem {
  final Book book;
  int quantity;
  double? discount; // percentage 0-100

  CartItem({
    required this.book,
    this.quantity = 1,
    this.discount,
  });

  double get subtotal {
    final base = book.price * quantity;
    if (discount != null && discount! > 0) {
      return base * (1 - discount! / 100);
    }
    return base;
  }

  double get discountAmount {
    if (discount == null || discount == 0) return 0;
    return book.price * quantity * (discount! / 100);
  }
}
