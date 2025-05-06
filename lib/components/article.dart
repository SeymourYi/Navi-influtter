import 'package:Navi/components/litarticle.dart';
import 'package:Navi/page/UserInfo/userhome.dart';
import 'package:Navi/page/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'package:provider/provider.dart';
import 'articleimage.dart';
import '../components/articledetail.dart';
import '../components/userinfo.dart';
import '../api/articleAPI.dart';
import '../api/getarticleinfoAPI.dart'; // 导入包含点赞API的服务
import '../Store/storeutils.dart'; // 导入用户信息存储工具
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Article extends StatefulWidget {
  const Article({super.key, required this.articleData});
  final dynamic articleData;
  @override
  State<Article> createState() => _ArticleState();
}

class _ArticleState extends State<Article> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool isLiked = false;
  int likeCount = 0;
  String username = ''; // 存储当前用户名
  bool isLikeLoading = false; // 点赞加载状态
  bool isRepostLoading = false; // 转发加载状态
  Map<String, dynamic>? _currentUser; // 当前用户信息
  TextEditingController _repostController = TextEditingController(); // 转发内容控制器
  final ImagePicker _picker = ImagePicker(); // 图片选择器实例
  String? _selectedImagePath; // 选择的图片路径
  bool option = false;
  @override
  void initState() {
    super.initState();
    // 初始化点赞状态
    if (widget.articleData != null) {
      isLiked = widget.articleData['islike'] ?? false;
      likeCount = widget.articleData['likecont'] ?? 0;
    }
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _animationController.value = 1.0;
    // 获取当前用户信息
    _loadCurrentUserInfo();
  }

  @override
  void dispose() {
    _repostController.dispose();
    super.dispose();
  }

  // 加载当前用户信息
  Future<void> _loadCurrentUserInfo() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      if (userInfo != null && userInfo['username'] != null) {
        setState(() {
          username = userInfo['username'];
          _currentUser = userInfo;
        });
      }
    } catch (e) {}
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

  void _NavigateToArticleDetail({bool focusOnComment = false}) {
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
                Articledetail(articleData: widget.articleData),
        // UserHome(),
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

  // 处理转发/引用帖子
  void _handleRepost() {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先登录后再转发'), duration: Duration(seconds: 2)),
      );
      return;
    }

    // 显示转发对话框
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 让底部弹窗可以随着内容滚动
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '转发帖子',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Divider(),

                    // 原帖内容预览
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: CachedNetworkImageProvider(
                                  widget.articleData['userPic'],
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                widget.articleData['nickname'] ?? '用户',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.articleData['content'],
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),
                    // 添加评论输入框
                    TextField(
                      controller: _repostController,
                      decoration: InputDecoration(
                        hintText: '添加评论...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),

                    SizedBox(height: 8),

                    // 图片选择区域
                    if (_selectedImagePath != null)
                      Stack(
                        children: [
                          Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.file(
                              File(_selectedImagePath!),
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImagePath = null;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 16),

                    // 操作按钮
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.image, color: Colors.green),
                          onPressed: () => _pickRepostImage(setState),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed:
                              isRepostLoading
                                  ? null
                                  : () => _submitRepost(context),
                          child:
                              isRepostLoading
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text('转发'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // 选择图片方法
  Future<void> _pickRepostImage(StateSetter setState) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {}
  }

  // 提交转发
  Future<void> _submitRepost(BuildContext context) async {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先登录后再转发'), duration: Duration(seconds: 2)),
      );
      return;
    }

    // 检查文章ID是否存在
    if (widget.articleData == null || widget.articleData['id'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('无效的文章'), duration: Duration(seconds: 2)),
      );
      return;
    }

    setState(() {
      isRepostLoading = true;
    });

    try {
      GetArticleInfoService service = GetArticleInfoService();

      var result = await service.addReapetArticle(
        beShareArticleId: widget.articleData['id'].toString(),
        content: _repostController.text,
        createUserId: _currentUser!['id'],
        createUserName: _currentUser!['username'],
        imagePath: _selectedImagePath,
      );

      setState(() {
        isRepostLoading = false;
        _repostController.clear();
        _selectedImagePath = null;
      });

      // 关闭底部表单
      Navigator.pop(context);

      // 显示成功信息
      if (result != null && result['code'] == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('转发成功!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        String errorMsg = result != null ? result['msg'] ?? '转发失败' : '转发失败';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isRepostLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('转发失败: ${e.toString()}'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
        side: BorderSide(color: Colors.grey.shade200, width: 0.5),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder:
                  (context, animation, secondaryAnimation) =>
                      Articledetail(articleData: widget.articleData),
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
              transitionDuration: Duration(milliseconds: 300),
              reverseTransitionDuration: Duration(milliseconds: 300),
              opaque: false,
              barrierDismissible: true,
            ),
          );
        },

        // onTap: _NavigateToArticleDetail,
        // splashColor: Colors.grey.withOpacity(0.1),
        // highlightColor: Colors.grey.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
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
                              UserHome(userId: widget.articleData['username']),
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
                      transitionDuration: Duration(milliseconds: 300),
                      reverseTransitionDuration: Duration(milliseconds: 300),
                      opaque: false,
                      barrierDismissible: true,
                    ),
                  );
                },
                child: Container(
                  width: 35, // 方形边长 = 圆形直径 (radius * 2)
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4), // 可以调整圆角大小
                    image: DecorationImage(
                      image: NetworkImage(widget.articleData['userPic']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // 右侧内容部分
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 用户信息行
                      Row(
                        children: [
                          Text(
                            "${widget.articleData['nickname']}",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(width: 4),
                          // Text(
                          //   "@${widget.articleData['username']}",
                          //   style: TextStyle(
                          //     fontSize: 13,
                          //     color: Colors.grey[600],
                          //   ),
                          //   overflow: TextOverflow.ellipsis,
                          // ),
                          // Text(
                          //   " · ${widget.articleData['uptonowTime']}",
                          //   style: TextStyle(
                          //     fontSize: 13,
                          //     color: Colors.grey[600],
                          //   ),
                          // ),
                        ],
                      ),

                      // 文章内容区域
                      Padding(
                        padding: const EdgeInsets.only(top: 2, bottom: 6),
                        child: Text(
                          "${widget.articleData['content']}",
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.3,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      // 文章图片
                      // if (widget.articleData['coverImg'] != "")
                      if (true)
                        GestureDetector(
                          onTap: () {
                            // 这里可以添加查看大图的逻辑
                            return;
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ArticleImage(
                                // imageUrls: ["${widget.articleData['coverImg']}"],
                                imageUrls: [
                                  "https://pic.vjshi.com/2022-04-25/2012b0a6f8a44f62b40dd3f2851d067d/00001.jpg?x-oss-process=style/watermark",
                                  "https://pic.vjshi.com/2022-04-25/2012b0a6f8a44f62b40dd3f2851d067d/00001.jpg?x-oss-process=style/watermark",
                                  "https://pic.vjshi.com/2022-04-25/2012b0a6f8a44f62b40dd3f2851d067d/00001.jpg?x-oss-process=style/watermark",
                                  "https://pic.vjshi.com/2022-04-25/2012b0a6f8a44f62b40dd3f2851d067d/00001.jpg?x-oss-process=style/watermark",
                                  "https://pic.vjshi.com/2022-04-25/2012b0a6f8a44f62b40dd3f2851d067d/00001.jpg?x-oss-process=style/watermark",
                                  "https://pic.vjshi.com/2022-04-25/2012b0a6f8a44f62b40dd3f2851d067d/00001.jpg?x-oss-process=style/watermark",
                                  "https://pic.vjshi.com/2022-04-25/2012b0a6f8a44f62b40dd3f2851d067d/00001.jpg?x-oss-process=style/watermark",
                                  "https://pic.vjshi.com/2022-04-25/2012b0a6f8a44f62b40dd3f2851d067d/00001.jpg?x-oss-process=style/watermark",
                                  "https://pic.vjshi.com/2022-04-25/2012b0a6f8a44f62b40dd3f2851d067d/00001.jpg?x-oss-process=style/watermark",
                                ],
                              ),
                            ),
                          ),
                        ),

                      // 转发内容
                      if (widget.articleData['userShare'] == true)
                        Container(
                          margin: EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: LitArticle(articleData: widget.articleData),
                        ),

                      // 互动栏
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 8),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       // 评论按钮
                      //       InkWell(
                      //         onTap: () {
                      //           Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //               builder:
                      //                   (context) => PostPage(
                      //                     type: '评论',
                      //                     articelData: widget.articleData,
                      //                   ),
                      //             ),
                      //           );
                      //         },
                      //         borderRadius: BorderRadius.circular(20),
                      //         child: Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: _buildActionButton(
                      //             icon:
                      //                 widget.articleData['commentcount'] !=
                      //                             null &&
                      //                         widget.articleData['commentcount'] >
                      //                             0
                      //                     ? "lib/assets/icons/chatbubble-ellipses.svg"
                      //                     : "lib/assets/icons/chatbubble-ellipses-outline.svg",
                      //             count: widget.articleData['commentcount'],
                      //             color: Color.fromRGBO(29, 161, 242, 1.0),
                      //           ),
                      //         ),
                      //       ),

                      //       // 转发按钮
                      //       InkWell(
                      //         onTap: () {
                      //           Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //               builder:
                      //                   (context) => PostPage(
                      //                     type: '转发',
                      //                     articelData: widget.articleData,
                      //                   ),
                      //             ),
                      //           );
                      //         },
                      //         borderRadius: BorderRadius.circular(20),
                      //         child: Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: _buildActionButton(
                      //             icon: "lib/assets/icons/repeat-outline.svg",
                      //             count: widget.articleData['repeatcount'],
                      //             color: Color.fromRGBO(23, 191, 99, 1.0),
                      //           ),
                      //         ),
                      //       ),

                      //       // 点赞按钮
                      //       InkWell(
                      //         onTap: _handleLike,
                      //         borderRadius: BorderRadius.circular(20),
                      //         child: Padding(
                      //           padding: const EdgeInsets.all(8.0),
                      //           child: _buildLikeButton(),
                      //         ),
                      //       ),

                      //       // 空白占位，保持按钮分布均匀
                      //       SizedBox(width: 8),
                      //     ],
                      //   ),
                      // ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque, // 阻止事件冒泡
                        onTap: () {
                          if (option == true) {
                            //打开操作栏
                            _animationController.forward();
                            print("打开");
                            setState(() {
                              option = !option;
                            });
                          } else {
                            //关闭操作栏
                            _animationController.reverse();
                            print("关闭");
                            setState(() {
                              option = !option;
                            });
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                child: Text(
                                  widget.articleData["uptonowTime"],
                                  style: TextStyle(
                                    fontSize: 10, // 字体大小
                                    color: Colors.grey, // 字体颜色
                                    fontWeight: FontWeight.w600, // 字重（正常/加粗等）
                                    fontStyle: FontStyle.normal, // 字体样式（正常/斜体）
                                  ),
                                ),
                              ),
                              // Container(
                              //   child: Text(
                              //     "商丘市",
                              //     style: TextStyle(
                              //       fontSize: 10, // 字体大小
                              //       color: const Color.fromARGB(
                              //         144,
                              //         43,
                              //         45,
                              //         48,
                              //       ), // 字体颜色
                              //       fontWeight: FontWeight.w600, // 字重（正常/加粗等）
                              //       fontStyle: FontStyle.normal, // 字体样式（正常/斜体）
                              //     ),
                              //   ),
                              // ),
                              Spacer(),
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(
                                      100 * _animationController.value,
                                      0,
                                    ),
                                    child: Transform.scale(
                                      scale: 1 - 1 * _animationController.value,
                                      child: Opacity(
                                        opacity:
                                            1.0 - _animationController.value,
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                              255,
                                              40,
                                              44,
                                              52,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ), // 更大的圆角
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ), // 左右内边距
                                          child: Row(
                                            mainAxisSize:
                                                MainAxisSize.min, // 让容器包裹内容
                                            children: [
                                              // 点赞按钮
                                              _buildActionButtona(
                                                icon:
                                                    'lib/assets/icons/Vector (9).svg',
                                                label: '赞',
                                                showDivider: true,
                                              ),

                                              // 评论按钮
                                              _buildActionButtona(
                                                icon:
                                                    'lib/assets/icons/chatbubble-ellipses-outline.svg',
                                                label: '评论',
                                                showDivider: true,
                                              ),
                                              // 转发按钮
                                              _buildActionButtona(
                                                icon:
                                                    'lib/assets/icons/repeat-outline.svg',
                                                label: '转发',
                                                showDivider: false,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // 辅助方法：构建单个操作按钮
                              SizedBox(width: 10),
                              Container(
                                width: 20, // 建议设置固定宽度，确保点击区域足够
                                height: 20, // 建议设置固定高度
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(
                                    0.1,
                                  ), // 微信风格的半透明红色背景
                                  borderRadius: BorderRadius.circular(
                                    6,
                                  ), // 微信风格的圆角大小
                                ),
                                child: Center(
                                  // 确保图标居中
                                  child: SvgPicture.asset(
                                    'lib/assets/icons/Vector9.svg',
                                    width: 6, // 适当调大图标尺寸
                                    height: 6,
                                    color: const Color.fromARGB(
                                      94,
                                      0,
                                      226,
                                      1,
                                    ), // 微信风格的红色图标
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color:
                              Colors
                                  .grey[100], // Lighter background color like WeChat
                          borderRadius: BorderRadius.circular(
                            3,
                          ), // Rounded corners
                        ),
                        width:
                            MediaQuery.of(context).size.width *
                            0.8, // Slightly narrower
                        padding: EdgeInsets.all(8), // Internal padding
                        margin: EdgeInsets.only(
                          right: 8,
                          bottom: 4,
                        ), // Spacing like WeChat
                        child: Wrap(
                          spacing: 6, // Space between items
                          runSpacing: 6, // Space between lines
                          children: [
                            Icon(
                              Icons.favorite_border_outlined,
                              size: 25,
                              color: const Color.fromARGB(64, 86, 105, 145),
                            ),
                            Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  2,
                                ), // Circular
                                image: DecorationImage(
                                  image: NetworkImage(
                                    widget.articleData['userPic'],
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtona({
    required String icon,
    required String label,
    required bool showDivider,
  }) {
    // 设置不同按钮的颜色
    Color iconColor;
    Color textColor;

    if (label == '赞') {
      iconColor =
          isLiked ? const Color.fromRGBO(224, 36, 94, 1.0) : Colors.grey[700]!;
      textColor =
          isLiked ? const Color.fromRGBO(224, 36, 94, 1.0) : Colors.grey[700]!;
    } else if (label == '评论') {
      iconColor = Color.fromRGBO(29, 161, 242, 1.0); // 蓝色
      textColor = Colors.grey[700]!;
    } else if (label == '转发') {
      iconColor = Color.fromRGBO(23, 191, 99, 1.0); // 绿色
      textColor = Colors.grey[700]!;
    } else {
      iconColor = Colors.grey[700]!;
      textColor = Colors.grey[700]!;
    }

    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque, // 确保整个区域可点击
          onTap: () {
            // 处理点击事件
            if (label == '评论') {
              _animationController.forward();
              setState(() {
                option = !option;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          PostPage(type: '评论', articelData: widget.articleData),
                ),
              );
            } else if (label == '转发') {
              _animationController.forward();
              setState(() {
                option = !option;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          PostPage(type: '转发', articelData: widget.articleData),
                ),
              );
            } else if (label == '赞') {
              _animationController.forward();
              setState(() {
                option = !option;
              });
              // _handleLike(); // 正确调用点赞方法
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                SvgPicture.asset(
                  icon,
                  width: 16, // 稍大的图标
                  height: 16,
                  color: iconColor, // 使用动态颜色
                ),
                SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: textColor), // 使用动态颜色
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            height: 12,
            width: 1,
            color: Colors.grey.withOpacity(0.3), // 更淡的分隔线
          ),
      ],
    );
  }

  // 构建交互按钮
  Widget _buildActionButton({
    required String icon,
    int? count,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          icon,
          width: 16,
          height: 16,
          color: count != null && count > 0 ? color : Colors.grey[600],
        ),
        if (count != null && count > 0)
          Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              "$count",
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }

  // 点赞按钮
  Widget _buildLikeButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        isLikeLoading
            ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color.fromRGBO(224, 36, 94, 1.0),
                ),
              ),
            )
            : Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color:
                  isLiked
                      ? const Color.fromRGBO(224, 36, 94, 1.0)
                      : Colors.grey[600],
            ),
        if (likeCount > 0)
          Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              "$likeCount",
              style: TextStyle(
                fontSize: 13,
                color:
                    isLiked
                        ? const Color.fromRGBO(224, 36, 94, 1.0)
                        : Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ],
    );
  }
}
