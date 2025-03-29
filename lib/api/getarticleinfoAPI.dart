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
}
