import 'package:dio/dio.dart';
import '../utils/mydio.dart';
import '../api/emailAPI.dart';

class ArticleService {
  Future<Map<String, dynamic>> getallArticleList(int userId) async {
    try {
      var response = await HttpClient.dio.get(
        "/article/AllArticleList?userid=${userId}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }

  Future<Map<String, dynamic>> getsomebodyArticleList(String username) async {
    try {
      var response = await HttpClient.dio.get("/article?username=${username}");
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }

  Future<Map<String, dynamic>> getfriendArticleList(int userId) async {
    try {
      var response = await HttpClient.dio.get(
        "/article/homeArticlelist?userid=${userId}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }

  Future<Map<String, dynamic>> getArticleComments(int articleId) async {
    try {
      var response = await HttpClient.dio.get(
        "/article/getArticleComments?articleId=${articleId}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }

  Future<Map<String, dynamic>> getArticleDetail(String articleId) async {
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
