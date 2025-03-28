import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsUtils {
  // 定义所有可能的存储键
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _nicknameKey = 'nickname';
  static const String _professionKey = 'profession';
  static const String _bioKey = 'bio';
  static const String _locationKey = 'location';
  static const String _userPicKey = 'user_pic';
  static const String _bgImgKey = 'bg_img';
  static const String _createTimeKey = 'create_time';
  static const String _updateTimeKey = 'update_time';
  static const String _phoneNumberKey = 'phone_number';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _isdeletKey = 'is_delet';

  // 存储任意字符串值
  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // 获取任意字符串值
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // 存储布尔值
  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // 获取布尔值
  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  // 存储整数
  static Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  // 获取整数
  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  // 存储双精度浮点数
  static Future<void> setDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  // 获取双精度浮点数
  static Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  // 清除指定键的值
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // 清除所有存储的数据
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // -------------------- Token 相关操作 --------------------
  static Future<void> saveToken(String token) async =>
      setString(_tokenKey, token);
  static Future<String?> getToken() async => getString(_tokenKey);
  static Future<void> clearToken() async => remove(_tokenKey);

  // -------------------- 用户信息相关操作 --------------------
  static Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setInt(_userIdKey, userInfo['id'] ?? 0),
      prefs.setString(_usernameKey, userInfo['username'] ?? ''),
      prefs.setString(_nicknameKey, userInfo['nickname'] ?? ''),
      prefs.setString(_professionKey, userInfo['profession'] ?? ''),
      prefs.setString(_bioKey, userInfo['bio'] ?? ''),
      prefs.setString(_locationKey, userInfo['location'] ?? ''),
      prefs.setString(_userPicKey, userInfo['userPic'] ?? ''),
      prefs.setString(_bgImgKey, userInfo['bgImg'] ?? ''),
      prefs.setString(_createTimeKey, userInfo['createTime'] ?? ''),
      prefs.setString(_updateTimeKey, userInfo['updateTime'] ?? ''),
      prefs.setString(_phoneNumberKey, userInfo['phoneNumber'] ?? ''),
      prefs.setBool(_isdeletKey, userInfo['isdelet'] ?? false),
      prefs.setBool(_isLoggedInKey, true),
    ]);
  }

  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);
    if (userId == null) return null;

    return {
      'id': userId,
      'username': prefs.getString(_usernameKey) ?? '',
      'nickname': prefs.getString(_nicknameKey) ?? '',
      'profession': prefs.getString(_professionKey) ?? '',
      'bio': prefs.getString(_bioKey) ?? '',
      'location': prefs.getString(_locationKey) ?? '',
      'userPic': prefs.getString(_userPicKey) ?? '',
      'bgImg': prefs.getString(_bgImgKey) ?? '',
      'createTime': prefs.getString(_createTimeKey) ?? '',
      'updateTime': prefs.getString(_updateTimeKey) ?? '',
      'phoneNumber': prefs.getString(_phoneNumberKey) ?? '',
      'isdelet': prefs.getBool(_isdeletKey) ?? false,
    };
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_userIdKey),
      prefs.remove(_usernameKey),
      prefs.remove(_nicknameKey),
      prefs.remove(_professionKey),
      prefs.remove(_bioKey),
      prefs.remove(_locationKey),
      prefs.remove(_userPicKey),
      prefs.remove(_bgImgKey),
      prefs.remove(_createTimeKey),
      prefs.remove(_updateTimeKey),
      prefs.remove(_phoneNumberKey),
      prefs.remove(_isdeletKey),
      prefs.remove(_isLoggedInKey),
    ]);
  }

  // -------------------- 用户信息部分字段快捷访问 --------------------
  static Future<int?> getUserId() async => getInt(_userIdKey);
  static Future<String?> getUsername() async => getString(_usernameKey);
  static Future<String?> getNickname() async => getString(_nicknameKey);
  static Future<String?> getUserPic() async => getString(_userPicKey);
  static Future<String?> getPhoneNumber() async => getString(_phoneNumberKey);
}
