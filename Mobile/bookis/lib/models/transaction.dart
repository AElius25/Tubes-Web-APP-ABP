import 'cart_item.dart';

enum PaymentMethod { cash, qris, transfer, debit }
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
    'bookId': bookId, 'bookTitle': bookTitle, 'bookAuthor': bookAuthor,
    'unitPrice': unitPrice, 'quantity': quantity, 'discount': discount,
  };

  factory TransactionItem.fromJson(Map<String, dynamic> j) => TransactionItem(
    bookId: j['bookId'], bookTitle: j['bookTitle'],
    bookAuthor: j['bookAuthor'], unitPrice: (j['unitPrice'] as num).toDouble(),
    quantity: j['quantity'], discount: (j['discount'] as num).toDouble(),
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

  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);

  Map<String, dynamic> toJson() => {
    'id': id,
    'receiptNumber': receiptNumber,
    'createdAt': createdAt.toIso8601String(),
    'items': items.map((i) => i.toJson()).toList(),
    'subtotal': subtotal,
    'discount': discount,
    'tax': tax,
    'total': total,
    'amountPaid': amountPaid,
    'change': change,
    'paymentMethod': paymentMethod.name,
    'status': status.name,
    'customerName': customerName,
    'notes': notes,
    'cashierName': cashierName,
  };
}
