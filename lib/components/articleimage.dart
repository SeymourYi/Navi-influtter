import 'package:flutter/material.dart';

class ArticleImage extends StatelessWidget {
  const ArticleImage({super.key});

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

  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  onLongPress: () => _showActionMenu(context),
                  child: Hero(
                    tag: 'article_image',
                    child: Image.asset(
                      "lib/assets/images/1.jpg",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 12),
      child: GestureDetector(
        onTap: () => _showFullScreenImage(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Hero(
            tag: 'article_image',
            child: Image.asset(
              "lib/assets/images/1.jpg",
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => Container(
                    height: 200,
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
