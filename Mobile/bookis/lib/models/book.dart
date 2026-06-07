class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String category;
  final double price;
  int stock;
  final String? coverPath; // path file lokal (image_picker)
  final String? coverUrl;  // URL jaringan (fallback)
  final String publisher;
  final int year;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.category,
    required this.price,
    required this.stock,
    this.coverPath,
    this.coverUrl,
    required this.publisher,
    required this.year,
  });

  bool get isLowStock => stock <= 5 && stock > 0;
  bool get isOutOfStock => stock == 0;
  bool get hasCover =>
      (coverPath != null && coverPath!.isNotEmpty) ||
      (coverUrl != null && coverUrl!.isNotEmpty);

  Book copyWith({
    String? id, String? title, String? author, String? isbn,
    String? category, double? price, int? stock,
    String? coverPath, String? coverUrl,
    String? publisher, int? year,
  }) => Book(
    id: id ?? this.id, title: title ?? this.title,
    author: author ?? this.author, isbn: isbn ?? this.isbn,
    category: category ?? this.category, price: price ?? this.price,
    stock: stock ?? this.stock, coverPath: coverPath ?? this.coverPath,
    coverUrl: coverUrl ?? this.coverUrl, publisher: publisher ?? this.publisher,
    year: year ?? this.year,
  );

  /// Untuk kirim ke Supabase — kolom snake_case
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'isbn': isbn,
    'category': category,
    'price': price,
    'stock': stock,
    'cover_path': coverPath,
    'cover_url': coverUrl,
    'publisher': publisher,
    'year': year,
  };

  /// Dari response Supabase — kolom snake_case
  factory Book.fromJson(Map<String, dynamic> j) => Book(
    id: j['id'].toString(),
    title: j['title'] ?? '',
    author: j['author'] ?? '',
    isbn: j['isbn'] ?? '',
    category: j['category'] ?? '',
    price: (j['price'] as num).toDouble(),
    stock: j['stock'] ?? 0,
    coverPath: j['cover_path'],
    coverUrl: j['cover_url'],
    publisher: j['publisher'] ?? '',
    year: j['year'] ?? DateTime.now().year,
  );
}
