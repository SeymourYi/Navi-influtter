import 'package:flutter/material.dart';
import 'full_screen_image_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Navi/utils/route_utils.dart';
import 'package:Navi/utils/viewport_image.dart';

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
    Navigator.push(
      context,
      RouteUtils.scaleImageTransition(
        FullScreenImageView(
          imageUrls: imageUrls,
          initialIndex: initialIndex,
          heroTags: imageUrls.asMap().entries.map((e) => _getHeroTag(e.key)).toList(),
        ),
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

  // 生成唯一的Hero tag
  String _getHeroTag(int index) {
    return 'article_image_${imageUrls[index].hashCode}_$index';
  }

  Widget _buildSingleImage(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context, index),
      child: Padding(
        // padding: const EdgeInsets.all(24),
        padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.0001,
          right: MediaQuery.of(context).size.width * 0.0001,
          top: MediaQuery.of(context).size.width * 0.0001,
          bottom: MediaQuery.of(context).size.width * 0.0001,
        ),
        child: ClipRRect(
          // borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            //设置一个最大高度
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            child: Hero(
              tag: _getHeroTag(index),
              child: Material(
                color: Colors.transparent,
                child: ViewportAwareImage(
                  imageUrl: imageUrls[index],
                  fit: BoxFit.cover,
                  alignment: Alignment.center, // 确保裁剪时居中
                  placeholder: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: Container(
                    width: double.infinity,
                    height: double.infinity, // 错误时也填充相同高度
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                    ),
                  ),
                  memCacheWidth: 800, // 限制内存缓存图片宽度，节省内存
                  maxWidthDiskCache: 1200, // 限制磁盘缓存图片宽度
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
