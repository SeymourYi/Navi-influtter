import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'articleimage.dart';
import '../components/articledetail.dart';
import '../components/userinfo.dart';
import '../api/articleAPI.dart';
import '../api/getarticleinfoAPI.dart'; // 导入包含点赞API的服务
import 'package:Navi/utils/viewport_image.dart';
import '../Store/storeutils.dart'; // 导入用户信息存储工具
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../utils/route_utils.dart';

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
  bool isRepostLoading = false; // 转发加载状态
  Map<String, dynamic>? _currentUser; // 当前用户信息
  TextEditingController _repostController = TextEditingController(); // 转发内容控制器
  final ImagePicker _picker = ImagePicker(); // 图片选择器实例
  String? _selectedImagePath; // 选择的图片路径

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

  Future<void> _NavigateToArticleDetail({bool focusOnComment = false}) async {
    // 检查文章ID是否存在
    if (widget.articleData == null || widget.articleData['id'] == null) {
      return;
    }

    String articleId = "${widget.articleData['id']}";

    try {
      List<String> imageUrls = [];
      if (widget.articleData != null) {
        if (widget.articleData['coverImgList'] != null &&
            widget.articleData['coverImgList'] is List &&
            (widget.articleData['coverImgList'] as List).isNotEmpty) {
          imageUrls = List<String>.from(widget.articleData['coverImgList']);
        } else if (widget.articleData['coverImg'] != null &&
            widget.articleData['coverImg'].toString().isNotEmpty) {
          imageUrls = [widget.articleData['coverImg'].toString()];
        }
      }

      if (imageUrls.isNotEmpty) {
        await Future.wait(
          imageUrls.map(
            (url) => ViewportAwareImage.precacheNetworkImage(url, context),
          ),
        ).timeout(const Duration(milliseconds: 600), onTimeout: () => []);
      }
    } catch (e) {}

    Navigator.push(
      context,
      RouteUtils.slideFromRight(Articledetail(articleData: widget.articleData)),
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
    } catch (e) {
      print('图片选择失败: $e');
    }
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
                    onTap: _NavigateToArticleDetail,
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
                              RouteUtils.slideFromRight(
                                ProfilePage(
                                  username: widget.articleData['username'],
                                ),
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
                                  onTap: _NavigateToArticleDetail,
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
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: Tooltip(
                                              message: isLiked ? '取消点赞' : '点赞',
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
                                                        padding:
                                                            EdgeInsets.only(
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
                                          ),
                                          SizedBox(width: 16), // 增加间距
                                          // 评论按钮 - 独立点击区域
                                          InkWell(
                                            onTap: () {
                                              // 评论操作 - 传递true表示需要聚焦到评论框
                                              _NavigateToArticleDetail(
                                                focusOnComment: true,
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: Tooltip(
                                              message: '点击发表评论',
                                              child: Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      widget.articleData['commentcount'] !=
                                                                  null &&
                                                              widget.articleData['commentcount'] >
                                                                  0
                                                          ? Icons.chat_bubble
                                                          : Icons
                                                              .chat_bubble_outline,
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
                                                        padding:
                                                            EdgeInsets.only(
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
                                          ),
                                          SizedBox(width: 16), // 增加间距
                                          // 转发按钮 - 独立点击区域
                                          InkWell(
                                            onTap: _handleRepost,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            child: Tooltip(
                                              message: '转发',
                                              child: Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.repeat,
                                                      size: 18,
                                                      color:
                                                          widget.articleData['repeatcount'] !=
                                                                      null &&
                                                                  widget.articleData['repeatcount'] >
                                                                      0
                                                              ? Colors.green
                                                              : Colors.grey,
                                                    ),
                                                    if (widget.articleData['repeatcount'] !=
                                                            null &&
                                                        widget.articleData['repeatcount'] >
                                                            0)
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                              left: 4,
                                                            ),
                                                        child: Text(
                                                          "${widget.articleData['repeatcount']}",
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.green,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
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
                                    onTap: _NavigateToArticleDetail,
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
