import 'package:Navi/api/articleAPI.dart';
import 'package:Navi/api/getarticleinfoAPI.dart';
import 'package:Navi/components/CommentWidget%20.dart';
import 'package:Navi/components/litarticle.dart';
import 'package:Navi/page/Home/articlelist.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'package:Navi/page/post/post.dart';
import 'package:Navi/utils/route_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'articleimage.dart';
import '../components/userinfo.dart';
import '../Store/storeutils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// 支持手势返回的包装组件（带平滑动画）
class _GestureWrapper extends StatefulWidget {
  final Widget child;

  const _GestureWrapper({required this.child});

  @override
  State<_GestureWrapper> createState() => _GestureWrapperState();
}

class _GestureWrapperState extends State<_GestureWrapper>
    with SingleTickerProviderStateMixin {
  double _dragStartX = 0.0;
  double _dragOffset = 0.0;
  bool _isDragging = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 缩短回弹动画时长，使手势反馈更灵敏
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragEnd(double velocity) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dragProgress = _dragOffset / screenWidth;

    // 如果拖动超过屏幕宽度的12%或速度足够，则触发返回
    // 降低比例和速度阈值以提高滑动灵敏度
    if (dragProgress > 0.12 || velocity > 200) {
      Navigator.pop(context);
    } else {
      // 否则回弹到原位置
      final startOffset = _dragOffset;
      _controller.reset();
      _controller.forward();

      void listener() {
        if (mounted) {
          setState(() {
            _dragOffset = startOffset * (1 - _controller.value);
          });
        }
      }

      void statusListener(AnimationStatus status) {
        if (status == AnimationStatus.completed && mounted) {
          _controller.removeListener(listener);
          _controller.removeStatusListener(statusListener);
          setState(() {
            _dragOffset = 0.0;
            _isDragging = false;
          });
          _controller.reset();
        }
      }

      _controller.addListener(listener);
      _controller.addStatusListener(statusListener);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onHorizontalDragStart: (details) {
        // 只允许从左侧边缘开始拖动。扩大起始区域以提高灵敏度（30 -> 80像素）。
        if (details.globalPosition.dx <= 80) {
          _dragStartX = details.globalPosition.dx;
          _isDragging = true;
          _controller.reset();
        }
      },
      onHorizontalDragUpdate: (details) {
        if (!_isDragging) return;

        final currentX = details.globalPosition.dx;
        final deltaX = currentX - _dragStartX;

        // 只允许向右拖动
        if (deltaX > 0) {
          setState(() {
            _dragOffset = deltaX.clamp(0.0, screenWidth);
          });
        }
      },
      onHorizontalDragEnd: (details) {
        if (!_isDragging) return;
        _handleDragEnd(details.velocity.pixelsPerSecond.dx);
      },
      child: Transform.translate(
        offset: Offset(_dragOffset, 0),
        child: widget.child,
      ),
    );
  }
}

class Articledetail extends StatefulWidget {
  const Articledetail({super.key, this.articleData});
  final dynamic articleData;

  @override
  State<Articledetail> createState() => _ArticledetailState();
}

class _ArticledetailState extends State<Articledetail> {
  ArticleService service = ArticleService();
  List<dynamic> articleComments = [];
  bool isLiked = false;
  int likeCount = 0;
  String username = ''; // 存储当前用户名
  bool isLikeLoading = false; // 点赞加载状态
  bool isRepostLoading = false; // 转发加载状态
  bool isDeleteLoading = false; // 删除加载状态
  Map<String, dynamic>? _currentUser; // 当前用户信息
  TextEditingController _repostController = TextEditingController(); // 转发内容控制器
  final ImagePicker _picker = ImagePicker(); // 图片选择器实例
  String? _selectedImagePath; // 选择的图片路径
  bool _isCurrentUserArticle = false; // 是否是当前用户的文章

  @override
  void initState() {
    super.initState();
    getarticleComments();

    // 初始化点赞状态
    if (widget.articleData != null) {
      isLiked = widget.articleData['islike'] ?? false;
      likeCount = widget.articleData['likecont'] ?? 0;
    }
    // 获取当前用户信息
    _loadCurrentUserInfo();
    // 检查是否是当前用户的文章
    _checkIfCurrentUserArticle();
  }

  // 检查是否是当前用户的文章
  void _checkIfCurrentUserArticle() {
    if (widget.articleData != null && username.isNotEmpty) {
      setState(() {
        _isCurrentUserArticle = widget.articleData['username'] == username;
      });
    }
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
        // 检查是否是当前用户的文章
        _checkIfCurrentUserArticle();
      }
    } catch (e) {}
  }

  void getarticleComments() async {
    final result = await ArticleService().getArticleComments(
      int.parse(widget.articleData['id']),
    );
    setState(() {
      articleComments = result['data'];
    });
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
      // 使用新的API调用
      var result = await service.likeArticle(
        username: username,
        articleId: int.parse(widget.articleData['id'].toString()),
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

  // 处理转发/引用帖子
  void _handleRepost() {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先登录后再转发'), duration: Duration(seconds: 2)),
      );
      return;
    }

    // 使用PostPage页面进行转发，与article.dart中完全一致
    Navigator.push(
      context,
      RouteUtils.slideFromBottom(
        PostPage(type: '转发', articelData: widget.articleData),
      ),
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

  void _navigatetoarticledetail() {
    // 检查文章ID是否存在
    // if (widget.articleData == null || widget.articleData['id'] == null) {
    //   return;
    // }

    // String beShareArticleId = "${widget.articleData['beShareArticleId']}";
    //得到文章详情
    // final result = await ArticleService().getArticleDetail(beShareArticleId);

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => Articledetail(articleData: result['data']),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return _GestureWrapper(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title:
              widget.articleData['categoryName'] != null &&
                      widget.articleData['categoryName'].isNotEmpty
                  ? Text(
                    widget.articleData['categoryName'],
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : null,
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(1.0),
            child: Container(height: 0.5, color: Colors.grey.shade200),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            // 用户信息和文章内容容器
            Container(
              padding: EdgeInsets.only(
                top: 12,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 用户信息行 - 推特风格
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        child:
                            widget.articleData['userPic'] != null &&
                                    widget.articleData['userPic'].isNotEmpty
                                ? CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                    widget.articleData['userPic'],
                                  ),
                                )
                                : CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey[300],
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey[600],
                                  ),
                                ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.articleData['nickname'] ?? '用户',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(width: 4),
                                if (widget.articleData['isVerified'] == true)
                                  Icon(
                                    Icons.verified,
                                    size: 16,
                                    color: Color(0xFF6201E7),
                                  ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  "@${widget.articleData['username'] ?? ''}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  " · ${widget.articleData['uptonowTime'] ?? ''}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        icon: Icon(
                          Icons.more_horiz,
                          size: 20,
                          color: Colors.grey[700],
                        ),
                        onPressed: () {
                          _showArticleMenu();
                        },
                      ),
                    ],
                  ),

                  // 文章内容区域 - 推特风格
                  Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 12),
                    child: Text(
                      widget.articleData['content'] ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.black87,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),

                  // 分类标签（如果有）
                  if (widget.articleData['categoryName'] != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        "#${widget.articleData['categoryName']}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6201E7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // 图片 - 推特风格
                  if (widget.articleData['imageUrls'] != null &&
                      widget.articleData['imageUrls'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ArticleImage(
                          imageUrls: widget.articleData['imageUrls'],
                        ),
                      ),
                    ),

                  if (widget.articleData['coverImg'] != "")
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ArticleImage(
                          imageUrls: List<String>.from(
                            widget.articleData['coverImgList'],
                          ),
                        ),
                      ),
                    ),

                  // 转发内容 - 推特风格
                  if (widget.articleData['userShare'] == true)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: LitArticle(articleData: widget.articleData),
                      ),
                    ),

                  // 发布时间 - 推特风格
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      "${widget.articleData['createTime'].substring(0, 4)}年${widget.articleData['createTime'].substring(5, 7)}月${widget.articleData['createTime'].substring(8, 10)}日 ${widget.articleData['createTime'].substring(11, 13)}:${widget.articleData['createTime'].substring(14, 16)}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 0.5, color: Colors.grey.shade200),

            // 互动统计 - 推特风格
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    "${widget.articleData['commentcount'] ?? '0'}",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    " 评论",
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    "${widget.articleData['repeatcount'] ?? '0'}",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    " 转发",
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    "${likeCount}",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    " 喜欢",
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            Divider(height: 0.5, color: Colors.grey.shade200),

            // 交互按钮 - 推特风格
            Container(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // 评论按钮
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        RouteUtils.slideFromBottom(
                          PostPage(type: '评论', articelData: widget.articleData),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'lib/assets/icons/chatbubble-ellipses-outline.svg',
                            width: 18,
                            height: 18,
                            color: Colors.grey[700],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 转发按钮
                  InkWell(
                    onTap: _handleRepost,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'lib/assets/icons/repeat-outline.svg',
                            width: 18,
                            height: 18,
                            color: Colors.grey[700],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 喜欢按钮
                  InkWell(
                    onTap: _handleLike,
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          isLikeLoading
                              ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color.fromRGBO(224, 36, 94, 1.0),
                                  ),
                                ),
                              )
                              : Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color:
                                    isLiked
                                        ? const Color.fromRGBO(224, 36, 94, 1.0)
                                        : Colors.grey[700],
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 0.5, color: Colors.grey.shade200),

            // 评论区域 - 推特风格
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 16, bottom: 12),
                  child: Text(
                    articleComments.isNotEmpty ? "评论" : "暂无评论",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (articleComments.isNotEmpty)
                  CommentWidget(
                    comments: articleComments,
                    uparticledata: widget.articleData,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required Widget icon, required String count}) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 4),
        Text(count, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  // 显示文章菜单
  void _showArticleMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isCurrentUserArticle) ...[
                ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('删除文章', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteArticle();
                  },
                ),
                Divider(height: 1),
              ],
              if (!_isCurrentUserArticle) ...[
                ListTile(
                  leading: Icon(Icons.flag_outlined, color: Colors.grey[700]),
                  title: Text('举报'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('举报功能开发中...')));
                  },
                ),
                Divider(height: 1),
              ],
              ListTile(
                leading: Icon(Icons.close, color: Colors.grey[700]),
                title: Text('取消'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // 确认删除文章
  void _confirmDeleteArticle() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('确认删除'),
          content: Text('确定要删除这篇文章吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteArticle();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('删除'),
            ),
          ],
        );
      },
    );
  }

  // 删除文章
  Future<void> _deleteArticle() async {
    if (widget.articleData == null || widget.articleData['id'] == null) {
      return;
    }

    setState(() {
      isDeleteLoading = true;
    });

    try {
      var result = await service.deleteArticle(
        int.parse(widget.articleData['id'].toString()),
      );

      if (result != null && result['code'] == 0) {
        // 删除成功，返回上一页
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('文章已删除')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result?['msg'] ?? '删除失败，请稍后重试')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('删除失败: ${e.toString()}')));
    } finally {
      if (mounted) {
        setState(() {
          isDeleteLoading = false;
        });
      }
    }
  }
}
