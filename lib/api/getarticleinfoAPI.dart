import 'package:dio/dio.dart';
import '../utils/mydio.dart';

class GetArticleInfoService {
  Future<Map<String, dynamic>> getArticleInfo(int articleId) async {
    try {
      var response = await HttpClient.dio.get(
        "/article/getArticle?articleId=${articleId}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }
}
