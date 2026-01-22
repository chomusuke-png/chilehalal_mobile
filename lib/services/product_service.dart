import 'dart:convert';
import 'package:http/http.dart' as http;

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
  // URL Base (Misma que AuthService)
  static const String baseUrl = 'https://www.chilehalal.cl/wp-json/chilehalal/v1';

  Future<ProductPaginationResponse> getProducts({int page = 1, String search = ''}) async {
    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: {
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
      // Si falla, devolvemos lista vacía
      return ProductPaginationResponse(products: [], totalPages: 1, currentPage: 1);
    } catch (e) {
      print("Error fetching products: $e");
      return ProductPaginationResponse(products: [], totalPages: 1, currentPage: 1);
    }
  }

  Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    final url = Uri.parse('$baseUrl/scan/$barcode');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body['data'];
        }
      }
      return null; // No encontrado o error
    } catch (e) {
      print("Error fetching product: $e");
      return null;
    }
  }
}