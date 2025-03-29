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

  Future<Map<String, dynamic>> getArticlecomment(int articleId) async {
    try {
      var response = await HttpClient.dio.get(
        "/article/getArticleComments?articleId=${articleId}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }

  Future<Map<String, dynamic>> postArticlecomment(
    Map<String, dynamic> commentParams,
  ) async {
    try {
      FormData formData = FormData.fromMap({
        'content': commentParams['content'],
        'categoryId': commentParams['categoryId'],
        'createUserId': commentParams['createUserId'],
        'createUserName': commentParams['createUserName'],
        'becomment_articleID': commentParams['becomment_articleID'],
      });

      if (commentParams.containsKey('imagePath') &&
          commentParams['imagePath'] != null &&
          commentParams['imagePath'].isNotEmpty) {
        formData.files.add(
          MapEntry(
            'file',
            await MultipartFile.fromFile(
              commentParams['imagePath'],
              filename: 'image.jpg',
            ),
          ),
        );
      }

      var response = await HttpClient.dio.post(
        "/article/replayArticle",
        data: formData,
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to post comment: $e');
    }
  }

  Future<Map<String, dynamic>> likesomearticle(
    String username,
    String articleId,
  ) async {
    try {
      // 确保参数不为空
      if (username.isEmpty) {
        throw Exception('用户名不能为空');
      }
      if (articleId.isEmpty) {
        throw Exception('文章ID不能为空');
      }

      // 尝试将articleId转换为整数后再转回字符串，确保格式正确
      try {
        var articleIdInt = int.parse(articleId);
        articleId = articleIdInt.toString();
      } catch (e) {
        // 格式问题时继续使用原值，无需打印警告
      }

      // 尝试方法一：使用查询参数（推荐方法）
      try {
        var response = await HttpClient.dio.post(
          "/article/likeSomeArticle",
          queryParameters: {'username': username, 'articleid': articleId},
          options: Options(
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

        return response.data;
      } catch (queryError) {
        // 备选方法：使用FormData
        FormData formData = FormData.fromMap({
          'username': username,
          'articleid': articleId,
        });

        var response = await HttpClient.dio.post(
          "/article/likeSomeArticle",
          data: formData,
          options: Options(
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

        return response.data;
      }
    } catch (e) {
      throw Exception('点赞操作失败: $e');
    }
  }

  // 新增：引用帖子功能
  Future<Map<String, dynamic>> addReapetArticle({
    required String beShareArticleId, // 被引用的文章ID
    required String content, // 引用时添加的内容
    required int createUserId, // 创建用户ID
    required String createUserName, // 创建用户名
    String? categoryId, // 可选的分类ID
    String? imagePath, // 可选的图片路径
  }) async {
    try {
      // 验证必要参数
      if (beShareArticleId.isEmpty) {
        throw Exception('被引用文章ID不能为空');
      }
      if (content.isEmpty) {
        throw Exception('内容不能为空');
      }
      if (createUserId <= 0) {
        throw Exception('用户ID无效');
      }
      if (createUserName.isEmpty) {
        throw Exception('用户名不能为空');
      }

      // 创建表单数据
      FormData formData = FormData.fromMap({
        'BeSharearticleID': beShareArticleId,
        'content': content,
        'createUserId': createUserId,
        'createUserName': createUserName,
      });

      // 添加可选参数
      if (categoryId != null) {
        formData.fields.add(MapEntry('categoryId', categoryId));
      }

      // 如果有图片，添加到表单
      if (imagePath != null && imagePath.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'file',
            await MultipartFile.fromFile(imagePath, filename: 'image.jpg'),
          ),
        );
      }

      // 发送请求
      var response = await HttpClient.dio.post(
        "/article/addReapetArticle",
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      return response.data;
    } catch (e) {
      print('引用文章失败: $e');
      throw Exception('引用文章失败: $e');
    }
  }
}
