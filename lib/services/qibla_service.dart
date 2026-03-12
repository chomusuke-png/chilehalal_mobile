import 'dart:convert';
import 'package:http/http.dart' as http;

class QiblaService {
  static final QiblaService _instance = QiblaService._internal();
  factory QiblaService() => _instance;
  QiblaService._internal();

  Future<double?> getQiblaDirection(double latitude, double longitude) async {
    try {
      final uri = Uri.parse('https://api.aladhan.com/v1/qibla/$latitude/$longitude');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          return data['data']['direction']?.toDouble();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}