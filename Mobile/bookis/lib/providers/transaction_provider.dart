import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/cart_item.dart';
import '../services/supabase_service.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  int _receiptCounter = 1001;
  bool _loading = false;
  String? _error;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  bool get isLoading => _loading;
  String? get error => _error;

  List<Transaction> get todayTransactions {
    final now = DateTime.now();
    return _transactions.where((t) =>
      t.createdAt.year == now.year &&
      t.createdAt.month == now.month &&
      t.createdAt.day == now.day &&
      t.status == TransactionStatus.completed).toList();
  }

  double get todayRevenue =>
      todayTransactions.fold(0.0, (s, t) => s + t.total);
  int get todayItemsSold =>
      todayTransactions.fold(0, (s, t) => s + t.totalItems);
  int get todayTransactionCount => todayTransactions.length;

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

  // ─── Supabase Operations ────────────────────────────────────────────────────

  /// Load semua transaksi dari Supabase
  Future<void> loadTransactions() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _transactions = await SupabaseService.fetchTransactions();
      // Set counter dari nomor terbesar yang ada
      if (_transactions.isNotEmpty) {
        final nums = _transactions
            .map((t) => int.tryParse(t.receiptNumber.split('-').last) ?? 0)
            .toList();
        _receiptCounter = (nums.reduce((a, b) => a > b ? a : b)) + 1;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  String _generateReceiptNumber() {
    final now = DateTime.now();
    final prefix = 'INV${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    return '$prefix-${_receiptCounter++}';
  }

  /// Buat transaksi baru → simpan ke Supabase → tambah ke list lokal
  Future<Transaction> createTransaction({
    required List<CartItem> cartItems,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    required double amountPaid,
    required PaymentMethod paymentMethod,
    String? customerName,
    String? notes,
  }) async {
    final receiptNumber = _generateReceiptNumber();
    final transaction = await SupabaseService.insertTransaction(
      cartItems: cartItems,
      subtotal: subtotal,
      discount: discount,
      tax: tax,
      total: total,
      amountPaid: amountPaid,
      paymentMethod: paymentMethod,
      customerName: customerName,
      notes: notes,
      receiptNumber: receiptNumber,
    );
    _transactions.insert(0, transaction);
    notifyListeners();
    return transaction;
  }

  /// Batalkan transaksi di Supabase + update lokal
  Future<void> voidTransaction(String id) async {
    try {
      await SupabaseService.voidTransaction(id);
      final idx = _transactions.indexWhere((t) => t.id == id);
      if (idx != -1) {
        _transactions[idx].status = TransactionStatus.voided;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

extension DateTimeCopyWith on DateTime {
  DateTime copyWith({int? year, int? month, int? day,
      int? hour, int? minute, int? second}) {
    return DateTime(year ?? this.year, month ?? this.month, day ?? this.day,
        hour ?? this.hour, minute ?? this.minute, second ?? this.second);
  }
}
