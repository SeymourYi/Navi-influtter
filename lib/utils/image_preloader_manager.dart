import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';

/// 图片预加载管理器
/// 根据滚动位置预加载即将进入视口的图片
class ImagePreloaderManager {
  static final ImagePreloaderManager _instance = ImagePreloaderManager._internal();
  factory ImagePreloaderManager() => _instance;
  ImagePreloaderManager._internal();

  final Set<String> _preloadingUrls = {};
  final Set<String> _preloadedUrls = {};
  Timer? _preloadTimer;
  static const int _preloadDistance = 500; // 预加载距离（像素）

  /// 根据滚动位置预加载图片
  /// [scrollOffset] 当前滚动位置
  /// [itemCount] 列表项总数
  /// [getItemImageUrls] 获取指定索引项的所有图片URL
  /// [getItemEstimatedHeight] 获取指定索引项的估算高度
  void preloadImagesForScrollPosition({
    required double scrollOffset,
    required int itemCount,
    required List<String> Function(int index) getItemImageUrls,
    required double Function(int index) getItemEstimatedHeight,
    required BuildContext context,
  }) {
    // 取消之前的预加载任务
    _preloadTimer?.cancel();

    // 延迟执行，避免频繁调用
    _preloadTimer = Timer(const Duration(milliseconds: 200), () {
      _performPreload(
        scrollOffset: scrollOffset,
        itemCount: itemCount,
        getItemImageUrls: getItemImageUrls,
        getItemEstimatedHeight: getItemEstimatedHeight,
        context: context,
      );
    });
  }

  void _performPreload({
    required double scrollOffset,
    required int itemCount,
    required List<String> Function(int index) getItemImageUrls,
    required double Function(int index) getItemEstimatedHeight,
    required BuildContext context,
  }) {
    if (!context.mounted) return;

    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double viewportHeight = mediaQuery.size.height;
    
    // 计算视口范围
    final double viewportTop = scrollOffset - _preloadDistance;
    final double viewportBottom = scrollOffset + viewportHeight + _preloadDistance;

    // 遍历所有项，找出在预加载范围内的项
    double currentOffset = 0;
    for (int i = 0; i < itemCount; i++) {
      final double itemHeight = getItemEstimatedHeight(i);
      
      // 检查项是否在预加载范围内
      if (currentOffset + itemHeight >= viewportTop && currentOffset <= viewportBottom) {
        // 预加载该项的所有图片
        final List<String> imageUrls = getItemImageUrls(i);
        for (final String url in imageUrls) {
          if (!_preloadedUrls.contains(url) && !_preloadingUrls.contains(url)) {
            _preloadImage(url, context);
          }
        }
      }

      currentOffset += itemHeight;

      // 如果已经超过底部预加载区域，可以提前退出
      if (currentOffset > viewportBottom + _preloadDistance * 2) {
        break;
      }
    }
  }

  Future<void> _preloadImage(String imageUrl, BuildContext context) async {
    if (!context.mounted) return;

    _preloadingUrls.add(imageUrl);
    
    try {
      await precacheImage(
        CachedNetworkImageProvider(imageUrl),
        context,
      );
      _preloadedUrls.add(imageUrl);
    } catch (e) {
      // 预加载失败，忽略错误
    } finally {
      _preloadingUrls.remove(imageUrl);
    }
  }

  /// 清理预加载缓存
  void clearCache() {
    _preloadedUrls.clear();
    _preloadingUrls.clear();
  }
}

