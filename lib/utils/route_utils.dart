import 'package:flutter/material.dart';

/// 支持手势返回的滑动页面路由
class SlidePageRoute<T> extends PageRoute<T> {
  final Widget page;
  final Offset startOffset;
  final Duration _duration;
  final Curve curve;

  SlidePageRoute({
    required this.page,
    this.startOffset = const Offset(1.0, 0.0),
    Duration transitionDuration = const Duration(milliseconds: 450),
    this.curve = Curves.easeOutCubic,
  }) : _duration = transitionDuration;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => _duration;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return page;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const end = Offset.zero;
    
    var tween = Tween(begin: startOffset, end: end).chain(
      CurveTween(curve: curve),
    );
    
    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}

/// 路由工具类 - 提供统一的滑动动画页面切换（支持手势返回）
class RouteUtils {
  /// 从右侧滑入的页面切换动画，支持手势返回（适用于大多数页面）
  static SlidePageRoute<T> slideFromRight<T>(Widget page) {
    return SlidePageRoute<T>(
      page: page,
      startOffset: const Offset(1.0, 0.0),
      transitionDuration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  /// 从右侧滑入的页面切换动画（兼容旧版本，不推荐使用）
  static PageRouteBuilder<T> slideFromRightOld<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 450),
      maintainState: true, // 保持页面状态，避免重新加载
    );
  }

  /// 从底部滑入的页面切换动画（适用于弹窗式页面，带遮罩）
  static PageRouteBuilder<T> slideFromBottom<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 450),
      maintainState: true, // 保持页面状态，避免重新加载
      opaque: false,
      barrierColor: Colors.black.withOpacity(0.5),
      barrierDismissible: true,
    );
  }

  /// 从左侧滑入的页面切换动画（较少使用）
  static PageRouteBuilder<T> slideFromLeft<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 450),
      reverseTransitionDuration: const Duration(milliseconds: 450),
      maintainState: true, // 保持页面状态，避免重新加载
    );
  }

  /// 图片查看的缩放放大动画（类似微信，支持Hero动画）
  /// Hero动画会处理图片的位置和大小过渡，这里只处理背景淡入
  static PageRouteBuilder<T> scaleImageTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 淡入动画：背景从透明慢慢变为黑色，使用平滑的曲线
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        // 轻微缩放：配合Hero动画，让整体有一个轻微的放大感
        final scaleAnimation = Tween<double>(
          begin: 0.95,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

        // 组合淡入和轻微缩放，Hero动画会处理图片本身的缩放
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      maintainState: true, // 保持页面状态，避免重新加载图片
      opaque: false,
    );
  }
}

