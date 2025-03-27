import 'package:flutter/material.dart';
import 'package:flutterlearn2/components/article.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: CustomScrollView(
          slivers: [
            // Cover photo (app bar)
            SliverAppBar(
              expandedHeight: 150.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: Image.asset(
                  "lib/assets/images/4.jpg",
                  fit: BoxFit.cover,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),

            // Profile information section
            SliverToBoxAdapter(child: _buildProfileInfo()),

            // Tab bar
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                const TabBar(
                  tabs: [
                    Tab(text: 'Tweets'),
                    Tab(text: 'Replies'),
                    Tab(text: 'Media'),
                    Tab(text: 'Likes'),
                  ],
                  indicatorColor: Colors.blue,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                ),
              ),
              pinned: true,
            ),

            // Tab content
            SliverFillRemaining(
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

  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar and follow button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Transform.translate(
                offset: const Offset(0, -40),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage("lib/assets/images/1.jpg"),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Follow',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),

          // Adjust spacing to account for avatar overlap
          const SizedBox(height: 8),

          // User info
          const Text(
            "霸气小肥鹅",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "@baqixiaofeie",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // Bio
          const Text(
            "独立开发者 | Flutter爱好者 | 分享开发经验和生活点滴",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),

          // Location and join date
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text("Beijing, China", style: TextStyle(color: Colors.grey[600])),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                "Joined March 2020",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Following/followers count
          Row(
            children: [
              Text(
                "542 ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text("Following", style: TextStyle(color: Colors.grey[600])),
              const SizedBox(width: 16),
              Text(
                "12.8K ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text("Followers", style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTweetsTab() {
    return ListView.builder(
      physics:
          const NeverScrollableScrollPhysics(), // Disable independent scrolling
      itemCount: 10,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Article(), // Your existing article widget
        );
      },
    );
  }

  Widget _buildRepliesTab() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage("lib/assets/images/1.jpg"),
          ),
          title: Text("@user replied to you"),
          subtitle: Text("This is a sample reply to your tweet..."),
        );
      },
    );
  }

  Widget _buildMediaTab() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
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
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage("lib/assets/images/1.jpg"),
          ),
          title: Text("@user liked your tweet"),
          subtitle: Text("Your tweet content preview..."),
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
