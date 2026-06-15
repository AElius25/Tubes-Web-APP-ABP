import 'package:flutter/foundation.dart';
import '../models/book.dart';

class BooksProvider extends ChangeNotifier {
  List<Book> _books = List.from(sampleBooks);
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  List<Book> get books => _filteredBooks;
  List<Book> get allBooks => _books;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<Book> get _filteredBooks {
    var result = _books.where((book) {
      final matchesSearch = _searchQuery.isEmpty ||
          book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.isbn.contains(_searchQuery);

      final matchesCategory =
          _selectedCategory == 'Semua' || book.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
    return result;
  }

  // Dashboard stats
  int get totalBooks => _books.length;
  int get lowStockCount => _books.where((b) => b.stock <= 5).length;
  int get outOfStockCount => _books.where((b) => b.stock == 0).length;
  double get totalInventoryValue =>
      _books.fold(0.0, (sum, b) => sum + (b.price * b.stock));

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void addBook(Book book) {
    _books.add(book);
    notifyListeners();
  }

  void updateBook(Book book) {
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _books[index] = book;
      notifyListeners();
    }
  }

  void deleteBook(String id) {
    _books.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  void decreaseStock(String id, int quantity) {
    final index = _books.indexWhere((b) => b.id == id);
    if (index != -1) {
      final book = _books[index];
      _books[index] = book.copyWith(stock: (book.stock - quantity).clamp(0, book.stock));
      notifyListeners();
    }
  }

  Book? findById(String id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }
}
