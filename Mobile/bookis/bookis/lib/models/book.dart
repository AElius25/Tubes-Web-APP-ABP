class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String category;
  final double price;
  int stock;
  final String? coverUrl;
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
    this.coverUrl,
    required this.publisher,
    required this.year,
  });

  bool get isLowStock => stock <= 5 && stock > 0;
  bool get isOutOfStock => stock == 0;

  Book copyWith({
    String? id, String? title, String? author, String? isbn,
    String? category, double? price, int? stock, String? coverUrl,
    String? publisher, int? year,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      coverUrl: coverUrl ?? this.coverUrl,
      publisher: publisher ?? this.publisher,
      year: year ?? this.year,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'author': author, 'isbn': isbn,
    'category': category, 'price': price, 'stock': stock,
    'coverUrl': coverUrl, 'publisher': publisher, 'year': year,
  };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'], title: json['title'], author: json['author'],
    isbn: json['isbn'], category: json['category'],
    price: (json['price'] as num).toDouble(),
    stock: json['stock'], coverUrl: json['coverUrl'],
    publisher: json['publisher'], year: json['year'],
  );
}
