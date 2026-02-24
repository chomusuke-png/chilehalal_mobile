import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:chilehalal_mobile/config.dart';
import 'auth_service.dart';

class FavoriteService extends ChangeNotifier {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  final AuthService _authService = AuthService();

  Future<List<Map<String, dynamic>>?> getFavorites() async {
    final token = await _authService.getToken();
    if (token == null) return null;

    final url = Uri.parse('${AppConfig.apiUrl}/favorites');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return List<Map<String, dynamic>>.from(body['data'] ?? []);
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> checkIsFavorite(int productId) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final url = Uri.parse('${AppConfig.apiUrl}/favorites/check/$productId');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['is_favorite'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleFavorite(int productId) async {
    final token = await _authService.getToken();
    if (token == null) return false;

    final url = Uri.parse('${AppConfig.apiUrl}/favorites/toggle');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'product_id': productId}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        
        notifyListeners(); 
        
        return body['is_favorite'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}