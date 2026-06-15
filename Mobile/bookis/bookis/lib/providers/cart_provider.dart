import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  double _globalDiscount = 0; // percent

  List<CartItem> get items => List.unmodifiable(_items);
  double get globalDiscount => _globalDiscount;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;

  int get totalQuantity => _items.fold(0, (s, i) => s + i.quantity);

  double get subtotal => _items.fold(0.0, (s, i) => s + i.subtotal);

  double get discountAmount {
    if (_globalDiscount <= 0) return 0;
    return subtotal * (_globalDiscount / 100);
  }

  double get tax => 0.0; // PPN optional

  double get total {
    final afterDiscount = subtotal - discountAmount;
    return afterDiscount + tax;
  }

  void addBook(Book book) {
    final existing = _items.where((i) => i.book.id == book.id);
    if (existing.isNotEmpty) {
      if (existing.first.quantity < book.stock) {
        existing.first.quantity++;
        notifyListeners();
      }
    } else if (!book.isOutOfStock) {
      _items.add(CartItem(book: book));
      notifyListeners();
    }
  }

  void removeItem(String bookId) {
    _items.removeWhere((i) => i.book.id == bookId);
    notifyListeners();
  }

  void incrementQty(String bookId) {
    final item = _items.firstWhere((i) => i.book.id == bookId);
    if (item.quantity < item.book.stock) {
      item.quantity++;
      notifyListeners();
    }
  }

  void decrementQty(String bookId) {
    final item = _items.firstWhere((i) => i.book.id == bookId);
    if (item.quantity > 1) {
      item.quantity--;
      notifyListeners();
    } else {
      removeItem(bookId);
    }
  }

  void setItemDiscount(String bookId, double discount) {
    final item = _items.firstWhere((i) => i.book.id == bookId);
    item.discount = discount;
    notifyListeners();
  }

  void setGlobalDiscount(double percent) {
    _globalDiscount = percent.clamp(0, 100);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _globalDiscount = 0;
    notifyListeners();
  }
}
