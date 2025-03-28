import 'package:flutter/material.dart';
import 'package:flutterlearn2/components/article.dart';
import 'package:flutterlearn2/page/Home/articlelist.dart';
import 'package:flutterlearn2/Store/storeutils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      setState(() {
        _userInfo = userInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('加载用户信息出错: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    // 头部区域（固定不滚动）
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 背景图片
                        Container(
                          height: 200,
                          width: double.infinity,
                          child:
                              _userInfo != null &&
                                      _userInfo!['bgImg'].isNotEmpty
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
                        // 返回按钮
                        Positioned(
                          top: 40,
                          left: 16,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        // 更多按钮
                        Positioned(
                          top: 40,
                          right: 16,
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        // 头像
                        Positioned(
                          bottom: -50,
                          left: 16,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child:
                                _userInfo != null &&
                                        _userInfo!['userPic'].isNotEmpty
                                    ? CircleAvatar(
                                      radius: 48,
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                            _userInfo!['userPic'],
                                          ),
                                    )
                                    : const CircleAvatar(
                                      radius: 48,
                                      backgroundImage: AssetImage(
                                        "lib/assets/images/1.jpg",
                                      ),
                                    ),
                          ),
                        ),
                        // 编辑资料按钮
                        Positioned(
                          bottom: -25,
                          right: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.blue, width: 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                '编辑资料',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 个人信息区域（固定不滚动）
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 用户名
                          Text(
                            _userInfo != null
                                ? _userInfo!['nickname']
                                : "加载中...",
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

                          // 简介
                          Text(
                            _userInfo != null ? _userInfo!['bio'] : "加载中...",
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 12),

                          // 位置和注册日期
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

                          // 关注者和粉丝
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
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 选项卡
                    TabBar(
                      tabs: [
                        Tab(text: '动态'),
                        Tab(text: '回复'),
                        Tab(text: '媒体'),
                        Tab(text: '喜欢'),
                      ],
                      indicatorColor: Colors.blue,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                    ),

                    // 选项卡内容区域（可滚动）
                    Expanded(
                      child: TabBarView(
                        children: [
                          _buildTweetsTab(),
                          _buildRepliesTab(),
                          _buildMediaTab(),
                          _buildLikesTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildTweetsTab() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 8),
      itemCount: 10,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Articlelist(), // Your existing article widget
        );
      },
    );
  }

  Widget _buildRepliesTab() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading:
              _userInfo != null && _userInfo!['userPic'].isNotEmpty
                  ? CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      _userInfo!['userPic'],
                    ),
                  )
                  : const CircleAvatar(
                    backgroundImage: AssetImage("lib/assets/images/1.jpg"),
                  ),
          title: Text("@user 回复了你"),
          subtitle: Text("这是对你动态的回复..."),
        );
      },
    );
  }

  Widget _buildMediaTab() {
    return GridView.builder(
      padding: EdgeInsets.only(top: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 15,
      itemBuilder: (context, index) {
        return Image.asset("lib/assets/images/3.jpg", fit: BoxFit.cover);
      },
    );
  }

  Widget _buildLikesTab() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 8),
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          leading:
              _userInfo != null && _userInfo!['userPic'].isNotEmpty
                  ? CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      _userInfo!['userPic'],
                    ),
                  )
                  : const CircleAvatar(
                    backgroundImage: AssetImage("lib/assets/images/1.jpg"),
                  ),
          title: Text("@user 喜欢了你的动态"),
          subtitle: Text("你的动态内容预览..."),
        );
      },
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
