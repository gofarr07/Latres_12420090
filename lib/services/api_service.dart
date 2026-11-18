import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article.dart';

class ApiService {
  static const String baseUrl =
      'https://api.spaceflightnewsapi.net/v4';

  static Future<List<Article>> fetchArticles(
    String category,
  ) async {
    final url = Uri.parse('$baseUrl/$category/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body);

      final List results = data['results'] ?? [];

      return results
          .map(
            (item) => Article.fromJson(
              Map<String, dynamic>.from(item),
              category,
            ),
          )
          .toList();
    } else {
      throw Exception(
        'Gagal mengambil data. Kode: ${response.statusCode}',
      );
    }
  }

  static Future<Article> fetchArticleDetail(
    String category,
    int id,
  ) async {
    final url = Uri.parse('$baseUrl/$category/$id/');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          jsonDecode(response.body);

      return Article.fromJson(data, category);
    } else {
      throw Exception(
        'Gagal mengambil detail berita. Kode: ${response.statusCode}',
      );
    }
  }
}
