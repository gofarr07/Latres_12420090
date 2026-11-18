import 'package:flutter/material.dart';

import '../models/article.dart';
import '../utils/preferences.dart';
import '../widgets/article_card.dart';
import 'detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<Article>> futureFavorites;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  void loadFavorites() {
    futureFavorites = Preferences.getFavorites();
  }

  Future<void> refreshFavorites() async {
    setState(() {
      loadFavorites();
    });

    await futureFavorites;
  }

  void openDetail(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(article: article),
      ),
    ).then((_) {
      if (mounted) {
        refreshFavorites();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Article>>(
        future: futureFavorites,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            );
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text('Belum ada berita favorit'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: refreshFavorites,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final article = favorites[index];

                return ArticleCard(
                  article: article,
                  onTap: () => openDetail(article),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
