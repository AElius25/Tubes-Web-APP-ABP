import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book.dart';
import '../models/transaction.dart';
import '../models/cart_item.dart';

/// Semua operasi database Supabase terpusat di sini.
/// Ganti SUPABASE_URL dan SUPABASE_ANON_KEY dengan milik Anda.
class SupabaseService {
  static const String supabaseUrl = 'https://cklwhfyjskiiblidwepe.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNrbHdoZnlqc2tpaWJsaWR3ZXBlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA3NTYxNTcsImV4cCI6MjA5NjMzMjE1N30.vpwN-BReeH1JwwPHi_bmW6YpCkoQi0foM71arQO-EMs';

  static SupabaseClient get client => Supabase.instance.client;

  // ─── Inisialisasi ───────────────────────────────────────────────────────────

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // ─── BOOKS ──────────────────────────────────────────────────────────────────

  /// Ambil semua buku dari tabel `books`
  static Future<List<Book>> fetchBooks() async {
    final data = await client.from('books').select().order('title');
    return (data as List).map((e) => Book.fromJson(e)).toList();
  }

  /// Tambah buku baru, kembalikan buku yang sudah ada ID-nya dari DB
  static Future<Book> insertBook(Book book) async {
    final data = await client
        .from('books')
        .insert(book.toJson()..remove('id'))
        .select()
        .single();
    return Book.fromJson(data);
  }

  /// Update buku yang sudah ada
  static Future<void> updateBook(Book book) async {
    await client.from('books').update(book.toJson()).eq('id', book.id);
  }

  /// Hapus buku
  static Future<void> deleteBook(String id) async {
    await client.from('books').delete().eq('id', id);
  }

  /// Kurangi stok setelah transaksi
  static Future<void> decreaseStock(String bookId, int qty) async {
    await client.rpc('decrease_book_stock', params: {
      'book_id': bookId,
      'qty': qty,
    });
  }

  // ─── TRANSACTIONS ────────────────────────────────────────────────────────────

  /// Ambil semua transaksi beserta item-nya
  static Future<List<Transaction>> fetchTransactions() async {
    final txData = await client
        .from('transactions')
        .select('*, transaction_items(*)')
        .order('created_at', ascending: false);

    return (txData as List).map((e) {
      // Parse items dari raw Map dulu
      final rawItems = (e['transaction_items'] as List? ?? []);
      final items = rawItems
          .map((i) => TransactionItem.fromJson(i as Map<String, dynamic>))
          .toList();

      // Tentukan payment method
      PaymentMethod method = PaymentMethod.cash;
      if ((e['payment_method'] ?? 'cash') == 'qris') {
        method = PaymentMethod.qris;
      }

      // Tentukan status
      TransactionStatus status = TransactionStatus.completed;
      final s = e['status'] ?? 'completed';
      if (s == 'voided') status = TransactionStatus.voided;
      if (s == 'refunded') status = TransactionStatus.refunded;

      // Bangun Transaction langsung — items sudah berupa List<TransactionItem>
      return Transaction(
        id: e['id'].toString(),
        receiptNumber: e['receipt_number'] ?? '',
        createdAt: e['created_at'] != null
            ? DateTime.parse(e['created_at'])
            : DateTime.now(),
        items: items,
        subtotal: ((e['subtotal'] ?? 0) as num).toDouble(),
        discount: ((e['discount'] ?? 0) as num).toDouble(),
        tax: ((e['tax'] ?? 0) as num).toDouble(),
        total: ((e['total'] ?? 0) as num).toDouble(),
        amountPaid: ((e['amount_paid'] ?? 0) as num).toDouble(),
        change: ((e['change'] ?? 0) as num).toDouble(),
        paymentMethod: method,
        status: status,
        customerName: e['customer_name'],
        notes: e['notes'],
        cashierName: e['cashier_name'] ?? 'Kasir',
      );
    }).toList();
  }

  /// Simpan transaksi + item ke DB dalam satu operasi
  static Future<Transaction> insertTransaction({
    required List<CartItem> cartItems,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
    required double amountPaid,
    required PaymentMethod paymentMethod,
    String? customerName,
    String? notes,
    required String receiptNumber,
  }) async {
    // 1. Insert transaksi header
    final txData = await client
        .from('transactions')
        .insert({
          'receipt_number': receiptNumber,
          'subtotal': subtotal,
          'discount': discount,
          'tax': tax,
          'total': total,
          'amount_paid': amountPaid,
          'change': amountPaid - total,
          'payment_method': paymentMethod.name,
          'status': 'completed',
          'customer_name': customerName,
          'notes': notes,
          'cashier_name': 'Kasir',
        })
        .select()
        .single();

    final txId = txData['id'] as String;

    // 2. Insert semua item
    final itemsPayload = cartItems
        .map((ci) => {
              'transaction_id': txId,
              'book_id': ci.book.id,
              'book_title': ci.book.title,
              'book_author': ci.book.author,
              'unit_price': ci.book.price,
              'quantity': ci.quantity,
              'discount': ci.discount ?? 0,
            })
        .toList();

    final itemsData =
        await client.from('transaction_items').insert(itemsPayload).select();

    // itemsData adalah List<Map> dari Supabase — parse dulu ke TransactionItem
    final items = (itemsData as List)
        .map((i) => TransactionItem.fromJson(i as Map<String, dynamic>))
        .toList();

    // Bangun Transaction langsung (jangan lewat fromJson karena items
    // sudah berupa List<TransactionItem>, bukan List<Map>)
    PaymentMethod method = PaymentMethod.cash;
    if (paymentMethod == PaymentMethod.qris) method = PaymentMethod.qris;

    return Transaction(
      id: txData['id'].toString(),
      receiptNumber: txData['receipt_number'] ?? receiptNumber,
      createdAt: txData['created_at'] != null
          ? DateTime.parse(txData['created_at'])
          : DateTime.now(),
      items: items,
      subtotal: (txData['subtotal'] as num).toDouble(),
      discount: (txData['discount'] as num).toDouble(),
      tax: (txData['tax'] as num).toDouble(),
      total: (txData['total'] as num).toDouble(),
      amountPaid: (txData['amount_paid'] as num).toDouble(),
      change: (txData['change'] as num).toDouble(),
      paymentMethod: method,
      customerName: txData['customer_name'],
      notes: txData['notes'],
      cashierName: txData['cashier_name'] ?? 'Kasir',
    );
  }

  /// Batalkan transaksi (void)
  static Future<void> voidTransaction(String id) async {
    await client.from('transactions').update({'status': 'voided'}).eq('id', id);
  }
}
