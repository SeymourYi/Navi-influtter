import 'package:Navi/components/litarticle.dart';
import 'package:Navi/page/UserInfo/userhome.dart';
import 'package:Navi/page/post/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'package:provider/provider.dart';
import 'package:Navi/utils/route_utils.dart';
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
  ArticleService articleService = ArticleService();
  
  @override
  void initState() {
    super.initState();
    // 直接使用API返回的点赞状态数据（后台接口已更新，islike: true 表示已点赞）
    if (widget.articleData != null) {
      // 处理 islike 字段，可能是布尔值或字符串
      final islikeValue = widget.articleData['islike'];
      if (islikeValue is bool) {
        isLiked = islikeValue;
      } else if (islikeValue is String) {
        isLiked = islikeValue.toLowerCase() == 'true' || islikeValue == '1';
      } else {
        isLiked = false;
      }
      
      // 处理点赞数量
      final likecontValue = widget.articleData['likecont'];
      if (likecontValue is int) {
        likeCount = likecontValue;
      } else if (likecontValue is String) {
        likeCount = int.tryParse(likecontValue) ?? 0;
      } else {
        likeCount = 0;
      }
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

  // 创建支持手势返回的滑动路由（使用RouteUtils统一管理）
  PageRoute _createSlideRoute(Widget page) {
    return RouteUtils.slideFromRight(page);
  }

  void _NavigateToArticleDetail({bool focusOnComment = false}) {
    // 检查文章ID是否存在
    if (widget.articleData == null || widget.articleData['id'] == null) {
      return;
    }

    String articleId = "${widget.articleData['id']}";

    Navigator.push(
      context,
      _createSlideRoute(Articledetail(articleData: widget.articleData)),
    ).then((_) {
      // 从详情页返回后，刷新点赞状态
      if (widget.articleData != null) {
        setState(() {
          // 重新读取点赞状态（从详情页返回后可能已更新）
          final islikeValue = widget.articleData['islike'];
          if (islikeValue is bool) {
            isLiked = islikeValue;
          } else if (islikeValue is String) {
            isLiked = islikeValue.toLowerCase() == 'true' || islikeValue == '1';
          } else {
            isLiked = false;
          }
          
          // 重新读取点赞数量
          final likecontValue = widget.articleData['likecont'];
          if (likecontValue is int) {
            likeCount = likecontValue;
          } else if (likecontValue is String) {
            likeCount = int.tryParse(likecontValue) ?? 0;
          } else {
            likeCount = 0;
          }
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

    // 使用PostPage页面进行转发
    Navigator.push(
      context,
      RouteUtils.slideFromBottom(PostPage(type: '转发', articelData: widget.articleData)),
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
    return InkWell(
      onTap: () {
        _NavigateToArticleDetail();
      },
      splashColor: Colors.grey[100],
      highlightColor: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧头像
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  RouteUtils.slideFromRight(UserHome(userId: widget.articleData['username'])),
                );
              },
              child: CircleAvatar(
                radius: 24,
                backgroundImage: CachedNetworkImageProvider(
                  widget.articleData['userPic'],
                ),
              ),
            ),

            // 右侧内容部分
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 用户信息行
                    Row(
                      children: [
                        // 用户名
                        Flexible(
                          child: Text(
                            "${widget.articleData['nickname'] ?? '用户'}",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: 4),
                        // 认证标志
                        if (widget.articleData['isVerified'] == true ||
                            widget.articleData['verified'] == true)
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Color(0xFF6201E7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        SizedBox(width: 6),
                        // 账号句柄
                        if (widget.articleData['username'] != null)
                          Flexible(
                            flex: 1,
                            child: Text(
                              "@${widget.articleData['username']}",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        SizedBox(width: 8),
                        // 时间戳
                        Text(
                          widget.articleData["uptonowTime"] ?? "",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4),

                    // 文章内容
                    Padding(
                      padding: const EdgeInsets.only(top: 0, bottom: 6),
                      child: Text(
                        "${widget.articleData['content'] ?? ''}",
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                        maxLines: null,
                      ),
                    ),

                    // 文章图片 - 支持多张图片
                    if (widget.articleData['coverImg'] != null &&
                        widget.articleData['coverImg'].toString().isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 8, right: 10, bottom: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ArticleImage(
                            imageUrls: widget.articleData['coverImgList'] != null &&
                                    widget.articleData['coverImgList'] is List &&
                                    (widget.articleData['coverImgList'] as List).isNotEmpty
                                ? List<String>.from(widget.articleData['coverImgList'])
                                : [widget.articleData['coverImg'].toString()],
                          ),
                        ),
                      ),

                    // 转发内容
                    if (widget.articleData['userShare'] == true)
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: LitArticle(articleData: widget.articleData),
                      ),

                    // 推特风格的操作栏
                    Padding(
                      padding: EdgeInsets.only(top: 8, right: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // 评论按钮
                          _buildTwitterActionButton(
                            icon: Icons.mode_comment_outlined,
                            count: widget.articleData['commentcount'] ?? 0,
                            color: Colors.grey[600]!, // 灰色
                            onTap: () {
                              Navigator.push(
                                context,
                                RouteUtils.slideFromBottom(PostPage(
                                  type: '评论',
                                  articelData: widget.articleData,
                                )),
                              );
                            },
                          ),
                          // 转发按钮
                          _buildTwitterActionButton(
                            icon: Icons.repeat_outlined,
                            count: widget.articleData['repeatcount'] ?? 0,
                            color: Colors.grey[600]!, // 灰色
                            onTap: () {
                              _handleRepost();
                            },
                          ),
                          // 点赞按钮
                          _buildTwitterActionButton(
                            icon: isLiked ? Icons.favorite : Icons.favorite_border,
                            count: likeCount,
                            color: isLiked
                                ? Color.fromRGBO(224, 36, 94, 1.0) // 已点赞时红色
                                : Colors.grey[600]!, // 未点赞时灰色
                            onTap: () {
                              _handleLike();
                            },
                            isLoading: isLikeLoading,
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
    );
  }

  // 推特风格的操作按钮
  Widget _buildTwitterActionButton({
    required IconData icon,
    required int count,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.15),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                )
              else
                Icon(
                  icon,
                  size: 18.5,
                  color: color,
                ),
              SizedBox(width: 6),
              Text(
                _formatCount(count),
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 格式化数字显示（类似推特：1K, 1M等）
  String _formatCount(int count) {
    if (count >= 1000000) {
      double m = count / 1000000;
      return m % 1 == 0 ? '${m.toInt()}M' : '${m.toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      double k = count / 1000;
      return k % 1 == 0 ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
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
