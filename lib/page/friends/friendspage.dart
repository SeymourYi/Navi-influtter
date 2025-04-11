import 'package:Navi/page/UserInfo/components/userpage.dart';
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
        _friends = [];
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
                separatorBuilder:
                    (context, index) => const Divider(
                      height: 0.5,
                      color: Color.fromARGB(75, 158, 158, 158),
                    ),
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(username: friend.username),
          ),
        );
      },
      child: Padding(
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
                          Text(
                            ' @${friend.username}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
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
                      // Bio
                      if (friend.bio != null && friend.bio!.isNotEmpty)
                        Text(
                          friend.bio!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ],
        ),
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
