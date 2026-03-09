import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class InboxService {
  static final InboxService _instance = InboxService._internal();
  factory InboxService() => _instance;
  InboxService._internal();

  static const String _key = 'ch_app_inbox';
  SharedPreferences? _prefsCache;

  Future<SharedPreferences> get _prefs async {
    _prefsCache ??= await SharedPreferences.getInstance();
    return _prefsCache!;
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    try {
      final preferences = await _prefs;
      final list = preferences.getStringList(_key) ?? [];
      return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addMessage(String title, String body) async {
    try {
      final preferences = await _prefs;
      final list = preferences.getStringList(_key) ?? [];
      
      final messageData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'body': body,
        'date': DateTime.now().toIso8601String(),
        'isRead': false,
      };
      
      list.insert(0, jsonEncode(messageData));
      await preferences.setStringList(_key, list);
    } catch (e) {
      throw Exception('Failed to save message to inbox');
    }
  }

  Future<void> deleteMessage(String id) async {
    try {
      final preferences = await _prefs;
      final list = preferences.getStringList(_key) ?? [];
      
      list.removeWhere((e) {
        final decoded = jsonDecode(e);
        return decoded['id'] == id;
      });
      
      await preferences.setStringList(_key, list);
    } catch (e) {
      throw Exception('Failed to delete message from inbox');
    }
  }

  Future<void> clearAll() async {
    try {
      final preferences = await _prefs;
      await preferences.remove(_key);
    } catch (e) {
      throw Exception('Failed to clear inbox');
    }
  }
}