import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductService {
  // URL Base (Misma que AuthService)
  static const String baseUrl = 'https://www.chilehalal.cl/wp-json/chilehalal/v1';

  Future<List<dynamic>> getProducts() async {
    final url = Uri.parse('$baseUrl/products');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body['data'];
        }
      }
      return [];
    } catch (e) {
      print("Error fetching products: $e");
      return [];
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