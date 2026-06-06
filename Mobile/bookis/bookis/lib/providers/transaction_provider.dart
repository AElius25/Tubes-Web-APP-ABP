import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/cart_item.dart';

class TransactionProvider extends ChangeNotifier {
  final List<Transaction> _transactions = [];
  int _receiptCounter = 1001;

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  List<Transaction> get todayTransactions {
    final now = DateTime.now();
    return _transactions.where((t) =>
      t.createdAt.year == now.year &&
      t.createdAt.month == now.month &&
      t.createdAt.day == now.day &&
      t.status == TransactionStatus.completed
    ).toList();
  }

  double get todayRevenue =>
      todayTransactions.fold(0.0, (s, t) => s + t.total);

  int get todayItemsSold =>
      todayTransactions.fold(0, (s, t) => s + t.totalItems);

  int get todayTransactionCount => todayTransactions.length;

  // Weekly revenue for chart
  List<double> get weeklyRevenue {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return _transactions
          .where((t) =>
              t.createdAt.year == day.year &&
              t.createdAt.month == day.month &&
              t.createdAt.day == day.day &&
              t.status == TransactionStatus.completed)
          .fold(0.0, (s, t) => s + t.total);
    });
  }

  // Top selling books
  Map<String, int> get topSellingBooks {
    final Map<String, int> counts = {};
    for (final t in _transactions) {
      if (t.status != TransactionStatus.completed) continue;
      for (final item in t.items) {
        counts[item.bookTitle] = (counts[item.bookTitle] ?? 0) + item.quantity;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(5));
  }

  String _generateReceiptNumber() {
    final now = DateTime.now();
    final prefix = 'INV${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    return '$prefix-${_receiptCounter++}';
  }

  Transaction createTransaction({
    required List<CartItem> cartItems,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    required double amountPaid,
    required PaymentMethod paymentMethod,
    String? customerName,
    String? notes,
  }) {
    final items = cartItems.map((ci) => TransactionItem(
      bookId: ci.book.id,
      bookTitle: ci.book.title,
      bookAuthor: ci.book.author,
      unitPrice: ci.book.price,
      quantity: ci.quantity,
      discount: ci.discount ?? 0,
    )).toList();

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      receiptNumber: _generateReceiptNumber(),
      createdAt: DateTime.now(),
      items: items,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      amountPaid: amountPaid,
      change: amountPaid - total,
      paymentMethod: paymentMethod,
      customerName: customerName,
      notes: notes,
    );

    _transactions.insert(0, transaction);
    notifyListeners();
    return transaction;
  }

  void voidTransaction(String id) {
    final idx = _transactions.indexWhere((t) => t.id == id);
    if (idx != -1) {
      _transactions[idx].status = TransactionStatus.voided;
      notifyListeners();
    }
  }

  void loadDummySales() {
    // Add some historical data for dashboard chart
    final now = DateTime.now();
    final random = [145000.0, 220000.0, 89000.0, 310000.0, 175000.0, 260000.0];
    for (int i = 6; i >= 1; i--) {
      final day = now.subtract(Duration(days: i));
      if (random[6 - i] > 0) {
        _transactions.add(Transaction(
          id: 'dummy_$i',
          receiptNumber: 'INV-DUMMY-$i',
          createdAt: day.copyWith(hour: 14),
          items: [TransactionItem(
            bookId: 'dummy',
            bookTitle: 'Sample Book',
            bookAuthor: 'Author',
            unitPrice: random[6 - i],
            quantity: 1,
          )],
          subtotal: random[6 - i],
          total: random[6 - i],
          amountPaid: random[6 - i],
          change: 0,
          paymentMethod: PaymentMethod.cash,
        ));
      }
    }
    notifyListeners();
  }
}

extension DateTimeCopyWith on DateTime {
  DateTime copyWith({int? year, int? month, int? day, int? hour, int? minute, int? second}) {
    return DateTime(year ?? this.year, month ?? this.month, day ?? this.day,
        hour ?? this.hour, minute ?? this.minute, second ?? this.second);
  }
}
