import 'package:Navi/components/articleimage.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'package:Navi/utils/route_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PostLitArticle extends StatefulWidget {
  const PostLitArticle({super.key, required this.articleData});
  final dynamic articleData;
  @override
  State<PostLitArticle> createState() => _PostLitArticleState();
}

class _PostLitArticleState extends State<PostLitArticle> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey.shade200, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left avatar - clickable area (方形圆角)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                RouteUtils.slideFromRight(ProfilePage(
                  username: widget.articleData['username'],
                )),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: widget.articleData['userPic'] != null &&
                      widget.articleData['userPic'].toString().isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: widget.articleData['userPic'],
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 32,
                        height: 32,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 32,
                        height: 32,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ),
                    )
                  : Container(
                      width: 32,
                      height: 32,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 18,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),

          // Right content - 使用 Expanded 和 Flexible 防止溢出
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Username row - 优化布局防止溢出（不显示标签）
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        "${widget.articleData['nickname'] ?? ''}",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        "@${widget.articleData['username'] ?? ''}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "·",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[600],
                      ),
                    ),
                    Flexible(
                      child: Text(
                        "${widget.articleData['uptonowTime'] ?? ''}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                // Content text - 确保文本正确换行
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "${widget.articleData['content'] ?? ''}",
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: null,
                  ),
                ),

                // Article image - 支持多张图片
                if (widget.articleData['coverImg'] != null &&
                    widget.articleData['coverImg'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ArticleImage(
                        imageUrls: widget.articleData['coverImgList'] != null &&
                                widget.articleData['coverImgList'] is List &&
                                (widget.articleData['coverImgList'] as List).isNotEmpty
                            ? List<String>.from(widget.articleData['coverImgList'])
                            : [widget.articleData['coverImg'].toString()],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
