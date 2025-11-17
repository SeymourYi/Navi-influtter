import 'package:Navi/api/articleAPI.dart';
import 'package:Navi/components/articledetail.dart';
import 'package:Navi/components/articleimage.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Navi/utils/route_utils.dart';
import 'package:Navi/utils/viewport_image.dart';

class LitArticle extends StatefulWidget {
  const LitArticle({super.key, required this.articleData});
  final Map<String, dynamic> articleData;
  @override
  State<LitArticle> createState() => _LitArticleState();
}

class _LitArticleState extends State<LitArticle> {
  final ArticleService articleService = ArticleService();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 转发提示 - 顶部显示转发者信息
          Row(
            children: [
              // 转发图标
              Icon(Icons.repeat, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              // 转发者昵称 + "转推了"
              Text(
                "${widget.articleData['nickname'] ?? '用户'} 转推了",
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left avatar - clickable area
              GestureDetector(
                onTap: () async {
                  // var result = await articleService.getArticleDetail(
                  //   widget.articleData[''],
                  // );

                  // var articleData = result['data'];

                  Navigator.push(
                    context,
                    RouteUtils.slideFromRight(
                      ProfilePage(
                        username: widget.articleData['beShareCreaterUserName'],
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 15,
                    backgroundImage: CachedNetworkImageProvider(
                      widget.articleData['beShareUserPic'],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    var result = await articleService.getArticleDetail(
                      widget.articleData['beShareArticleId'],
                    );
                    var articleData = result['data'];

                    // 尝试预加载文章中的图片以实现“秒开”体验
                    try {
                      List<String> imageUrls = [];
                      if (articleData != null) {
                        if (articleData['coverImgList'] != null &&
                            articleData['coverImgList'] is List &&
                            (articleData['coverImgList'] as List).isNotEmpty) {
                          imageUrls = List<String>.from(
                            articleData['coverImgList'],
                          );
                        } else if (articleData['coverImg'] != null &&
                            articleData['coverImg'].toString().isNotEmpty) {
                          imageUrls = [articleData['coverImg'].toString()];
                        }
                      }

                      if (imageUrls.isNotEmpty) {
                        // 并行预加载，但限制等待时间，避免卡顿
                        await Future.wait(
                          imageUrls.map(
                            (url) => ViewportAwareImage.precacheNetworkImage(
                              url,
                              context,
                            ),
                          ),
                        ).timeout(
                          const Duration(milliseconds: 600),
                          onTimeout: () => [],
                        );
                      }
                    } catch (e) {
                      // 预加载出错时忽略，继续导航
                    }

                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                Articledetail(articleData: articleData),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
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
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username row - 昵称、账号句柄、时间戳在同一行
                      Row(
                        children: [
                          // 昵称 - 稍大，粗体，黑色
                          Flexible(
                            flex: 2,
                            child: Text(
                              "${widget.articleData['beShareNickName']}",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 4),
                          // 账号句柄 - 灰色，较小，使用省略号
                          Flexible(
                            flex: 1,
                            child: Text(
                              "@${widget.articleData['beShareCreaterUserName']}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 时间戳 - 灰色，较小
                          Text(
                            widget.articleData['beShareUptonowTime'] ?? "",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      // Content text - 标准正文大小
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(
                          "${widget.articleData['beShareContent'] ?? ''}",
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            height: 1.5,
                          ),
                          maxLines: null,
                        ),
                      ),

                      // Article image - 支持多张图片
                      if (widget.articleData['beShareCoverImg'] != null &&
                          widget.articleData['beShareCoverImg']
                              .toString()
                              .isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ArticleImage(
                              imageUrls:
                                  widget.articleData['beShareCoverImgList'] !=
                                              null &&
                                          widget.articleData['beShareCoverImgList']
                                              is List &&
                                          (widget.articleData['beShareCoverImgList']
                                                  as List)
                                              .isNotEmpty
                                      ? List<String>.from(
                                        widget
                                            .articleData['beShareCoverImgList'],
                                      )
                                      : [
                                        widget.articleData['beShareCoverImg']
                                            .toString(),
                                      ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
