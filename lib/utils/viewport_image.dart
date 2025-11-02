import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 优化的图片组件，结合 ListView 的 cacheExtent 实现视口优先加载
/// 
/// 注意：此组件依赖于 ListView.builder 的懒加载机制
/// 需要配合 ListView 的 cacheExtent 参数使用
class ViewportAwareImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Alignment alignment;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? memCacheWidth;
  final int? maxWidthDiskCache;
  final double? width;
  final double? height;

  const ViewportAwareImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.maxWidthDiskCache,
    this.width,
    this.height,
  });

  /// 预加载图片到缓存
  /// 这个方法可以在滚动时调用，提前加载即将进入视口的图片
  static Future<void> precacheNetworkImage(String imageUrl, BuildContext context) async {
    await precacheImage(
      CachedNetworkImageProvider(imageUrl),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      alignment: alignment,
      placeholder: (context, url) => placeholder ??
          Container(
            width: width ?? double.infinity,
            height: height ?? double.infinity,
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
      errorWidget: (context, url, error) => errorWidget ??
          Container(
            width: width ?? double.infinity,
            height: height ?? double.infinity,
            color: Colors.grey[200],
            child: const Icon(
              Icons.broken_image,
              color: Colors.grey,
            ),
          ),
      memCacheWidth: memCacheWidth,
      maxWidthDiskCache: maxWidthDiskCache,
      width: width,
      height: height,
      // 使用 fadeInDuration 为 0 来确保立即显示已缓存的图片
      fadeInDuration: const Duration(milliseconds: 0),
      // 启用缓存，优先使用缓存
      cacheKey: imageUrl,
    );
  }
}

