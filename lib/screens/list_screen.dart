import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/api_service.dart';
import '../widgets/article_card.dart';
import 'detail_screen.dart';

class ListScreen extends StatefulWidget {
  final String category;

  const ListScreen({
    super.key,
    required this.category,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Future<List<Article>> futureArticles;
  String selectedAuthor = '';

  @override
  void initState() {
    super.initState();
    futureArticles = ApiService.fetchArticles(widget.category);
  }

  String get pageTitle {
    switch (widget.category) {
      case 'articles':
        return 'Articles';
      case 'blogs':
        return 'Blogs';
      case 'reports':
        return 'Reports';
      default:
        return 'News';
    }
  }

  void refreshArticles() {
    setState(() {
      futureArticles = ApiService.fetchArticles(widget.category);
      selectedAuthor = '';
    });
  }

  void openDetail(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        actions: [
          IconButton(
            onPressed: refreshArticles,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<List<Article>>(
        future: futureArticles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Gagal mengambil berita:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: refreshArticles,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final articles = snapshot.data ?? [];

          if (articles.isEmpty) {
            return const Center(
              child: Text('Belum ada berita.'),
            );
          }

          final authors = articles
              .expand((article) => article.authors)
              .toSet()
              .toList()
            ..sort();

          final filteredArticles = selectedAuthor.isEmpty
              ? articles
              : articles
                  .where(
                    (article) =>
                        article.authors.contains(selectedAuthor),
                  )
                  .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButtonFormField<String>(
                  initialValue: selectedAuthor,
                  decoration: const InputDecoration(
                    labelText: 'Filter berdasarkan Author',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Semua Author'),
                    ),
                    ...authors.map(
                      (author) => DropdownMenuItem(
                        value: author,
                        child: Text(
                          author,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedAuthor = value ?? '';
                    });
                  },
                ),
              ),
              Expanded(
                child: filteredArticles.isEmpty
                    ? const Center(
                        child: Text('Berita tidak ditemukan.'),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          refreshArticles();
                          await futureArticles;
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredArticles.length,
                          itemBuilder: (context, index) {
                            final article = filteredArticles[index];

                            return ArticleCard(
                              article: article,
                              onTap: () => openDetail(article),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
