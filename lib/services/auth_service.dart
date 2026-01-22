import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chilehalal_mobile/config.dart'; 

class AuthService {
  static const String _tokenKey = 'ch_auth_token';
  static const String _userKey = 'ch_user_data';

  // --- LOGIN ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${AppConfig.apiUrl}/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        await _saveSession(body['data']['token'], body['data']);
        return {'success': true, 'data': body['data']};
      } else {
        return {
          'success': false, 
          'message': body['message'] ?? 'Error desconocido'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión. Revisa tu internet.'};
    }
  }

  // --- REGISTER ---
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final url = Uri.parse('${AppConfig.apiUrl}/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final body = jsonDecode(response.body);

      // El backend devuelve 201 Created si todo sale bien
      if (response.statusCode == 201 && body['success'] == true) {
        return {'success': true, 'message': body['message']};
      } else {
        return {
          'success': false, 
          'message': body['message'] ?? 'Error al registrar'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // --- MOSTRAR PERFIL ---
  Future<Map<String, dynamic>?> getUserProfile() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse('${AppConfig.apiUrl}/user/me');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data']; 
      } else {
        if (response.statusCode == 401) await logout();
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // --- Helpers Críticos para Roles y UI ---

  Future<String?> getRole() async {
    final user = await getLocalUser();
    return user?['role'];
  }

  // --- Gestión de Sesión Local ---

  Future<void> _saveSession(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  // Recuperar datos del usuario guardado localmente
  Future<Map<String, dynamic>?> getLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}