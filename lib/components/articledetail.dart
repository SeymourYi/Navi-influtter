import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Navi/api/getarticleinfoAPI.dart';
import 'package:Navi/Store/storeutils.dart'; // 导入用户信息存储工具
import 'package:image_picker/image_picker.dart'; // 导入图片选择器
import 'dart:io'; // 导入File类
import 'articleimage.dart';
import '../components/userinfo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Articledetail extends StatefulWidget {
  final String id;
  final bool autoFocusComment;

  const Articledetail({
    super.key,
    required this.id,
    this.autoFocusComment = false,
  });

  @override
  State<Articledetail> createState() => _ArticledetailState();
}

class _ArticledetailState extends State<Articledetail> {
  bool _isLiked = false;
  int _likeCount = 42;
  bool _isBookmarked = false;
  var articleInfodata; // 改为不指定类型，以便适应不同的数据结构
  List<dynamic> commentsList = []; // 添加评论列表变量
  TextEditingController _commentController = TextEditingController(); // 评论输入控制器
  String? _selectedImagePath; // 选择的图片路径
  final ImagePicker _picker = ImagePicker(); // 图片选择器实例
  final FocusNode _commentFocusNode = FocusNode(); // 评论输入框焦点
  bool _isLoading = false; // 加载状态
  bool _isRepostLoading = false; // 转发加载状态
  TextEditingController _repostController = TextEditingController(); // 转发内容控制器
  String? _repostImagePath; // 选择的转发图片路径
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  // 当前用户信息
  Map<String, dynamic> _currentUser = {
    'id': 0,
    'username': '',
    'nickname': '用户',
    'userPic': '',
  };

  @override
  void initState() {
    super.initState();
    // 获取当前用户信息
    _loadCurrentUserInfo();

    if (widget.id != null && widget.id.isNotEmpty) {
      _fetchArticleInfo();
    }

    // 自动聚焦到评论框
    if (widget.autoFocusComment) {
      // 延迟执行以确保界面已构建完成
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_commentFocusNode);
      });
    }
  }

  @override
  void dispose() {
    // 释放资源
    _commentFocusNode.dispose();
    _commentController.dispose();
    _repostController.dispose();
    super.dispose();
  }

  // 加载当前用户信息
  Future<void> _loadCurrentUserInfo() async {
    final userInfo = await SharedPrefsUtils.getUserInfo();
    if (userInfo != null) {
      setState(() {
        _currentUser = userInfo;
      });
    }
  }

  Future<void> _fetchArticleInfo() async {
    if (widget.id == null || widget.id.isEmpty || _isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      GetArticleInfoService service = GetArticleInfoService();
      var result = await service.getArticleInfo(int.parse(widget.id));
      var result_comments = await service.getArticlecomment(
        int.parse(widget.id),
      );

      if (result != null && result['data'] != null) {
        setState(() {
          articleInfodata = result['data'];
        });
      }

      if (result_comments != null &&
          result_comments['code'] == 0 &&
          result_comments['data'] != null) {
        setState(() {
          commentsList = result_comments['data'];
        });
      }
    } catch (e) {
      // 错误提示
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('获取文章详情失败，请检查网络连接')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 选择图片方法
  Future<void> _pickImage() async {
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

  // 清除已选图片
  void _clearSelectedImage() {
    setState(() {
      _selectedImagePath = null;
    });
  }

  // 处理转发/引用帖子
  void _handleRepost() {
    if (_currentUser['id'] == 0) {
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
            builder: (context, setModalState) {
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
                                backgroundImage:
                                    articleInfodata != null &&
                                            articleInfodata['userPic'] !=
                                                null &&
                                            articleInfodata['userPic']
                                                .isNotEmpty
                                        ? NetworkImage(
                                          articleInfodata['userPic'],
                                        )
                                        : null,
                                child:
                                    articleInfodata == null ||
                                            articleInfodata['userPic'] ==
                                                null ||
                                            articleInfodata['userPic'].isEmpty
                                        ? Icon(Icons.person, size: 16)
                                        : null,
                              ),
                              SizedBox(width: 8),
                              Text(
                                articleInfodata != null
                                    ? articleInfodata['nickname'] ?? '用户'
                                    : '用户',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            articleInfodata != null
                                ? articleInfodata['content'] ?? ''
                                : '',
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
                    if (_repostImagePath != null)
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
                              File(_repostImagePath!),
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  _repostImagePath = null;
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
                          onPressed: () => _pickRepostImage(setModalState),
                        ),
                        Spacer(),
                        ElevatedButton(
                          onPressed:
                              _isRepostLoading
                                  ? null
                                  : () => _submitRepost(context),
                          child:
                              _isRepostLoading
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
          _repostImagePath = image.path;
        });
      }
    } catch (e) {
      print('图片选择失败: $e');
    }
  }

  // 提交转发
  Future<void> _submitRepost(BuildContext context) async {
    if (_currentUser['id'] == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('请先登录后再转发'), duration: Duration(seconds: 2)),
      );
      return;
    }

    setState(() {
      _isRepostLoading = true;
    });

    try {
      GetArticleInfoService service = GetArticleInfoService();

      // 确保我们使用的是正确的文章ID
      var articleId =
          widget.id != null
              ? widget.id.toString()
              : (articleInfodata != null && articleInfodata['id'] != null
                  ? articleInfodata['id'].toString()
                  : '');

      if (articleId.isEmpty) {
        throw Exception('文章ID不能为空');
      }

      var result = await service.addReapetArticle(
        beShareArticleId: articleId,
        content: _repostController.text,
        createUserId: _currentUser['id'],
        createUserName: _currentUser['username'],
        imagePath: _repostImagePath,
      );

      setState(() {
        _isRepostLoading = false;
        _repostController.clear();
        _repostImagePath = null;
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
        _isRepostLoading = false;
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
    // 提取文章内容，适应不同的数据结构
    String title = "";
    String content = "加载中...";
    String nickname = "用户";
    String username = "";
    String userPic = "";
    String categoryName = "";
    String coverImg = "";
    String createTime = "刚刚";
    int likecont = 0;
    bool isLike = false;
    int commentcount = 0;
    int repeatcount = 0;

    // 如果获取到了有效的文章数据，则使用API返回的数据
    if (articleInfodata != null) {
      try {
        if (articleInfodata is Map) {
          // 使用API返回的字段
          content = articleInfodata['content'] ?? content;
          nickname = articleInfodata['nickname'] ?? nickname;
          username = articleInfodata['username'] ?? username;
          userPic = articleInfodata['userPic'] ?? userPic;
          categoryName = articleInfodata['categoryName'] ?? categoryName;
          coverImg = articleInfodata['coverImg'] ?? coverImg;
          createTime = articleInfodata['createTime'] ?? createTime;
          likecont = articleInfodata['likecont'] ?? 0;
          isLike = articleInfodata['islike'] ?? false;
          commentcount = articleInfodata['commentcount'] ?? 0;
          repeatcount = articleInfodata['repeatcount'] ?? 0;
        }
      } catch (e) {
        // 错误处理
      }
    }

    // 整理图片URL列表
    List<String> imageUrls = [];
    if (coverImg != null && coverImg.isNotEmpty) {
      imageUrls.add(coverImg);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: categoryName.isNotEmpty ? Text(categoryName) : null,
        actions: [
          // 添加刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => _refreshIndicatorKey.currentState?.show(),
            tooltip: '刷新',
          ),
        ],
      ),
      body:
          _isLoading && articleInfodata == null
              ? _buildLoadingView()
              : RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _fetchArticleInfo,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    // User info row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Userinfo(),
                                ),
                              );
                            },
                            child:
                                userPic.isNotEmpty
                                    ? CircleAvatar(
                                      radius: 24,
                                      backgroundImage: NetworkImage(userPic),
                                    )
                                    : CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Colors.grey[300],
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nickname,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "@$username · ${_formatCreateTime(createTime)}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_horiz),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    // Article content
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        content,
                        style: TextStyle(fontSize: 16, height: 1.4),
                      ),
                    ),

                    // Images
                    if (imageUrls.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ArticleImage(imageUrls: imageUrls),
                      ),

                    // Stats and actions
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Text(
                            createTime,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          if (categoryName.isNotEmpty)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                categoryName,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildActionButton(
                            icon: Icons.mode_comment_outlined,
                            count: commentcount.toString(),
                            onPressed: () {
                              // 滚动到评论区
                              FocusScope.of(
                                context,
                              ).requestFocus(_commentFocusNode);
                            },
                          ),
                          _buildActionButton(
                            icon: Icons.repeat,
                            count: repeatcount.toString(),
                            onPressed: _handleRepost,
                          ),
                          _buildActionButton(
                            icon:
                                isLike ? Icons.favorite : Icons.favorite_border,
                            count: likecont.toString(),
                            isActive: isLike,
                            onPressed: () {
                              setState(() {
                                _isLiked = !_isLiked;
                                _likeCount += _isLiked ? 1 : -1;
                              });
                            },
                          ),
                          _buildActionButton(
                            icon:
                                _isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                            onPressed: () {
                              setState(() {
                                _isBookmarked = !_isBookmarked;
                              });
                            },
                            isActive: _isBookmarked,
                          ),
                          _buildActionButton(
                            icon: Icons.share,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // Replies section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${commentsList.length} 条评论",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (commentsList.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "暂无评论，快来发表你的看法吧！",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                            )
                          else
                            Column(
                              children:
                                  commentsList.map((comment) {
                                    return _buildReplyItem(
                                      userPic: comment['userPic'] ?? "",
                                      name: comment['nickname'] ?? "用户",
                                      handle: "@${comment['username'] ?? ''}",
                                      content: comment['content'] ?? "",
                                      time: comment['uptonowTime'] ?? "",
                                      likes: "${comment['likecont'] ?? 0}",
                                    );
                                  }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 显示选中的图片预览
            if (_selectedImagePath != null)
              Stack(
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
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
                      onTap: _clearSelectedImage,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  _currentUser['userPic'] != null &&
                          _currentUser['userPic'].isNotEmpty
                      ? CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage(_currentUser['userPic']),
                      )
                      : CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      focusNode: _commentFocusNode, // 使用焦点节点
                      decoration: InputDecoration(
                        hintText: "发表评论...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.image, color: Colors.green),
                              onPressed: _pickImage,
                            ),
                            IconButton(
                              icon: Icon(Icons.send, color: Colors.blue),
                              onPressed: _submitComment,
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
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    String? count,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.red : Colors.grey[600],
            ),
            if (count != null) ...[
              const SizedBox(width: 4),
              Text(
                count,
                style: TextStyle(
                  color: isActive ? Colors.red : Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReplyItem({
    required String userPic,
    required String name,
    required String handle,
    required String content,
    required String time,
    required String likes,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userPic.isNotEmpty
              ? CircleAvatar(radius: 20, backgroundImage: NetworkImage(userPic))
              : CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.grey[600]),
              ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 4),
                    Text(handle, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(width: 4),
                    Text("· $time", style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
                const SizedBox(height: 4),
                Text(content),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Icon(
                    //   Icons.favorite_border,
                    //   size: 16,
                    //   color: Colors.grey[600],
                    // ),
                    // const SizedBox(width: 4),
                    // Text(
                    //   likes,
                    //   style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 格式化时间方法
  String _formatCreateTime(String timeStr) {
    try {
      // 简单格式化，只返回月份和日期
      if (timeStr == null || timeStr.isEmpty) return "刚刚";

      DateTime dateTime = DateTime.parse(timeStr);
      DateTime now = DateTime.now();

      if (now.difference(dateTime).inMinutes < 60) {
        return "${now.difference(dateTime).inMinutes}分钟前";
      } else if (now.difference(dateTime).inHours < 24) {
        return "${now.difference(dateTime).inHours}小时前";
      } else if (now.difference(dateTime).inDays < 30) {
        return "${now.difference(dateTime).inDays}天前";
      } else {
        return "${dateTime.month}月${dateTime.day}日";
      }
    } catch (e) {
      print("日期格式化出错: $e");
      return timeStr;
    }
  }

  void _submitComment() {
    String commentText = _commentController.text.trim();
    if (commentText.isEmpty) {
      return;
    }

    // 准备评论所需参数
    Map<String, dynamic> commentParams = {
      'content': commentText,
      'categoryId': 1, // 固定分类ID为1
      'createUserId': _currentUser['id'],
      'createUserName': _currentUser['username'],
      'becomment_articleID': widget.id, // 被评论文章的ID
    };

    // 如果有选择图片，添加图片路径
    if (_selectedImagePath != null) {
      commentParams['imagePath'] = _selectedImagePath;
    }

    // 打印参数用于调试
    print('评论参数: $commentParams');

    // 调用API发送评论
    GetArticleInfoService service = GetArticleInfoService();
    service
        .postArticlecomment(commentParams)
        .then((response) {
          if (response != null && response['code'] == 0) {
            // 评论发送成功后，添加到本地列表显示
            setState(() {
              Map<String, dynamic> newComment = {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'username': _currentUser['username'],
                'nickname': _currentUser['nickname'],
                'userPic': _currentUser['userPic'],
                'content': commentText,
                'createTime': DateTime.now().toString(),
                'uptonowTime': '刚刚',
                'likecont': 0,
                // 如果有图片，保存图片信息
                if (_selectedImagePath != null)
                  'coverImg': response['data']['coverImg'] ?? '',
              };
              commentsList.insert(0, newComment);
              _selectedImagePath = null; // 清除已选图片
            });

            // 清空输入框并取消焦点
            _commentController.clear();
            FocusScope.of(context).unfocus();

            // 可以添加一个成功提示
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('评论发布成功！')));
          } else {
            // 处理评论发送失败情况
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('评论发布失败，请稍后重试')));
          }
        })
        .catchError((error) {
          print('评论发送错误: $error');
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('评论发送失败: $error')));
        });
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            '正在加载文章...',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
