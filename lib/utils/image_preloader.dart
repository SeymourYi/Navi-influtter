import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Store/storeutils.dart';

class ImagePreloader {
  // 存储预加载的图片
  static ImageProvider? drawerBackgroundImage;
  static ImageProvider? userAvatarImage;

  // 默认背景图片URL
  static const String DEFAULT_BG_IMAGE =
      'https://img-s.msn.cn/tenant/amp/entityid/AA1yQEG5?w=0&h=0&q=60&m=6&f=jpg&u=t';

  // 默认头像图片路径
  static const String DEFAULT_AVATAR = "lib/assets/images/userpic.jpg";

  // 在应用启动时预加载图片
  static Future<void> preloadImages(BuildContext context) async {
    try {
      // 获取用户信息
      final userInfo = await SharedPrefsUtils.getUserInfo();

      // 预加载背景图片
      final String bgImageUrl =
          userInfo != null &&
                  userInfo['bgImg'] != null &&
                  userInfo['bgImg'].isNotEmpty
              ? userInfo['bgImg']
              : DEFAULT_BG_IMAGE;

      drawerBackgroundImage = CachedNetworkImageProvider(bgImageUrl);
      precacheImage(drawerBackgroundImage!, context);

      // 预加载用户头像
      if (userInfo != null &&
          userInfo['userPic'] != null &&
          userInfo['userPic'].isNotEmpty) {
        userAvatarImage = CachedNetworkImageProvider(userInfo['userPic']);
        precacheImage(userAvatarImage!, context);
      } else {
        userAvatarImage = AssetImage(DEFAULT_AVATAR);
        precacheImage(userAvatarImage!, context);
      }

      print('图片预加载成功');
    } catch (e) {
      print('图片预加载失败: $e');
      // 加载失败时，使用默认图片
      drawerBackgroundImage = CachedNetworkImageProvider(DEFAULT_BG_IMAGE);
      userAvatarImage = AssetImage(DEFAULT_AVATAR);
    }
  }

  // 更新预加载的图片（当用户信息更新时使用）
  static Future<void> updateImages(
    BuildContext context,
    Map<String, dynamic>? userInfo,
  ) async {
    try {
      if (userInfo != null) {
        // 更新背景图片
        if (userInfo['bgImg'] != null && userInfo['bgImg'].isNotEmpty) {
          final String bgImageUrl = userInfo['bgImg'];

          if (drawerBackgroundImage == null ||
              (drawerBackgroundImage is CachedNetworkImageProvider &&
                  (drawerBackgroundImage as CachedNetworkImageProvider).url != bgImageUrl)) {
            drawerBackgroundImage = CachedNetworkImageProvider(bgImageUrl);
            precacheImage(drawerBackgroundImage!, context);
          }
        }

        // 更新用户头像
        if (userInfo['userPic'] != null && userInfo['userPic'].isNotEmpty) {
          userAvatarImage = CachedNetworkImageProvider(userInfo['userPic']);
          precacheImage(userAvatarImage!, context);
        }
      }
    } catch (e) {
      print('更新预加载图片失败: $e');
    }
  }
}
