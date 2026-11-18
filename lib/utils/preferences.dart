import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';

class Preferences {
  static const String usersKey = 'users';
  static const String loginKey = 'isLoggedIn';
  static const String usernameKey = 'username';
  static const String favoritesKey = 'favorites';

  static Future<bool> register(
    String username,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final users = prefs.getString(usersKey);
    final Map<String, dynamic> userData =
        users == null ? {} : jsonDecode(users);

    if (userData.containsKey(username)) {
      return false;
    }

    userData[username] = password;

    await prefs.setString(usersKey, jsonEncode(userData));

    return true;
  }

  static Future<bool> login(
    String username,
    String password,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final users = prefs.getString(usersKey);

    if (users == null) {
      return false;
    }

    final Map<String, dynamic> userData = jsonDecode(users);

    if (userData[username] == password) {
      await prefs.setBool(loginKey, true);
      await prefs.setString(usernameKey, username);
      return true;
    }

    return false;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginKey) ?? false;
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(usernameKey) ?? 'User';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginKey, false);
    await prefs.remove(usernameKey);
  }

  static Future<List<Article>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(favoritesKey);

    if (data == null) {
      return [];
    }

    final List decoded = jsonDecode(data);

    return decoded
        .map(
          (item) => Article.fromStorage(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  static Future<void> toggleFavorite(Article article) async {
    final prefs = await SharedPreferences.getInstance();

    final favorites = await getFavorites();

    final index = favorites.indexWhere(
      (item) =>
          item.id == article.id &&
          item.category == article.category,
    );

    if (index >= 0) {
      favorites.removeAt(index);
    } else {
      favorites.add(article);
    }

    final data = favorites.map((item) => item.toJson()).toList();

    await prefs.setString(favoritesKey, jsonEncode(data));
  }

  static Future<bool> isFavorite(Article article) async {
    final favorites = await getFavorites();

    return favorites.any(
      (item) =>
          item.id == article.id &&
          item.category == article.category,
    );
  }
}
