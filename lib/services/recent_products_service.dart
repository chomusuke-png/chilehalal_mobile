import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RecentProductsService {
  static const String _storageKey = 'ch_recent_products';
  static const int _maxItems = 10;

  Future<void> addProductToRecents(Map<String, dynamic> product) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentList = prefs.getStringList(_storageKey) ?? [];

    currentList.removeWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == product['id'] || decoded['barcode'] == product['barcode'];
    });

    currentList.insert(0, jsonEncode(product));

    if (currentList.length > _maxItems) {
      currentList.removeLast();
    }

    await prefs.setStringList(_storageKey, currentList);
  }

  Future<List<Map<String, dynamic>>> getRecentProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_storageKey) ?? [];
    return list.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
  }
}