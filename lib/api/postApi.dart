import 'package:dio/dio.dart';
import '../utils/mydio.dart';

class PostService {
  Future<Map<String, dynamic>> PostArticle(int userId) async {
    try {
      var response = await HttpClient.dio.get(
        "/article/AllArticleList?userid=${userId}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }
}
