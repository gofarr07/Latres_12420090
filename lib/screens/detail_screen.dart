import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../models/article.dart';
import '../services/api_service.dart';
import '../utils/preferences.dart';

class DetailScreen extends StatefulWidget {
  final Article article;

  const DetailScreen({
    super.key,
    required this.article,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Article> futureDetail;

  bool isFavorite = false;
  bool isCheckingFavorite = true;

  @override
  void initState() {
    super.initState();
    futureDetail = loadDetail();
    checkFavorite();
  }

  Future<Article> loadDetail() async {
    try {
      return await ApiService.fetchArticleDetail(
        widget.article.category,
        widget.article.id,
      );
    } catch (_) {
      return widget.article;
    }
  }

  Future<void> checkFavorite() async {
    final result = await Preferences.isFavorite(widget.article);

    if (!mounted) return;

    setState(() {
      isFavorite = result;
      isCheckingFavorite = false;
    });
  }

  Future<void> toggleFavorite() async {
    await Preferences.toggleFavorite(widget.article);

    if (!mounted) return;

    setState(() {
      isFavorite = !isFavorite;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? 'Ditambahkan ke Favorite'
              : 'Dihapus dari Favorite',
        ),
      ),
    );
  }

  Future<void> openOriginalArticle(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link artikel tidak tersedia'),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);

    if (uri == null) return;

    final success = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka artikel'),
        ),
      );
    }
  }

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd MMMM yyyy').format(parsedDate);
    } catch (_) {
      return 'Tanggal tidak tersedia';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        actions: [
          IconButton(
            onPressed: isCheckingFavorite ? null : toggleFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            tooltip: 'Favorite',
          ),
        ],
      ),
      body: FutureBuilder<Article>(
        future: futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final article = snapshot.data ?? widget.article;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(
                  imageUrl: article.imageUrl,
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 240,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 240,
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 60,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 18,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(article.authorName),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(formatDate(article.publishedAt)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Ringkasan Berita',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        article.summary,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            openOriginalArticle(article.url);
                          },
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Buka Artikel Asli'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
