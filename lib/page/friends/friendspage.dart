import 'package:flutter/material.dart';
import 'package:Navi/api/getfriendlist.dart';
import '../../api/articleAPI.dart';
import '../../Store/storeutils.dart';

class Friend {
  final String name;
  final String username;
  final String avatarUrl;
  final String? bio;
  final bool isFollowing;
  final bool isVerified;
  final int followers;
  final int following;
  final bool showStats;

  Friend({
    required this.name,
    required this.username,
    required this.avatarUrl,
    this.bio,
    this.isFollowing = false,
    this.isVerified = false,
    this.followers = 0,
    this.following = 0,
    this.showStats = false,
  });

  // 从API返回的数据中创建Friend对象
  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      name: json['nickname'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['userPic'] ?? 'https://via.placeholder.com/150',
      bio: json['bio'] ?? '',
      isFollowing: true, // 假设已关注
      isVerified: false, // 假设未认证
      followers: 0, // 默认值
      following: 0, // 默认值
      showStats: true, // 显示统计信息
    );
  }
}

class FriendsList extends StatefulWidget {
  final List<Friend>? friends;
  final ValueChanged<Friend>? onFollowPressed;

  const FriendsList({super.key, this.friends, this.onFollowPressed});

  @override
  State<FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  bool _isLoading = true;
  List<Friend> _friends = [];

  @override
  void initState() {
    super.initState();
    _fetchFriendList();
  }

  Future<void> _fetchFriendList() async {
    // 如果传入了friends列表，则使用传入的列表
    if (widget.friends != null && widget.friends!.isNotEmpty) {
      setState(() {
        _friends = widget.friends!;
        _isLoading = false;
      });
      return;
    }

    GetFriendListService service = GetFriendListService();
    try {
      var username = await SharedPrefsUtils.getUsername();
      var result = await service.GetFriendList(username.toString());
      print(result);

      // 将API返回的数据转换为Friend对象列表
      List<Friend> apiFriends = [];
      if (result['code'] == 0 && result['data'] is List) {
        for (var item in result['data']) {
          apiFriends.add(Friend.fromJson(item));
        }
      }

      setState(() {
        _friends = apiFriends;
        _isLoading = false;
      });
    } catch (e) {
      // 创建一些模拟数据，以防API调用失败
      setState(() {
        _friends = [
          Friend(
            name: '霸气小肥鹅',
            username: '1111',
            avatarUrl:
                'https://bigevent24563.oss-cn-beijing.aliyuncs.com/7a2fc306-3a6a-4d5f-ab06-e470ecb1d3a7.jpg',
            bio: '韶华易逝，劝君惜取少年时',
            isFollowing: true,
            isVerified: true,
            followers: 12800,
            following: 542,
            showStats: true,
          ),
          Friend(
            name: '金杯车',
            username: '2222',
            avatarUrl:
                'https://bigevent24563.oss-cn-beijing.aliyuncs.com/973eae25-8da6-4011-9281-f686f03c1bfd.jpg',
            bio: '青天碧海，蓝天无线。\n微风徐来，阳光沙滩。',
            isFollowing: true,
            isVerified: false,
            followers: 5400,
            following: 210,
            showStats: true,
          ),
          Friend(
            name: '用户已注销',
            username: '3333',
            avatarUrl:
                'https://bigevent24563.oss-cn-beijing.aliyuncs.com/R-C.png',
            bio: '财务自由 | 游乐人间。\n仰观宇宙之大，俯察品类之盛。',
            isFollowing: false,
            isVerified: true,
            followers: 8600,
            following: 320,
            showStats: true,
          ),
        ];
        _isLoading = false;
      });
      print('Error fetching friend list: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关注列表'),
        centerTitle: true,
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _friends.isEmpty
              ? const Center(
                child: Text('你还没有关注任何人', style: TextStyle(fontSize: 16)),
              )
              : ListView.separated(
                itemCount: _friends.length,
                separatorBuilder: (context, index) => const Divider(height: 0),
                itemBuilder: (context, index) {
                  final friend = _friends[index];
                  return FriendListItem(
                    friend: friend,
                    onFollowPressed: () {
                      setState(() {
                        // 切换关注状态
                        final updatedFriend = Friend(
                          name: friend.name,
                          username: friend.username,
                          avatarUrl: friend.avatarUrl,
                          bio: friend.bio,
                          isFollowing: !friend.isFollowing,
                          isVerified: friend.isVerified,
                          followers: friend.followers,
                          following: friend.following,
                          showStats: friend.showStats,
                        );
                        _friends[index] = updatedFriend;
                      });
                      widget.onFollowPressed?.call(friend);
                    },
                  );
                },
              ),
    );
  }
}

class FriendListItem extends StatelessWidget {
  final Friend friend;
  final VoidCallback? onFollowPressed;

  const FriendListItem({super.key, required this.friend, this.onFollowPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(friend.avatarUrl),
              ),
              const SizedBox(width: 12),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and username
                    Row(
                      children: [
                        Text(
                          friend.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (friend.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '@${friend.username}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    // Bio
                    if (friend.bio != null && friend.bio!.isNotEmpty)
                      Text(
                        friend.bio!,
                        style: const TextStyle(fontSize: 14),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Follow button
              _buildFollowButton(),
            ],
          ),
          // Stats (optional)
          if (friend.showStats)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  _buildStatItem(Icons.people, '${friend.following} 关注'),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    Icons.people_outline,
                    '${friend.followers} 粉丝',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return friend.isFollowing
        ? OutlinedButton(
          onPressed: onFollowPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey[300]!),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text('已关注', style: TextStyle(color: Colors.black)),
        )
        : ElevatedButton(
          onPressed: onFollowPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: const Text('关注', style: TextStyle(color: Colors.white)),
        );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
