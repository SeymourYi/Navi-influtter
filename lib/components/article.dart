import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'articleimage.dart';

class Article extends StatefulWidget {
  const Article({super.key});

  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧头像
              Padding(
                padding: EdgeInsets.only(left: 12, top: 8, right: 8),
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(
                    "assets/images/user_avatar.png",
                  ), // 替换为你的头像路径
                ),
              ),

              // 右侧内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 用户名
                    Text(
                      "霸气小肥鹅",
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
                        "社区有个小伙伴，刚跟我吐槽职场环境，结果上周他自己的 App 爆发，得到了应用市场的推荐，数据爆炸。他的产品其实已经默默开发 2 年多了，去年还问我怎么把收到的100 刀提出来，如今已经在琢磨如何利用好这 破天富贵，期待他有空了发个帖子分享一下。做独立开发者就是这样，有努力、有运气，有坚持。",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontFamily: "Inter-Regular",
                        ),
                      ),
                    ),
                    ArticleImage(
                      imageUrls: [
                        "lib/assets/images/3.jpg",
                        "lib/assets/images/3.jpg",
                        "lib/assets/images/3.jpg",
                        "lib/assets/images/3.jpg",
                        "lib/assets/images/3.jpg",
                        "lib/assets/images/3.jpg",
                      ],
                    ),
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
