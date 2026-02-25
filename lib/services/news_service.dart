import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  static List<Map<String, dynamic>>? _cachedNews;

  Future<List<Map<String, dynamic>>> getLatestNews() async {
    if (_cachedNews != null && _cachedNews!.isNotEmpty) {
      return _cachedNews!;
    }

    final url = Uri.parse('https://www.halalflash.com/wp-json/wp/v2/posts?per_page=3&_embed');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        
        _cachedNews = data.map((post) {
          String? imageUrl;
          
          if (post['_embedded'] != null && post['_embedded']['wp:featuredmedia'] != null) {
             imageUrl = post['_embedded']['wp:featuredmedia'][0]['source_url'];
          }
          
          return {
            'title': post['title']['rendered'],
            'link': post['link'],
            'image_url': imageUrl,
          };
        }).toList();
        
        return _cachedNews!;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}