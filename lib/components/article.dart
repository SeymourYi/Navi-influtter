import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutterlearn2/page/UserInfo/components/userpage.dart';
import 'articleimage.dart';
import '../components/articledetail.dart';
import '../components/userinfo.dart';
import '../api/articleAPI.dart';
import '../api/getarticleinfoAPI.dart'; // 导入包含点赞API的服务
import '../Store/storeutils.dart'; // 导入用户信息存储工具
import 'package:cached_network_image/cached_network_image.dart';

class Article extends StatefulWidget {
  const Article({super.key, required this.articleData});
  final dynamic articleData;
  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> {
  bool isLiked = false;
  int likeCount = 0;
  String username = ''; // 存储当前用户名
  bool isLikeLoading = false; // 点赞加载状态

  @override
  void initState() {
    super.initState();
    // 初始化点赞状态
    if (widget.articleData != null) {
      isLiked = widget.articleData['islike'] ?? false;
      likeCount = widget.articleData['likecont'] ?? 0;
    }
    // 获取当前用户信息
    _loadCurrentUserInfo();
  }

  // 加载当前用户信息
  Future<void> _loadCurrentUserInfo() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      if (userInfo != null && userInfo['username'] != null) {
        setState(() {
          username = userInfo['username'];
        });
      }
    } catch (e) {
      print('加载用户信息失败: $e');
    }
  }

  // 处理点赞操作
  void _handleLike() async {
    // 如果用户名为空或点赞请求正在处理中，则不执行操作
    if (username.isEmpty || isLikeLoading) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(username.isEmpty ? '请先登录后再点赞' : '正在处理，请稍候...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 检查文章ID是否存在
    if (widget.articleData == null || widget.articleData['id'] == null) {
      return;
    }

    // 先在UI上直接反映点赞状态变化，提高响应速度
    bool newLikedState = !isLiked;
    int newLikeCount = newLikedState ? likeCount + 1 : likeCount - 1;

    // 在UI上立即应用变更
    setState(() {
      isLiked = newLikedState;
      likeCount = newLikeCount;
      isLikeLoading = true;
    });

    try {
      // 使用API调用
      GetArticleInfoService service = GetArticleInfoService();

      var result = await service.likesomearticle(
        username,
        widget.articleData['id'].toString(),
      );

      // 处理API响应
      if (result != null && result['code'] == 0) {
        // 更新原始数据，保证UI一致性
        if (widget.articleData != null) {
          widget.articleData['islike'] = isLiked;
          widget.articleData['likecont'] = likeCount;
        }

        // 显示简短成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isLiked ? '点赞成功' : '取消点赞成功'),
            duration: Duration(milliseconds: 800),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // API失败，回滚状态
        setState(() {
          isLiked = !newLikedState;
          likeCount = isLiked ? likeCount + 1 : likeCount - 1;
        });

        // 显示错误信息
        String errorMsg = '操作失败';
        if (result != null) {
          errorMsg += ': ${result['msg'] ?? result['message'] ?? '未知错误'}';
        } else {
          errorMsg += ': 服务器无响应';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), duration: Duration(seconds: 3)),
        );
      }
    } catch (e) {
      // 处理异常，回滚状态
      setState(() {
        isLiked = !newLikedState;
        likeCount = isLiked ? likeCount + 1 : likeCount - 1;
      });

      // 提取错误信息
      String errorMessage = e.toString();
      if (errorMessage.length > 100) {
        errorMessage = '${errorMessage.substring(0, 97)}...';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('点赞失败: $errorMessage'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      // 重置加载状态
      setState(() {
        isLikeLoading = false;
      });
    }
  }

  void _navigateToArticleDetail() {
    // 检查文章ID是否存在
    if (widget.articleData == null || widget.articleData['id'] == null) {
      return;
    }

    String articleId = "${widget.articleData['id']}";

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                Articledetail(id: articleId),
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
    ).then((_) {
      // 从详情页返回后，刷新点赞状态
      if (widget.articleData != null) {
        setState(() {
          isLiked = widget.articleData['islike'] ?? false;
          likeCount = widget.articleData['likecont'] ?? 0;
        });
      }
    });
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
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _navigateToArticleDetail,
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
                                      "${widget.articleData['uptonowTime']}",
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
                                            onTap: _handleLike,
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Row(
                                                children: [
                                                  // 显示加载状态或点赞图标
                                                  isLikeLoading
                                                      ? SizedBox(
                                                        width: 18,
                                                        height: 18,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.red),
                                                        ),
                                                      )
                                                      : Icon(
                                                        isLiked
                                                            ? Icons.thumb_up
                                                            : Icons
                                                                .thumb_up_outlined,
                                                        size: 18,
                                                        color:
                                                            isLiked
                                                                ? Colors.red
                                                                : Colors.grey,
                                                      ),
                                                  if (likeCount > 0)
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        left: 4,
                                                      ),
                                                      child: Text(
                                                        "$likeCount",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              isLiked
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .grey[700],
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16), // 增加间距
                                          // 评论按钮 - 独立点击区域
                                          InkWell(
                                            onTap: () {
                                              // 评论操作
                                              _navigateToArticleDetail();
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.all(8),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    widget.articleData['commentcount'] !=
                                                                null &&
                                                            widget.articleData['commentcount'] >
                                                                0
                                                        ? Icons.mode_comment
                                                        : Icons
                                                            .mode_comment_outlined,
                                                    size: 18,
                                                    color:
                                                        widget.articleData['commentcount'] !=
                                                                    null &&
                                                                widget.articleData['commentcount'] >
                                                                    0
                                                            ? Colors.blue
                                                            : Colors.grey,
                                                  ),
                                                  if (widget.articleData['commentcount'] !=
                                                          null &&
                                                      widget.articleData['commentcount'] >
                                                          0)
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                        left: 4,
                                                      ),
                                                      child: Text(
                                                        "${widget.articleData['commentcount']}",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.w500,
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

                              // 点赞和评论行 - 仅在需要时显示
                              likeCount > 0 ||
                                      (widget.articleData['commentcount'] !=
                                              null &&
                                          widget.articleData['commentcount'] >
                                              0)
                                  ? GestureDetector(
                                    onTap: _navigateToArticleDetail,
                                    child: Container(
                                      width: double.infinity,
                                      margin: EdgeInsets.only(
                                        top: 6,
                                        right: 12,
                                      ),
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
                                            // 点赞行 - 仅当有点赞时显示
                                            if (likeCount > 0)
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
                                                        padding:
                                                            EdgeInsets.only(
                                                              right: 4,
                                                            ),
                                                        child: Icon(
                                                          Icons.favorite,
                                                          size: 14,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: "$likeCount人点赞",
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            // 评论行 - 仅当有评论时显示
                                            if (widget.articleData['commentcount'] !=
                                                    null &&
                                                widget.articleData['commentcount'] >
                                                    0)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: likeCount > 0 ? 6 : 0,
                                                ),
                                                child: Text(
                                                  "${widget.articleData['commentcount']}条评论",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Color(0xFF576B95),
                                                    fontFamily: "Inter-Regular",
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  : Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Divider(height: 20, thickness: 0.5),
        ],
      ),
    );
  }
}
