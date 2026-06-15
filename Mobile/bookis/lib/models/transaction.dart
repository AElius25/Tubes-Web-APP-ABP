import 'cart_item.dart';

enum PaymentMethod { cash, qris }  // ← hanya Tunai dan QRIS
enum TransactionStatus { completed, refunded, voided }

class TransactionItem {
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final double unitPrice;
  final int quantity;
  final double discount;

  TransactionItem({
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    required this.unitPrice,
    required this.quantity,
    this.discount = 0,
  });

  double get subtotal => unitPrice * quantity * (1 - discount / 100);

  Map<String, dynamic> toJson() => {
    'book_id': bookId, 'book_title': bookTitle, 'book_author': bookAuthor,
    'unit_price': unitPrice, 'quantity': quantity, 'discount': discount,
  };

  factory TransactionItem.fromJson(Map<String, dynamic> j) => TransactionItem(
    bookId: j['book_id'] ?? j['bookId'] ?? '',
    bookTitle: j['book_title'] ?? j['bookTitle'] ?? '',
    bookAuthor: j['book_author'] ?? j['bookAuthor'] ?? '',
    unitPrice: (j['unit_price'] ?? j['unitPrice'] as num).toDouble(),
    quantity: j['quantity'] ?? 1,
    discount: ((j['discount'] ?? 0) as num).toDouble(),
  );
}

class Transaction {
  final String id;
  final String receiptNumber;
  final DateTime createdAt;
  final List<TransactionItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final double amountPaid;
  final double change;
  final PaymentMethod paymentMethod;
  TransactionStatus status;
  final String? customerName;
  final String? notes;
  final String cashierName;

  Transaction({
    required this.id,
    required this.receiptNumber,
    required this.createdAt,
    required this.items,
    required this.subtotal,
    this.discount = 0,
    this.tax = 0,
    required this.total,
    required this.amountPaid,
    required this.change,
    required this.paymentMethod,
    this.status = TransactionStatus.completed,
    this.customerName,
    this.notes,
    this.cashierName = 'Kasir',
  });

  int get totalItems => items.fold(0, (s, i) => s + i.quantity);

  /// Dari Supabase — snake_case, items sudah di-join
  factory Transaction.fromJson(Map<String, dynamic> j) {
    final itemsRaw = j['items'] ?? j['transaction_items'] ?? [];
    final items = (itemsRaw as List)
        .map((i) => TransactionItem.fromJson(i as Map<String, dynamic>))
        .toList();

    PaymentMethod method = PaymentMethod.cash;
    final m = j['payment_method'] ?? 'cash';
    if (m == 'qris') method = PaymentMethod.qris;

    TransactionStatus status = TransactionStatus.completed;
    final s = j['status'] ?? 'completed';
    if (s == 'voided') status = TransactionStatus.voided;
    if (s == 'refunded') status = TransactionStatus.refunded;

    return Transaction(
      id: j['id'].toString(),
      receiptNumber: j['receipt_number'] ?? j['receiptNumber'] ?? '',
      createdAt: j['created_at'] != null
          ? DateTime.parse(j['created_at'])
          : DateTime.now(),
      items: items,
      subtotal: ((j['subtotal'] ?? 0) as num).toDouble(),
      discount: ((j['discount'] ?? 0) as num).toDouble(),
      tax: ((j['tax'] ?? 0) as num).toDouble(),
      total: ((j['total'] ?? 0) as num).toDouble(),
      amountPaid: ((j['amount_paid'] ?? 0) as num).toDouble(),
      change: ((j['change'] ?? 0) as num).toDouble(),
      paymentMethod: method,
      status: status,
      customerName: j['customer_name'],
      notes: j['notes'],
      cashierName: j['cashier_name'] ?? 'Kasir',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'receipt_number': receiptNumber,
    'created_at': createdAt.toIso8601String(),
    'subtotal': subtotal,
    'discount': discount,
    'tax': tax,
    'total': total,
    'amount_paid': amountPaid,
    'change': change,
    'payment_method': paymentMethod.name,
    'status': status.name,
    'customer_name': customerName,
    'notes': notes,
    'cashier_name': cashierName,
  };
}
