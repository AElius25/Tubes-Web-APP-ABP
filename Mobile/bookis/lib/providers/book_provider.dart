import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/supabase_service.dart';

class BookProvider extends ChangeNotifier {
  List<Book> _books = [];
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  bool _loading = false;
  String? _error;

  List<Book> get books => _filteredBooks;
  List<Book> get allBooks => _books;
  bool get isLoading => _loading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;

  List<String> get categories {
    final cats = _books.map((b) => b.category).toSet().toList()..sort();
    return ['Semua', ...cats];
  }

  List<Book> get _filteredBooks {
    var list = _books;
    if (_selectedCategory != 'Semua') {
      list = list.where((b) => b.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((b) =>
              b.title.toLowerCase().contains(q) ||
              b.author.toLowerCase().contains(q) ||
              b.isbn.contains(q))
          .toList();
    }
    return list;
  }

  List<Book> get lowStockBooks =>
      _books.where((b) => b.isLowStock || b.isOutOfStock).toList();

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setCategory(String cat) {
    _selectedCategory = cat;
    notifyListeners();
  }

  // ─── Supabase Operations ────────────────────────────────────────────────────

  /// Load semua buku dari Supabase saat app buka
  Future<void> loadBooks() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _books = await SupabaseService.fetchBooks();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Tambah buku baru → simpan ke Supabase → update list lokal
  Future<void> addBook(Book book) async {
    try {
      final saved = await SupabaseService.insertBook(book);
      _books.add(saved);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Edit buku → update Supabase → update list lokal
  Future<void> updateBook(Book updated) async {
    try {
      await SupabaseService.updateBook(updated);
      final idx = _books.indexWhere((b) => b.id == updated.id);
      if (idx != -1) {
        _books[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Hapus buku → hapus dari Supabase → hapus dari list lokal
  Future<void> deleteBook(String id) async {
    try {
      await SupabaseService.deleteBook(id);
      _books.removeWhere((b) => b.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Kurangi stok lewat Supabase stored procedure
  Future<void> decreaseStock(String id, int qty) async {
    try {
      await SupabaseService.decreaseStock(id, qty);
      // Update juga di RAM agar UI langsung berubah tanpa fetch ulang
      final idx = _books.indexWhere((b) => b.id == id);
      if (idx != -1) {
        _books[idx].stock -= qty;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Book? findById(String id) => _books.where((b) => b.id == id).isNotEmpty
      ? _books.firstWhere((b) => b.id == id)
      : null;
}
