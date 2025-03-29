import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterlearn2/page/UserInfo/components/userpage.dart';
import 'articleimage.dart';
import '../components/articledetail.dart';
import '../components/userinfo.dart';
import '../api/articleAPI.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Article extends StatefulWidget {
  const Article({super.key, required this.articleData});
  final dynamic articleData;
  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  @override
  void initState() {
    super.initState();
  }

  void _navigateToArticleDetail() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                Articledetail(id: "123"),
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
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          // 使用Stack和Positioned来确保能够点击所有区域
          Stack(
            children: [
              // 底层可点击区域 - 覆盖整个文章区域
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: _navigateToArticleDetail,
                  ),
                ),
              ),

              // 文章内容
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 左侧头像 - 独立点击区域
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        ProfilePage(),
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
                          child: Padding(
                            padding: EdgeInsets.only(left: 12, right: 8),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage: CachedNetworkImageProvider(
                                widget.articleData['userPic'],
                              ),
                            ),
                          ),
                        ),

                        // 右侧内容
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 用户名
                              Text(
                                "${widget.articleData['nickname']}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Inter-Regular",
                                ),
                              ),

                              // 正文内容
                              Padding(
                                padding: EdgeInsets.only(top: 4, right: 12),
                                child: Text(
                                  "${widget.articleData['content']}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontFamily: "Inter-Regular",
                                  ),
                                ),
                              ),

                              // 文章图片
                              widget.articleData['coverImg'] != ""
                                  ? ArticleImage(
                                    imageUrls: [
                                      "${widget.articleData['coverImg']}",
                                    ],
                                  )
                                  : Container(),

                              // 时间和操作按钮区域
                              Padding(
                                padding: EdgeInsets.only(top: 8, right: 12),
                                child: Row(
                                  children: [
                                    Text(
                                      "五分钟以前",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontFamily: "Inter-Regular",
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Spacer(),
                                    // 微信风格操作按钮
                                    Material(
                                      color: Colors.transparent,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // 点赞按钮 - 独立点击区域
                                          InkWell(
                                            onTap: () {
                                              // 点赞操作
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Icon(
                                                Icons.thumb_up_outlined,
                                                size: 18,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          // 评论按钮 - 独立点击区域
                                          InkWell(
                                            onTap: () {
                                              // 评论操作
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Icon(
                                                Icons.mode_comment_outlined,
                                                size: 18,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 点赞和评论行
                              Container(
                                width: double.infinity,
                                margin: EdgeInsets.only(top: 6, right: 12),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF7F7F7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // 点赞行
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF576B95),
                                            fontFamily: "Inter-Regular",
                                          ),
                                          children: [
                                            WidgetSpan(
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                  right: 4,
                                                ),
                                                child: Icon(
                                                  Icons.favorite,
                                                  size: 14,
                                                  color: Color(0xFF576B95),
                                                ),
                                              ),
                                            ),
                                            TextSpan(text: "张三、李四、王五等10人"),
                                          ],
                                        ),
                                      ),

                                      // 评论行
                                      Padding(
                                        padding: EdgeInsets.only(top: 6),
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black,
                                              fontFamily: "Inter-Regular",
                                            ),
                                            children: [
                                              TextSpan(
                                                text: "霸气小肥鹅：",
                                                style: TextStyle(
                                                  color: Color(0xFF576B95),
                                                ),
                                              ),
                                              TextSpan(text: "感谢大家的支持！"),
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // 独立点击区域 - 点赞和评论区，防止点击穿透
              Positioned(
                bottom: 0,
                left: 60, // 与头像对齐
                right: 0,
                child: Column(
                  children: [
                    // 点赞和评论区域
                    Container(
                      margin: EdgeInsets.only(top: 6, right: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // 点击评论区的操作
                          },
                          child: Container(
                            height: 70, // 大约覆盖整个评论区高度
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 20, thickness: 0.5),
        ],
      ),
    );
  }
}
