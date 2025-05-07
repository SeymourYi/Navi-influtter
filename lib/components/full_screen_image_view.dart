import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

class FullScreenImageView extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageView({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;

  // 拖拽状态
  bool _isDragging = false;
  Offset _dragOffset = Offset.zero;
  double _dragScale = 1.0;
  double _backgroundOpacity = 0.5;
  double _dragStartY = 0;

  // 缩放状态
  bool _isZoomed = false;
  double _currentScale = 1.0;
  double _startScale = 1.0;
  Offset _normalizedPosition = Offset.zero;

  // 双击放大相关变量
  bool _isAnimating = false;
  int _doubleTapCount = 0;
  double _previousScale = 1.0;
  final double _maxDoubleTapScale = 3.0; // 双击最大放大倍数

  // 滑动速度计算
  DateTime _lastDragUpdate = DateTime.now();
  Offset _lastDragPosition = Offset.zero;
  double _dragVelocity = 0;

  // 退出动画控制器
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  // 缩放动画控制器
  late AnimationController _zoomAnimationController;
  late Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // 初始化动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_animationController);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(_animationController);

    _opacityAnimation = Tween<double>(
      begin: 0.5,
      end: 0.5,
    ).animate(_animationController);

    // 初始化缩放动画控制器
    _zoomAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _zoomAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _zoomAnimationController.addListener(() {
      setState(() {
        _currentScale = _zoomAnimation.value;
      });
    });

    _zoomAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimating = false;
        // 更新缩放状态
        setState(() {
          _isZoomed = _currentScale > 1.05;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _zoomAnimationController.dispose();
    super.dispose();
  }

  // 计算屏幕高度的30%作为判断阈值
  double get _dismissThreshold => MediaQuery.of(context).size.height * 0.3;

  // 处理拖拽开始
  void _handleDragStart(DragStartDetails details) {
    if (_isZoomed) return;

    setState(() {
      _isDragging = true;
      _dragStartY = details.globalPosition.dy;
      _lastDragPosition = details.globalPosition;
      _lastDragUpdate = DateTime.now();
      _dragVelocity = 0;
    });

    _animationController.stop();
  }

  // 处理拖拽更新
  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || _isZoomed) return;

    // 计算拖拽速度
    final now = DateTime.now();
    final timeDiff = now.difference(_lastDragUpdate).inMilliseconds;
    if (timeDiff > 0) {
      _dragVelocity =
          (details.globalPosition.dy - _lastDragPosition.dy) / timeDiff * 1000;
    }
    _lastDragPosition = details.globalPosition;
    _lastDragUpdate = now;

    // 计算拖拽偏移和缩放
    final dy = details.globalPosition.dy - _dragStartY;

    setState(() {
      // 只允许向下拖动
      if (dy > 0) {
        _dragOffset = Offset(0, dy);

        // 计算背景透明度 (随拖动距离快速减小)
        final dragPercent = math.min(1.0, dy / _dismissThreshold);
        _backgroundOpacity = math.max(0, 0.5 - dragPercent * 0.5);

        // 计算缩放比例 (随拖动距离缓慢减小)
        _dragScale = math.max(0.7, 1.0 - dragPercent * 0.3);
      }
    });
  }

  // 处理拖拽结束
  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging || _isZoomed) return;

    // 判断是否应该关闭
    final shouldDismiss =
        _dragOffset.dy > _dismissThreshold * 0.25 || // 距离超过阈值25%
        _dragVelocity > 700; // 或者速度足够快

    if (shouldDismiss) {
      _animateDismiss();
    } else {
      _animateReset();
    }

    setState(() {
      _isDragging = false;
    });
  }

  // 处理拖拽取消
  void _handleDragCancel() {
    if (_isDragging) {
      _animateReset();
      setState(() {
        _isDragging = false;
      });
    }
  }

  // 执行退出动画
  void _animateDismiss() {
    final targetOffset = Offset(0, MediaQuery.of(context).size.height);

    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: targetOffset,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: _dragScale, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(
      begin: _backgroundOpacity,
      end: 0.0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.reset();
    _animationController.forward().then((_) {
      Navigator.of(context).pop();
    });
  }

  // 执行重置动画
  void _animateReset() {
    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: _dragScale, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(
      begin: _backgroundOpacity,
      end: 0.5,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.reset();
    _animationController.forward().then((_) {
      setState(() {
        _dragOffset = Offset.zero;
        _dragScale = 1.0;
        _backgroundOpacity = 0.5;
      });
    });
  }

  // 处理缩放开始事件
  void _handleScaleStart(ScaleStartDetails details) {
    _startScale = _currentScale;
    // 记录归一化后的触摸位置作为缩放中心点
    _normalizedPosition = details.localFocalPoint;

    // 存储双击位置坐标
    if (!_isAnimating) {
      _previousScale = _currentScale;
    }
  }

  // 处理缩放更新事件
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_isAnimating) return;

    // 限制最大最小缩放比例
    final newScale = (_startScale * details.scale).clamp(0.8, 4.0);

    setState(() {
      _currentScale = newScale;
      _isZoomed = _currentScale > 1.05;
    });
  }

  // 处理缩放结束事件
  void _handleScaleEnd(ScaleEndDetails details) {
    if (_isAnimating) return;

    // 如果缩放比例小于1.0，则恢复到1.0
    if (_currentScale < 1.0) {
      _animateScale(1.0);
    } else if (_currentScale > 4.0) {
      _animateScale(4.0);
    }
  }

  // 处理双击事件
  void _handleDoubleTap(TapDownDetails details) {
    // 记录双击位置
    final tapPosition = details.localPosition;

    if (_currentScale > 1.05) {
      // 如果已经放大，双击恢复原始大小
      _animateScale(1.0);
    } else {
      // 如果是原始大小，双击放大
      _animateScale(_maxDoubleTapScale);
    }
  }

  // 缩放动画
  void _animateScale(double targetScale) {
    _isAnimating = true;
    _zoomAnimation = Tween<double>(
      begin: _currentScale,
      end: targetScale,
    ).animate(
      CurvedAnimation(
        parent: _zoomAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _zoomAnimationController.reset();
    _zoomAnimationController.forward();
  }

  // 显示操作菜单
  void _showActionMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.save_alt),
                  title: const Text('保存到相册'),
                  onTap: () {
                    Navigator.pop(context);
                    // 实现保存功能
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.close),
                  title: const Text('取消'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // 计算当前偏移、缩放和透明度值
        final currentOffset =
            _isDragging ? _dragOffset : _offsetAnimation.value;
        final currentScale = _isDragging ? _dragScale : _scaleAnimation.value;
        final currentOpacity =
            _isDragging ? _backgroundOpacity : _opacityAnimation.value;

        return Scaffold(
          backgroundColor: Colors.black.withOpacity(currentOpacity),
          body: Stack(
            fit: StackFit.expand,
            children: [
              // 图片内容区
              Transform.translate(
                offset: currentOffset,
                child: Transform.scale(scale: currentScale, child: child),
              ),

              // 指示器
              if (widget.imageUrls.length > 1 &&
                  !_isDragging &&
                  currentOpacity > 0.2)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.imageUrls.length,
                      (index) => Container(
                        width: _currentIndex == index ? 10 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              _currentIndex == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
      child: GestureDetector(
        // 统一的手势检测器
        onVerticalDragStart: _isZoomed ? null : _handleDragStart,
        onVerticalDragUpdate: _isZoomed ? null : _handleDragUpdate,
        onVerticalDragEnd: _isZoomed ? null : _handleDragEnd,
        onVerticalDragCancel: _handleDragCancel,
        onTap: _isZoomed ? null : () => Navigator.of(context).pop(),
        onLongPress: _showActionMenu,
        // 双击手势检测器
        onDoubleTapDown: _handleDoubleTap,
        // 缩放手势
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
        // 内容区域
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.imageUrls.length,
          physics:
              _isDragging || _isZoomed
                  ? const NeverScrollableScrollPhysics()
                  : const ClampingScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
              // 重置缩放状态
              _currentScale = 1.0;
              _isZoomed = false;
            });
          },
          itemBuilder: (context, index) {
            return Hero(
              tag: 'article_image_$index',
              child: Transform.scale(
                scale: _currentScale,
                child: Center(
                  child: Image.network(
                    widget.imageUrls[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      );
                    },
                    errorBuilder:
                        (context, error, stackTrace) => Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error,
                                color: Colors.white,
                                size: 50,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '图片加载失败',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
