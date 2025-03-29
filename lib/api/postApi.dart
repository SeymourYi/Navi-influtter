import 'package:dio/dio.dart';
import '../utils/mydio.dart';
import 'dart:io';

class PostService {
  // 发布普通文章
  Future<Map<String, dynamic>> postArticle({
    required String content,
    required int userId,
    required String username,
    required int categoryId,
    File? imageFile,
  }) async {
    try {
      // 创建FormData对象
      Map<String, dynamic> formMap = {
        'content': content,
        'createUserId': userId,
        'categoryId': categoryId,
        'username': username,
      };

      // 如果有图片文件，添加到表单数据中
      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        formMap['file'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        );
      }

      FormData formData = FormData.fromMap(formMap);

      // 发送请求
      var response = await HttpClient.dio.post("/article", data: formData);
      return response.data;
    } catch (e) {
      throw Exception('发布文章失败: $e');
    }
  }

  // 转发/分享文章
  Future<Map<String, dynamic>> postShareArticle({
    required String content,
    required int userId,
    required String username,
    required int categoryId,
    required int originalArticleId,
  }) async {
    try {
      // 创建FormData对象
      FormData formData = FormData.fromMap({
        'content': content,
        'createUserId': userId,
        'categoryId': categoryId,
        'username': username,
        'BeSharearticleID': originalArticleId,
        'createUserName': username,
      });

      // 发送请求
      var response = await HttpClient.dio.post(
        "/article/addReapetArticle",
        data: formData,
      );
      return response.data;
    } catch (e) {
      throw Exception('转发文章失败: $e');
    }
  }

  // 评论文章
  Future<Map<String, dynamic>> postComment({
    required String content,
    required int userId,
    required String username,
    required int articleId,
  }) async {
    try {
      // 创建FormData对象
      FormData formData = FormData.fromMap({
        'content': content,
        'createUserId': userId,
        'articleId': articleId,
        'username': username,
        'categoryId': 1,
      });

      // 发送请求
      var response = await HttpClient.dio.post("/article", data: formData);
      return response.data;
    } catch (e) {
      throw Exception('评论文章失败: $e');
    }
  }
}
