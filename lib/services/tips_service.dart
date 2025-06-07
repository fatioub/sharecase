import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tip.dart';

class TipsService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  static Future<List<ModTip>> fetchTips() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts?_limit=10'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ModTip.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tips: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // In a real app, you might have additional methods like:
  // static Future<ModTip> fetchTipById(int id) async { ... }
  // static Future<List<ModTip>> fetchTipsByCategory(String category) async { ... }
}
