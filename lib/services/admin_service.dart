import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chilehalal_mobile/config.dart';
import 'package:chilehalal_mobile/services/auth_service.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  Future<Map<String, dynamic>> sendGlobalNotification(String title, String message) async {
    final token = await AuthService().getToken();
    if (token == null) return {'success': false, 'message': 'Sesión expirada o no válida.'};

    final url = Uri.parse('${AppConfig.apiUrl}/admin/notifications/broadcast');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'title': title,
          'message': message,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        return {
          'success': true, 
          'message': responseBody['message'] ?? 'Notificación enviada exitosamente a todos los usuarios.'
        };
      } else {
        return {
          'success': false, 
          'message': responseBody['message'] ?? 'Error al procesar la solicitud en el servidor.'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión. Verifica tu acceso a internet.'};
    }
  }
}