import 'package:dio/dio.dart';
import '../utils/mydio.dart';
import '../Store/storeutils.dart';

class UserService {
  Future<Map<String, dynamic>> getUserinfo() async {
    try {
      var response = await HttpClient.dio.get("/user/userinfo");
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }

  Future<Map<String, dynamic>> whetherfriend(String myId, String userid) async {
    try {
      var response = await HttpClient.dio.post(
        "/user/whetherfriend?username=${myId}&friendname=${userid}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }

  Future<Map<String, dynamic>> getsomeUserinfo(String username) async {
    try {
      var response = await HttpClient.dio.get(
        "/user/someoneinfo?username=${username}",
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }

  // 刷新和更新本地存储的用户信息
  Future<bool> refreshUserInfo() async {
    try {
      var response = await HttpClient.dio.get("/user/userinfo");
      if (response.data != null && response.data['data'] != null) {
        await SharedPrefsUtils.saveUserInfo(response.data['data']);
        return true;
      }
      return false;
    } catch (e) {
      print('刷新用户信息失败: $e');
      return false;
    }
  }

  // 更新用户信息的方法
  Future<Map<String, dynamic>> updateUserInfo({
    required int id,
    required String username,
    required String nickname,
    String? profession,
    String? bio,
    String? location,
    MultipartFile? userPicFile,
    MultipartFile? bgImgFile,
  }) async {
    try {
      // 创建FormData对象
      FormData formData = FormData.fromMap({
        'id': id,
        'username': username,
        'nickname': nickname,
        'profession': profession ?? '',
        'bio': bio ?? '',
        'location': location ?? '',
        // 添加默认的分类名称
        'categoryName1': '默认分类1',
        'categoryName2': '默认分类2',
        'categoryName3': '默认分类3',
        'phoneNumber': '',
      });

      // 如果有头像文件，添加到表单
      if (userPicFile != null) {
        formData.files.add(MapEntry('file1', userPicFile));
      }

      // 如果有背景图文件，添加到表单
      if (bgImgFile != null) {
        formData.files.add(MapEntry('file2', bgImgFile));
      }

      // 发送更新请求
      var response = await HttpClient.dio.post(
        "/user/updateUser",
        data: formData,
      );

      return response.data;
    } catch (e) {
      throw Exception('更新用户信息失败: $e');
    }
  }
}
