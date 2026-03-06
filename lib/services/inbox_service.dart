import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InboxService {
  static final InboxService _instance = InboxService._internal();
  factory InboxService() => _instance;
  InboxService._internal();

  static const String _key = 'ch_app_inbox';

  Future<List<Map<String, dynamic>>> getMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  Future<void> addMessage(String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    
    final msg = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'date': DateTime.now().toIso8601String(),
      'isRead': false,
    };
    
    list.insert(0, jsonEncode(msg));
    await prefs.setStringList(_key, list);
  }

  Future<void> deleteMessage(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.removeWhere((e) {
      final decoded = jsonDecode(e);
      return decoded['id'] == id;
    });
    await prefs.setStringList(_key, list);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}