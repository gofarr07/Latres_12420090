class Article {
  final int id;
  final String title;
  final String imageUrl;
  final List<String> authors;
  final String summary;
  final String url;
  final String publishedAt;
  final String category;

  Article({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.authors,
    required this.summary,
    required this.url,
    required this.publishedAt,
    required this.category,
  });

  factory Article.fromJson(
    Map<String, dynamic> json,
    String category,
  ) {
    final authorData = json['authors'] as List? ?? [];

    final authorNames = authorData.map((author) {
      if (author is Map) {
        return author['name']?.toString() ?? '';
      }
      return '';
    }).where((name) => name.isNotEmpty).toList();

    return Article(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Tanpa Judul',
      imageUrl: json['image_url'] ?? '',
      authors: authorNames,
      summary: json['summary'] ?? 'Tidak ada ringkasan.',
      url: json['url'] ?? '',
      publishedAt: json['published_at'] ?? '',
      category: category,
    );
  }

  String get authorName {
    if (authors.isEmpty) {
      return 'Unknown Author';
    }
    return authors.join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'authors': authors.map((name) => {'name': name}).toList(),
      'summary': summary,
      'url': url,
      'published_at': publishedAt,
      'category': category,
    };
  }

  factory Article.fromStorage(Map<String, dynamic> json) {
    return Article.fromJson(
      json,
      json['category'] ?? 'articles',
    );
  }
}
