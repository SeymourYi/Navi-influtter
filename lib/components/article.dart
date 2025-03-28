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
    print(widget.articleData);
    print("111111111111111111111111111111111111");
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // padding: EdgeInsets.all(0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧头像
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
                  padding: EdgeInsets.only(left: 12, top: 8, right: 8),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: CachedNetworkImageProvider(
                      widget.articleData['userPic'],
                    ), // 替换为你的头像路径
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    Articledetail(id: "123"),
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
                    ),

                    widget.articleData['coverImg'] != ""
                        ? ArticleImage(
                          imageUrls: ["${widget.articleData['coverImg']}"],
                        )
                        : Container(), // Returns an empty container if no image
                    // 时间和操作按钮
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
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                iconSize: 18,
                                onPressed: () {},
                                icon: Icon(
                                  Icons.thumb_up_outlined,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                iconSize: 18,
                                onPressed: () {},
                                icon: Icon(
                                  Icons.mode_comment_outlined,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                    padding: EdgeInsets.only(right: 4),
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
                                    style: TextStyle(color: Color(0xFF576B95)),
                                  ),
                                  TextSpan(text: "感谢大家的支持！"),
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
          Divider(height: 20, thickness: 0.5),
        ],
      ),
    );
  }
}
