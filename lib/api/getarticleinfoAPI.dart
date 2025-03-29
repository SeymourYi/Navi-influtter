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
        print('文章ID转换警告: $e, 使用原始值');
      }

      print('点赞请求参数 - username: $username, articleid: $articleId');

      // 尝试方法一：直接使用查询参数 - 根据后端代码这是正确的方式
      try {
        var response = await HttpClient.dio.post(
          "/article/likeSomeArticle",
          queryParameters: {
            'username': username,
            'articleid': articleId, // 修改参数名为articleid
          },
          options: Options(
            // 增加更长的超时时间
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

        print('点赞响应(查询参数): ${response.data}');
        return response.data;
      } catch (queryError) {
        print('查询参数请求失败，尝试表单数据: $queryError');

        // 方法二：使用FormData
        FormData formData = FormData.fromMap({
          'username': username,
          'articleid': articleId, // 修改参数名为articleid
        });

        print('FormData: ${formData.fields}');

        var response = await HttpClient.dio.post(
          "/article/likeSomeArticle",
          data: formData,
          options: Options(
            // 增加更长的超时时间
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

        print('点赞响应(表单): ${response.data}');
        return response.data;
      }
    } catch (e) {
      // 详细记录错误
      print('点赞请求失败详情: $e');
      throw Exception('Failed to like article: $e');
    }
  }
}
