import 'package:flutter/material.dart';
import 'full_screen_image_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ArticleImage extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ArticleImage({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

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
                  leading: const Icon(Icons.close),
                  title: const Text('取消'),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
    );
  }

  void _showFullScreenImage(BuildContext context, int initialIndex) {
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder:
    //         (context) => FullScreenImageView(
    //           imageUrls: imageUrls,
    //           initialIndex: initialIndex,
    //         ),
    //   ),
    // );
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => FullScreenImageView(
              imageUrls: imageUrls,
              initialIndex: initialIndex,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrls.length == 1)
            _buildSingleImage(context, 0)
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: imageUrls.length > 3 ? 3 : imageUrls.length,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
                childAspectRatio: 1,
              ),
              itemCount: imageUrls.length > 9 ? 9 : imageUrls.length,
              itemBuilder: (context, index) {
                return _buildSingleImage(context, index);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSingleImage(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context, index),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 500),
          child: Hero(
            tag: 'article_image_$index',
            child: Image.network(
              imageUrls[index],
              // width: double.infinity,
              // height: double.infinity, // 让高度尽可能填充可用空间
              fit: BoxFit.cover,
              alignment: Alignment.center, // 确保裁剪时居中
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: double.infinity, // 错误时也填充相同高度
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
