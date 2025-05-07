import 'package:Navi/components/full_screen_image_view.dart';
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

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadUserInfo();
    // _fetchArticleList();
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

  void _NavigateToChat() async {
    if (widget.username == null || _userInfo == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ChatScreen(
              // initialChatUsername: widget.username,
              // initialChatName: _userInfo!['nickname'] ?? widget.username,
              // initialChatAvatar: _userInfo!['userPic'] ?? '',
              // initialChatBio: _userInfo!['bio'] ?? '',
            ),
      ),
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

  Future<void> _loadUserInfo() async {
    try {
      UserService userService = UserService();

      if (widget.username == null) {
        final userInfo = await SharedPrefsUtils.getUserInfo();

        setState(() {
          _userInfo = userInfo;
          _isLoading = false;
          _isCurrentUser = true;
        });
      } else {
        var result = await userService.getsomeUserinfo(widget.username!);
        if (result['code'] == 0 && result['data'] != null) {
          setState(() {
            _userInfo = result['data'];
            _isLoading = false;
          });

          final currentUser = await SharedPrefsUtils.getUserInfo();
          if (currentUser != null &&
              currentUser['username'] == widget.username) {
            setState(() {
              _isCurrentUser = true;
            });
          } else {
            await _checkFriendStatus();
          }
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
    ArticleService service = ArticleService();
    print("11111111111");
    print(_userInfo);
    print("122222222111");
    try {
      // 获取用户ID
      int userId = 1; // 默认ID

      if (_userInfo != null && _userInfo!['id'] != null) {
        userId = _userInfo!['id'];
      } else if (widget.username != null) {
        // 如果有用户名但没有用户信息，先等待用户信息加载
        await _loadUserInfo();
        if (_userInfo != null && _userInfo!['id'] != null) {
          userId = _userInfo!['id'];
        }
      }
      var result = await service.getsomebodyArticleList(_userInfo!['username']);
      if (result['code'] == 0 && result['data'] != null) {
        setState(() {
          _articleList = result['data'];
        });
      }
    } catch (e) {
      print('获取文章列表失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                children: [
                  // 顶部背景和头像部分
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 背景图
                      Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.grey[200]),
                        child:
                            _userInfo != null && _userInfo!['bgImg'].isNotEmpty
                                ? CachedNetworkImage(
                                  imageUrl: _userInfo!['bgImg'],
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Image.asset(
                                        "lib/assets/images/4.jpg",
                                        fit: BoxFit.cover,
                                      ),
                                  errorWidget:
                                      (context, url, error) => Image.asset(
                                        "lib/assets/images/4.jpg",
                                        fit: BoxFit.cover,
                                      ),
                                )
                                : Image.asset(
                                  "lib/assets/images/4.jpg",
                                  fit: BoxFit.cover,
                                ),
                      ),

                      // 返回按钮 - 左上角
                      Positioned(
                        left: 8,
                        top: 8,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),

                      // 操作按钮
                      Positioned(
                        right: 8,
                        top: 8,
                        child: IconButton(
                          icon: const Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),

                      // 头像和编辑资料按钮 - 定位在背景图底部
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -40, // 向下偏移使其部分显示在背景图外
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // 头像
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => FullScreenImageView(
                                            // imageUrls: List.from(
                                            //   _userinfo["userPic"],
                                            // ),
                                            imageUrls: [_userInfo!['userPic']],
                                            initialIndex: 0,
                                          ),
                                    ),
                                  );
                                },
                                child: Material(
                                  elevation: 4,
                                  shape: const CircleBorder(),
                                  clipBehavior: Clip.antiAlias,
                                  child: CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.white,
                                    child:
                                        _userInfo != null &&
                                                _userInfo!['userPic'].isNotEmpty
                                            ? CircleAvatar(
                                              radius: 38,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                    _userInfo!['userPic'],
                                                  ),
                                            )
                                            : const CircleAvatar(
                                              radius: 38,
                                              backgroundImage: AssetImage(
                                                "lib/assets/images/1.jpg",
                                              ),
                                            ),
                                  ),
                                ),
                              ),

                              // Material(
                              //   elevation: 4,
                              //   shape: const CircleBorder(),
                              //   clipBehavior: Clip.antiAlias,
                              //   child: CircleAvatar(
                              //     radius: 40,
                              //     backgroundColor: Colors.white,
                              //     child:
                              //         _userInfo != null &&
                              //                 _userInfo!['userPic'].isNotEmpty
                              //             ? CircleAvatar(
                              //               radius: 38,
                              //               backgroundImage:
                              //                   CachedNetworkImageProvider(
                              //                     _userInfo!['userPic'],
                              //                   ),
                              //             )
                              //             : const CircleAvatar(
                              //               radius: 38,
                              //               backgroundImage: AssetImage(
                              //                 "lib/assets/images/1.jpg",
                              //               ),
                              //             ),
                              //   ),
                              // ),

                              // 编辑资料按钮
                              _isCurrentUser
                                  ? Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.blue,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white, // 添加白色背景确保可见性
                                    ),
                                    child: TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        '编辑资料',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  )
                                  : Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color:
                                            _isFriend
                                                ? Colors.grey
                                                : Colors.blue,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      color:
                                          _isFriend
                                              ? Colors.grey[300]
                                              : Colors.white,
                                    ),
                                    child: TextButton(
                                      onPressed: null, // 按照要求不实现关注功能
                                      child: Text(
                                        _isFriend ? '已关注' : '关注',
                                        style: TextStyle(
                                          color:
                                              _isFriend
                                                  ? Colors.black
                                                  : Colors.blue,
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

                  // 用户信息区域
                  Container(
                    padding: const EdgeInsets.only(
                      top: 50, // 增加顶部padding为头像预留空间
                      left: 16,
                      right: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 用户名和其他信息
                        Text(
                          _userInfo != null ? _userInfo!['nickname'] : "加载中...",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userInfo != null
                              ? "@${_userInfo!['username']}"
                              : "@加载中...",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 个人简介
                        Text(
                          _userInfo != null ? _userInfo!['bio'] : "加载中...",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),

                        // 地点和加入日期
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _userInfo != null
                                  ? _userInfo!['location']
                                  : "加载中...",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _userInfo != null &&
                                      _userInfo!['createTime'] != null
                                  ? "加入于 ${_userInfo!['createTime'].substring(0, 10)}"
                                  : "加入时间未知",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 关注和粉丝
                        Row(
                          children: [
                            Text(
                              "542 ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              "关注",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              "12.8K ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              "粉丝",
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const Spacer(),
                            // 添加私聊按钮 - 只为非当前用户显示
                            //   if (!_isCurrentUser && widget.username != null)
                            //     Container(
                            //       decoration: BoxDecoration(
                            //         color: Colors.blue.withOpacity(0.1),
                            //         borderRadius: BorderRadius.circular(20),
                            //         border: Border.all(
                            //           color: Colors.blue,
                            //           width: 1,
                            //         ),
                            //       ),
                            //       child: TextButton.icon(
                            //         icon: const Icon(
                            //           Icons.chat_bubble_outline,
                            //           color: Colors.blue,
                            //           size: 16,
                            //         ),
                            //         label: const Text(
                            //           '私聊',
                            //           style: TextStyle(
                            //             color: Colors.blue,
                            //             fontSize: 14,
                            //           ),
                            //         ),
                            //         onPressed: _NavigateToChat,
                            //       ),
                            //     ),
                            // ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 分割线
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 0),
                    child: Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Colors.grey[300],
                    ),
                  ),

                  // 动态列表
                  for (
                    int i = 0;
                    i < (_articleList.isEmpty ? 1 : _articleList.length);
                    i++
                  )
                    i == 0
                        ? Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 2),
                          child:
                              _articleList.isNotEmpty
                                  ? Article(articleData: _articleList[i])
                                  : const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                        )
                        : Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 2),
                          child: Article(articleData: _articleList[i]),
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
