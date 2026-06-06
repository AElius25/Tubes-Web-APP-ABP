import 'package:flutter/foundation.dart';
import '../models/book.dart';

class BookProvider extends ChangeNotifier {
  List<Book> _books = [];
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  List<Book> get books => _filteredBooks;
  List<Book> get allBooks => _books;
  String get searchQuery => _searchQuery;
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
      list = list.where((b) =>
        b.title.toLowerCase().contains(q) ||
        b.author.toLowerCase().contains(q) ||
        b.isbn.contains(q)
      ).toList();
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

  void addBook(Book book) {
    _books.add(book);
    notifyListeners();
  }

  void updateBook(Book updated) {
    final idx = _books.indexWhere((b) => b.id == updated.id);
    if (idx != -1) {
      _books[idx] = updated;
      notifyListeners();
    }
  }

  void deleteBook(String id) {
    _books.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  void decreaseStock(String id, int qty) {
    final idx = _books.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _books[idx].stock -= qty;
      notifyListeners();
    }
  }

  Book? findById(String id) =>
      _books.where((b) => b.id == id).isNotEmpty
          ? _books.firstWhere((b) => b.id == id)
          : null;

  void loadDummyData() {
    _books = [
      Book(id: '1', title: 'Laskar Pelangi', author: 'Andrea Hirata',
          isbn: '9789793062792', category: 'Fiksi', price: 89000,
          stock: 15, publisher: 'Bentang Pustaka', year: 2005),
      Book(id: '2', title: 'Bumi Manusia', author: 'Pramoedya Ananta Toer',
          isbn: '9789799731234', category: 'Sosial', price: 112000,
          stock: 8, publisher: 'Lentera Dipantara', year: 1980),
      Book(id: '3', title: 'Atomic Habits', author: 'James Clear',
          isbn: '9781847941831', category: 'Produktivitas', price: 138000,
          stock: 20, publisher: 'Random House', year: 2018),
      Book(id: '4', title: 'Sapiens', author: 'Yuval Noah Harari',
          isbn: '9780062316110', category: 'Sejarah', price: 165000,
          stock: 5, publisher: 'Harper Collins', year: 2011),
      Book(id: '5', title: 'Filosofi Teras', author: 'Henry Manampiring',
          isbn: '9786020649221', category: 'Produktivitas', price: 98000,
          stock: 12, publisher: 'Kompas', year: 2018),
      Book(id: '6', title: 'Dilan 1990', author: 'Pidi Baiq',
          isbn: '9786021600375', category: 'Fiksi', price: 75000,
          stock: 3, publisher: 'Mizan', year: 2014),
      Book(id: '7', title: 'Rich Dad Poor Dad', author: 'Robert Kiyosaki',
          isbn: '9781612680194', category: 'Keuangan', price: 125000,
          stock: 18, publisher: 'Plata Publishing', year: 1997),
      Book(id: '8', title: 'The Psychology of Money', author: 'Morgan Housel',
          isbn: '9780857197689', category: 'Keuangan', price: 148000,
          stock: 0, publisher: 'Harriman House', year: 2020),
      Book(id: '9', title: 'Negeri 5 Menara', author: 'Ahmad Fuadi',
          isbn: '9786020301839', category: 'Fiksi', price: 85000,
          stock: 10, publisher: 'Gramedia', year: 2009),
      Book(id: '10', title: 'Sebuah Seni untuk Bersikap Bodo Amat',
          author: 'Mark Manson', isbn: '9786020385792',
          category: 'Produktivitas', price: 98000,
          stock: 25, publisher: 'Gramedia', year: 2016),
      Book(id: '11', title: 'Pulang', author: 'Tere Liye',
          isbn: '9786020323763', category: 'Fiksi', price: 79000,
          stock: 2, publisher: 'Republika', year: 2015),
      Book(id: '12', title: 'Zero to One', author: 'Peter Thiel',
          isbn: '9780804139021', category: 'Bisnis', price: 145000,
          stock: 7, publisher: 'Crown Business', year: 2014),
    ];
    notifyListeners();
  }
}
