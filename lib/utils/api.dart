import 'package:http/http.dart' as http;
import 'dart:convert';

class Api {
  static Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('https://opentdb.com/api_category.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['trivia_categories'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      // Return empty on error - callers should handle empty lists
      return [];
    }
  }

  static Future<List<dynamic>> fetchQuestions({
    required int amount,
    required int categoryId,
    required String difficulty,
    required String type,
  }) async {
    try {
      final url = 'https://opentdb.com/api.php?amount=$amount&category=$categoryId&difficulty=$difficulty&type=$type';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['results'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

