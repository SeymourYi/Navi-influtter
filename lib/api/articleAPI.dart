import 'package:Navi/api/getarticleinfoAPI.dart';
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

  Future<Map<String, dynamic>> getArticlelikers(String articleId) async {
    try {
      var response = await HttpClient.dio.get(
        "/article/articleInfo/likers?articleid=${articleId}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }

  // 点赞某个文章
  Future<Map<String, dynamic>> likeArticle({
    required String username,
    required int articleId,
  }) async {
    try {
      var response = await HttpClient.dio.post(
        "/article/likeSomeArticle?username=${username}&articleid=${articleId}",
      );
      return response.data;
    } catch (e) {
      throw Exception('点赞文章失败: $e');
    }
  }

  // 删除文章
  Future<Map<String, dynamic>> deleteArticle(int articleId) async {
    try {
      var response = await HttpClient.dio.get(
        "/article/deletArticle?articleId=${articleId}",
      );
      return response.data;
    } catch (e) {
      throw Exception('删除文章失败: $e');
    }
  }

  // 搜索文章
  /// [keyword] 搜索关键词
  Future<Map<String, dynamic>> searchArticles({
    required String keyword,
  }) async {
    try {
      var response = await HttpClient.dio.get(
        "/article/search",
        queryParameters: {
          'keyword': keyword,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('搜索文章失败: $e');
    }
  }
}
