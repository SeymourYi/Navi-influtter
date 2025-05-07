import 'package:Navi/api/emailAPI.dart';
import 'package:dio/dio.dart';
import '../utils/mydio.dart';
import 'dart:io';

class PostService {
  final EmailService emailService = EmailService();
  // 发布普通文章
  Future<Map<String, dynamic>> postArticle({
    required String content,
    required int userId,
    required String username,
    required int categoryId,
    File? imageFile,
    List<File>? imageFiles,
  }) async {
    try {
      // 创建FormData对象
      Map<String, dynamic> formMap = {
        'content': content,
        'createUserId': userId,
        'categoryId': categoryId,
        'username': username,
      };

      // 处理单张图片
      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        formMap['file'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        );
      }

      // 处理多张图片
      if (imageFiles != null && imageFiles.isNotEmpty) {
        // 如果只有一张图片，则使用单文件上传方式
        if (imageFiles.length == 1) {
          String fileName = imageFiles[0].path.split('/').last;
          formMap['file'] = await MultipartFile.fromFile(
            imageFiles[0].path,
            filename: fileName,
          );
        } else {
          // 多张图片使用数组上传
          List<MultipartFile> multipartFiles = [];
          for (int i = 0; i < imageFiles.length; i++) {
            String fileName = imageFiles[i].path.split('/').last;
            multipartFiles.add(
              await MultipartFile.fromFile(
                imageFiles[i].path,
                filename: fileName,
              ),
            );
          }
          formMap['file'] = multipartFiles;
        }
      }

      FormData formData = FormData.fromMap(formMap);

      // 发送请求
      var response = await HttpClient.dio.post("/article", data: formData);
      print("00000000000000000000000000");
      print(formData);
      print("11111111111111111111111111111");
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
    File? imageFile,
    List<File>? imageFiles,
  }) async {
    try {
      // 创建FormData对象
      Map<String, dynamic> formMap = {
        'content': content,
        'createUserId': userId,
        'categoryId': categoryId,
        'username': username,
        'BeSharearticleID': originalArticleId.toString(),
        'createUserName': username,
      };

      // 处理单张图片
      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        formMap['file'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        );
      }

      // 处理多张图片
      if (imageFiles != null && imageFiles.isNotEmpty) {
        // 如果只有一张图片，则使用单文件上传方式
        if (imageFiles.length == 1) {
          String fileName = imageFiles[0].path.split('/').last;
          formMap['file'] = await MultipartFile.fromFile(
            imageFiles[0].path,
            filename: fileName,
          );
        } else {
          // 多张图片使用数组上传
          List<MultipartFile> multipartFiles = [];
          for (int i = 0; i < imageFiles.length; i++) {
            String fileName = imageFiles[i].path.split('/').last;
            multipartFiles.add(
              await MultipartFile.fromFile(
                imageFiles[i].path,
                filename: fileName,
              ),
            );
          }
          formMap['files'] = multipartFiles;
        }
      }

      FormData formData = FormData.fromMap(formMap);

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
    required int categoryId,
    required int becommentarticleId,
    File? imageFile,
    List<File>? imageFiles,
  }) async {
    try {
      // 创建FormData对象
      Map<String, dynamic> formMap = {
        'content': content,
        'createUserId': userId,
        'articleId': articleId,
        'username': username,
        'categoryId': categoryId,
        'becomment_articleID': becommentarticleId,
        'createUserName': username,
      };

      // 处理单张图片
      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        formMap['file'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        );
      }

      // 处理多张图片
      if (imageFiles != null && imageFiles.isNotEmpty) {
        // 如果只有一张图片，则使用单文件上传方式
        if (imageFiles.length == 1) {
          String fileName = imageFiles[0].path.split('/').last;
          formMap['file'] = await MultipartFile.fromFile(
            imageFiles[0].path,
            filename: fileName,
          );
        } else {
          // 多张图片使用数组上传
          List<MultipartFile> multipartFiles = [];
          for (int i = 0; i < imageFiles.length; i++) {
            String fileName = imageFiles[i].path.split('/').last;
            multipartFiles.add(
              await MultipartFile.fromFile(
                imageFiles[i].path,
                filename: fileName,
              ),
            );
          }
          formMap['files'] = multipartFiles;
        }
      }

      FormData formData = FormData.fromMap(formMap);

      // 发送请求
      var response = await HttpClient.dio.post(
        "/article/replayArticle",
        data: formData,
      );
      return response.data;
    } catch (e) {
      throw Exception('评论文章失败: $e');
    }
  }
}
