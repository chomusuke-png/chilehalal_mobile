import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chilehalal_mobile/config.dart';

class CouponService {
  static final CouponService _instance = CouponService._internal();
  factory CouponService() => _instance;
  CouponService._internal();

  Future<Map<String, dynamic>> getCoupons({
    int? businessId, 
    bool onlyActive = true,
  }) async {
    try {
      final queryParams = {
        'active': onlyActive.toString(),
      };
      
      if (businessId != null) {
        queryParams['business_id'] = businessId.toString();
      }

      final uri = Uri.parse('${AppConfig.apiUrl}/coupons').replace(queryParameters: queryParams);
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Error del servidor: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de red.'};
    }
  }
}