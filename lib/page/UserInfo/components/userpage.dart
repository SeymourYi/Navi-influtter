import 'package:Navi/components/full_screen_image_view.dart';
import 'package:Navi/utils/route_utils.dart';
import 'package:flutter/material.dart';
import 'package:Navi/components/article.dart';
import 'package:Navi/api/articleAPI.dart';
import 'package:Navi/Store/storeutils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Navi/api/userAPI.dart';
import 'package:Navi/page/chat/screen/chat_screen.dart';
import 'package:Navi/page/chat/screen/role_selection_screen.dart';

class ProfilePage extends StatefulWidget {
  final String? username;

  const ProfilePage({super.key, this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;
  List<dynamic> _articleList = [];
  final ScrollController _scrollController = ScrollController();
  bool _isCurrentUser = false;
  bool _isFriend = false;
  String? _currentUsername;
  bool _isFollowingLoading = false; // 关注操作加载状态
  static final Map<String, Map<String, dynamic>> _dataCache = {}; // 静态数据缓存

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadUserInfoFromCache(); // 先从缓存加载
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      if (userInfo != null && userInfo['username'] != null) {
        _currentUsername = userInfo['username'];
      }
    } catch (e) {
      print('加载当前用户信息失败: $e');
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '未知';
    }
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.year}年${date.month}月${date.day}日加入';
    } catch (e) {
      return dateString;
    }
  }

  void _NavigateToChat() async {
    if (widget.username == null || _userInfo == null) return;

    await Navigator.push(
      context,
      RouteUtils.slideFromRight(ChatScreen()),
    );
  }

  Future<void> _checkFriendStatus() async {
    if (_currentUsername == null || widget.username == null || _isCurrentUser) {
      return;
    }

    try {
      UserService userService = UserService();
      var result = await userService.whetherfriend(
        _currentUsername!,
        widget.username!,
      );

      if (result != null && result['code'] == 0) {
        setState(() {
          _isFriend = result['data'] == "1";
        });
      }
    } catch (e) {
      print('检查朋友关系失败: $e');
    }
  }

  /// 从缓存加载用户信息
  Future<void> _loadUserInfoFromCache() async {
    final cacheKey = widget.username ?? 'current_user';
    
    // 如果缓存中有数据，先使用缓存数据
    if (_dataCache.containsKey(cacheKey)) {
      final cachedData = _dataCache[cacheKey]!;
      setState(() {
        _userInfo = cachedData['userInfo'];
        _isCurrentUser = cachedData['isCurrentUser'] ?? false;
        _isFriend = cachedData['isFriend'] ?? false;
        _articleList = cachedData['articleList'] ?? [];
        _isLoading = false;
      });
      // 后台刷新数据
      _loadUserInfo();
      return;
    }
    
    // 缓存中没有数据，正常加载
    await _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      UserService userService = UserService();
      final cacheKey = widget.username ?? 'current_user';

      if (widget.username == null) {
        final userInfo = await SharedPrefsUtils.getUserInfo();

        setState(() {
          _userInfo = userInfo;
          _isLoading = false;
          _isCurrentUser = true;
        });
        
        // 更新缓存（保留已有的文章列表）
        _dataCache[cacheKey] = {
          'userInfo': userInfo,
          'isCurrentUser': true,
          'isFriend': false,
          'articleList': _dataCache[cacheKey]?['articleList'] ?? [],
        };
      } else {
        var result = await userService.getsomeUserinfo(widget.username!);
        if (result['code'] == 0 && result['data'] != null) {
          setState(() {
            _userInfo = result['data'];
            _isLoading = false;
          });

          final currentUser = await SharedPrefsUtils.getUserInfo();
          bool isCurrentUserFlag = false;
          if (currentUser != null &&
              currentUser['username'] == widget.username) {
            setState(() {
              _isCurrentUser = true;
            });
            isCurrentUserFlag = true;
          } else {
            await _checkFriendStatus();
          }
          
          // 更新缓存（保留已有的文章列表）
          _dataCache[cacheKey] = {
            'userInfo': result['data'],
            'isCurrentUser': isCurrentUserFlag,
            'isFriend': _isFriend,
            'articleList': _dataCache[cacheKey]?['articleList'] ?? [],
          };
        } else {
          throw Exception('获取用户信息失败');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('加载用户信息出错: $e');
    }

    _fetchArticleList();
  }

  Future<void> _fetchArticleList() async {
    if (_userInfo == null) return;
    
    ArticleService service = ArticleService();
    final cacheKey = widget.username ?? 'current_user';
    
    try {
      // 获取用户ID
      int userId = 1; // 默认ID

      if (_userInfo!['id'] != null) {
        userId = _userInfo!['id'];
      }
      
      var result = await service.getsomebodyArticleList(_userInfo!['username']);
      if (result['code'] == 0 && result['data'] != null) {
        setState(() {
          _articleList = result['data'];
        });
        
        // 更新缓存中的文章列表
        if (_dataCache.containsKey(cacheKey)) {
          _dataCache[cacheKey]!['articleList'] = result['data'];
        }
      }
    } catch (e) {
      print('获取文章列表失败: $e');
    }
  }

  // 处理关注/取关操作
  Future<void> _handleFollowAction() async {
    if (_currentUsername == null || widget.username == null || _isCurrentUser) {
      return;
    }

    setState(() {
      _isFollowingLoading = true;
    });

    try {
      UserService userService = UserService();
      
      // 如果是已关注状态，显示确认对话框
      if (_isFriend) {
        bool? confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text('确认取关'),
              content: Text('确定要取消关注 ${_userInfo?['nickname'] ?? '该用户'} 吗？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('确定'),
                ),
              ],
            );
          },
        );

        if (confirm != true) {
          setState(() {
            _isFollowingLoading = false;
          });
          return;
        }
      }

      // 调用关注/取关API
      var result = await userService.followOrUnfollowUser(
        currentUsername: _currentUsername!,
        targetUsername: widget.username!,
      );

      if (result != null && result['code'] == 0) {
        // 操作成功，更新朋友状态
        setState(() {
          _isFriend = !_isFriend;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFriend ? '已关注' : '已取消关注'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result?['msg'] ?? '操作失败，请稍后重试'),
          ),
        );
      }
    } catch (e) {
      print('关注操作失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isFollowingLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Profile Header
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Image
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 背景图
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(color: Colors.grey[200]),
                            child: _userInfo != null &&
                                    _userInfo!['bgImg'] != null &&
                                    _userInfo!['bgImg'].toString().isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: _userInfo!['bgImg'],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.green[100]!,
                                          Colors.orange[100]!,
                                          Colors.yellow[100]!,
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.landscape,
                                      size: 30,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),

                          // 返回按钮 - 左上角（推特风格）
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 8,
                            left: 8,
                            child: Material(
                              color: Colors.black.withOpacity(0.5),
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 更多操作按钮 - 右上角（确保不重叠）
                          Positioned(
                            top: MediaQuery.of(context).padding.top + 8,
                            right: 8,
                            child: Material(
                              color: Colors.black.withOpacity(0.5),
                              shape: const CircleBorder(),
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 头像和操作按钮 - 定位在背景图底部
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: -40,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // 头像 - 方形圆角
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        RouteUtils.slideFromRight(
                                          FullScreenImageView(
                                            imageUrls: [_userInfo!['userPic']],
                                            initialIndex: 0,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Container(
                                        width: 65,
                                        height: 65,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: _userInfo != null &&
                                                _userInfo!['userPic'] != null &&
                                                _userInfo!['userPic']
                                                    .toString()
                                                    .isNotEmpty
                                            ? CachedNetworkImage(
                                                imageUrl: _userInfo!['userPic'],
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(
                                                  Icons.person,
                                                  size: 32,
                                                  color: Colors.grey,
                                                ),
                                              )
                                            : Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 32,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),

                                  // 操作按钮 - 推特风格
                                  _isCurrentUser
                                      ? SizedBox.shrink() // 如果是自身界面，不显示按钮
                                      : Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Colors.black87,
                                          ),
                                          child: TextButton(
                                            onPressed: _isFollowingLoading ? null : _handleFollowAction,
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 8),
                                            ),
                                            child: _isFollowingLoading
                                                ? SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                    ),
                                                  )
                                                : Text(
                                                    _isFriend ? '已关注' : '关注',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 用户信息区域 - 推特风格
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 50, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 用户名和认证
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _userInfo != null
                                        ? _userInfo!['nickname'] ?? '用户'
                                        : "加载中...",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                if (_userInfo != null &&
                                    _userInfo!['isVerified'] == true)
                                  Icon(
                                    Icons.verified,
                                    size: 18,
                                    color: Color(0xFF6201E7),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _userInfo != null
                                  ? "@${_userInfo!['username']}"
                                  : "@加载中...",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 个人简介
                            if (_userInfo != null &&
                                _userInfo!['bio'] != null &&
                                _userInfo!['bio'].toString().isNotEmpty)
                              Text(
                                _userInfo!['bio'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                            if (_userInfo != null &&
                                _userInfo!['bio'] != null &&
                                _userInfo!['bio'].toString().isNotEmpty)
                              const SizedBox(height: 12),

                            // 地点和加入日期
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                if (_userInfo != null &&
                                    _userInfo!['location'] != null &&
                                    _userInfo!['location'].toString().isNotEmpty)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _userInfo!['location'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                if (_userInfo != null &&
                                    _userInfo!['createTime'] != null)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(_userInfo!['createTime']),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),

                      // 分割线
                      Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Colors.grey.shade200,
                      ),

                      // 动态列表
                      if (_articleList.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Text(
                              '暂无动态',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                      else
                        ...(_articleList.asMap().entries.map((entry) {
                          int index = entry.key;
                          dynamic articleData = entry.value;
                          return Column(
                            children: [
                              Article(articleData: articleData),
                              if (index < _articleList.length - 1)
                                Divider(
                                  height: 1,
                                  thickness: 0.5,
                                  color: Colors.grey.shade200,
                                ),
                            ],
                          );
                        }).toList()),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  const _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
