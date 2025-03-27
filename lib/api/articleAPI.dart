import 'package:dio/dio.dart';
import '../utils/mydio.dart';

class ArticleService {
  Future<Map<String, dynamic>> getArticleList(int userId) async {
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
