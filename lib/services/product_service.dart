import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chilehalal_mobile/config.dart';
import 'auth_service.dart';

class ProductPaginationResponse {
  final List<dynamic> products;
  final int totalPages;
  final int currentPage;

  ProductPaginationResponse({
    required this.products,
    required this.totalPages,
    required this.currentPage,
  });
}

class ProductService {
  final AuthService _authService = AuthService();

  // --- OBTENER LISTADO DE PRODUCTOS ---
  Future<ProductPaginationResponse> getProducts({int page = 1, String search = ''}) async {
    final uri = Uri.parse('${AppConfig.apiUrl}/products').replace(queryParameters: {
      'page': page.toString(),
      'search': search,
    });

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return ProductPaginationResponse(
            products: body['data'] ?? [],
            totalPages: body['pagination']['total_pages'] ?? 1,
            currentPage: body['pagination']['current_page'] ?? 1,
          );
        }
      }
      return ProductPaginationResponse(products: [], totalPages: 1, currentPage: 1);
    } catch (e) {
      print("Error fetching products: $e");
      return ProductPaginationResponse(products: [], totalPages: 1, currentPage: 1);
    }
  }

  // --- ESCANEAR PRODUCTO ---
  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final url = Uri.parse('${AppConfig.apiUrl}/scan/$barcode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body['data'];
        }
      }
      return null;
    } catch (e) {
      print("Error scanning product: $e");
      return null;
    }
  }

  // --- CREAR PRODUCTO ---
  // Retorna un Map con {success: bool, message: String}
  Future<Map<String, dynamic>> createProduct({
    required String name,
    required String brand,
    required String barcode,
    required String isHalal, // 'yes', 'no', 'doubt'
    List<String>? categories,
  }) async {
    
    // Obtenemos el token guardado
    final token = await _authService.getToken();
    if (token == null) {
      return {'success': false, 'message': 'Sesión expirada. Ingresa nuevamente.'};
    }

    final url = Uri.parse('${AppConfig.apiUrl}/products');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'brand': brand,
          'barcode': barcode,
          'is_halal': isHalal,
          'categories': categories ?? [],
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 201 && body['success'] == true) {
        return {'success': true, 'message': body['message']};
      } else if (response.statusCode == 403) {
        return {'success': false, 'message': 'No tienes permiso para usar esta marca.'};
      } else {
        return {'success': false, 'message': body['message'] ?? 'Error al guardar.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }
}