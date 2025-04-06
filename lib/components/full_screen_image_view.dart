import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

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

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 1.0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveImage() async {
    try {
      // 请求存储权限
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('需要存储权限才能保存图片')));
        return;
      }

      // 下载图片
      final response = await http.get(
        Uri.parse(widget.imageUrls[_currentIndex]),
      );
      if (response.statusCode != 200) {
        throw Exception('下载图片失败');
      }

      // 保存到相册
      final result = await ImageGallerySaver.saveImage(
        response.bodyBytes,
        quality: 100,
        name: "image_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess']) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('图片已保存到相册')));
      } else {
        throw Exception('保存失败');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败: ${e.toString()}')));
    }
  }

  void _showActionMenu(BuildContext context) {
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
                    _saveImage();
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Navigator.pop(context),
                onLongPress: () => _showActionMenu(context),
                child: Hero(
                  tag: 'article_image_$index',
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
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.imageUrls.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: _currentIndex == index ? 12 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _currentIndex == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
