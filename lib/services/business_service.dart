import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chilehalal_mobile/config.dart';

class BusinessService {
  static final BusinessService _instance = BusinessService._internal();
  factory BusinessService() => _instance;
  BusinessService._internal();

  Future<Map<String, dynamic>> getBusinesses({
    int page = 1,
    String? search,
    String? type,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
      };
      
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }
      if (type != null && type.trim().isNotEmpty) {
        queryParams['type'] = type.trim();
      }

      final uri = Uri.parse('${AppConfig.apiUrl}/businesses').replace(queryParameters: queryParams);
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false, 
          'message': 'Error del servidor: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {
        'success': false, 
        'message': 'Error de conexión: Verifica tu internet.'
      };
    }
  }

  Future<Map<String, dynamic>?> getBusinessDetails(int id) async {
    try {
      final uri = Uri.parse('${AppConfig.apiUrl}/businesses/$id');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['success'] == true) {
          return decoded['data']; 
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}