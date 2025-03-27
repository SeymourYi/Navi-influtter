import 'package:flutter/material.dart';

class FriendsList extends StatelessWidget {
  final List<Friend> friends;
  final ValueChanged<Friend>? onFollowPressed;

  const FriendsList({super.key, required this.friends, this.onFollowPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.separated(
        itemCount: friends.length,
        separatorBuilder: (context, index) => const Divider(height: 0),
        itemBuilder: (context, index) {
          final friend = friends[index];
          return FriendListItem(
            friend: friend,
            onFollowPressed: () => onFollowPressed?.call(friend),
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
                  _buildStatItem(Icons.people, '${friend.following} Following'),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    Icons.people_outline,
                    '${friend.followers} Followers',
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
          child: const Text('Following', style: TextStyle(color: Colors.black)),
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
          child: const Text('Follow', style: TextStyle(color: Colors.white)),
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
}

// Example usage:
/*
FriendsList(
  friends: [
    Friend(
      name: '霸气小肥鹅',
      username: 'baqixiaofeie',
      avatarUrl: 'assets/images/user_avatar.png',
      bio: '独立开发者 | Flutter爱好者 | 分享开发经验和生活点滴',
      isFollowing: true,
      isVerified: true,
      followers: 12800,
      following: 542,
      showStats: true,
    ),
    Friend(
      name: 'Flutter官方',
      username: 'flutter',
      avatarUrl: 'assets/images/flutter_logo.png',
      bio: 'Flutter官方账号，分享Flutter最新动态和开发技巧',
      isVerified: true,
      followers: 250000,
      following: 120,
      showStats: true,
    ),
    // Add more friends...
  ],
  onFollowPressed: (friend) {
    // Handle follow/unfollow action
    print('Follow button pressed for ${friend.name}');
  },
)
*/
