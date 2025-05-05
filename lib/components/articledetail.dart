import 'package:Navi/api/articleAPI.dart';
import 'package:Navi/api/getarticleinfoAPI.dart';
import 'package:Navi/components/CommentWidget%20.dart';
import 'package:Navi/components/litarticle.dart';
import 'package:Navi/page/Home/articlelist.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'package:Navi/page/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'articleimage.dart';
import '../components/userinfo.dart';
import '../Store/storeutils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  Map<String, dynamic>? _currentUser; // 当前用户信息
  TextEditingController _repostController = TextEditingController(); // 转发内容控制器
  final ImagePicker _picker = ImagePicker(); // 图片选择器实例
  String? _selectedImagePath; // 选择的图片路径

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
      MaterialPageRoute(
        builder:
            (context) => PostPage(type: '转发', articelData: widget.articleData),
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
    return Scaffold(
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
            padding: EdgeInsets.only(top: 12, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息行 - 更紧凑的布局
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProfilePage(
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
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.articleData['nickname'] ?? '用户',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 1),
                          Row(
                            children: [
                              Text(
                                "@${widget.articleData['username'] ?? ''}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                " · ${widget.articleData['uptonowTime'] ?? ''}",
                                style: TextStyle(
                                  fontSize: 12,
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
                      onPressed: () {},
                    ),
                  ],
                ),

                // 文章内容区域 - 直接跟在用户信息下方
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 8),
                  child: Text(
                    widget.articleData['content'] ?? '',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.3,
                      color: Colors.black,
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
                        color: Color.fromRGBO(29, 161, 242, 1.0),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // 图片 - 紧贴内容
                if (widget.articleData['imageUrls'] != null &&
                    widget.articleData['imageUrls'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ArticleImage(
                        imageUrls: widget.articleData['imageUrls'],
                      ),
                    ),
                  ),

                if (widget.articleData['coverImg'] != "")
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ArticleImage(
                        imageUrls: ["${widget.articleData['coverImg']}"],
                      ),
                    ),
                  ),

                // 转发内容
                if (widget.articleData['userShare'] == true)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: LitArticle(articleData: widget.articleData),
                    ),
                  ),

                // 发布时间 - 更小的文字
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    "${widget.articleData['createTime'].substring(0, 4)}年${widget.articleData['createTime'].substring(5, 7)}月${widget.articleData['createTime'].substring(8, 10)}日 ${widget.articleData['createTime'].substring(11, 13)}:${widget.articleData['createTime'].substring(14, 16)}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 0.5, color: Colors.grey.shade200),

          // 互动统计 - 更紧凑的布局
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  "${widget.articleData['commentcount'] ?? '0'}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(29, 161, 242, 1.0),
                  ),
                ),
                Text(
                  " 评论",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Text(
                  "${widget.articleData['repeatcount'] ?? '0'}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(23, 191, 99, 1.0),
                  ),
                ),
                Text(
                  " 转发",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Text(
                  "${likeCount}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(224, 36, 94, 1.0),
                  ),
                ),
                Text(
                  " 喜欢",
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          Divider(height: 0.5, color: Colors.grey.shade200),

          // 交互按钮 - 更简洁的样式
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 评论按钮
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => PostPage(
                            type: '评论',
                            articelData: widget.articleData,
                          ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'lib/assets/icons/chatbubble-ellipses-outline.svg',
                        width: 16,
                        height: 16,
                        color:
                            widget.articleData['commentcount'] > 0
                                ? Color.fromRGBO(29, 161, 242, 1.0)
                                : Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        "评论",
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),

              // 转发按钮
              InkWell(
                onTap: _handleRepost,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'lib/assets/icons/repeat-outline.svg',
                        width: 16,
                        height: 16,
                        color:
                            widget.articleData['repeatcount'] > 0
                                ? Color.fromRGBO(23, 191, 99, 1.0)
                                : Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        "转发",
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),

              // 喜欢按钮
              InkWell(
                onTap: _handleLike,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
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
                      SizedBox(width: 4),
                      Text(
                        "喜欢",
                        style: TextStyle(
                          fontSize: 13,
                          color:
                              isLiked
                                  ? const Color.fromRGBO(224, 36, 94, 1.0)
                                  : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Divider(height: 0.5, color: Colors.grey.shade200),

          // 评论区域
          if (articleComments.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
                  child: Text(
                    "评论",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                CommentWidget(comments: articleComments),
              ],
            ),
        ],
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
}
