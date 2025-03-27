// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'articleimage.dart';
// import '../components/userinfo.dart';

// class Articledetail extends StatefulWidget {
//   final String id;

//   const Articledetail({super.key, required this.id});

//   @override
//   State<Articledetail> createState() => _ArticledetailState();
// }

// class _ArticledetailState extends State<Articledetail> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('文章详情'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // User info and title section
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Avatar
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         PageRouteBuilder(
//                           pageBuilder:
//                               (context, animation, secondaryAnimation) =>
//                                   const Userinfo(),
//                           transitionsBuilder: (
//                             context,
//                             animation,
//                             secondaryAnimation,
//                             child,
//                           ) {
//                             const begin = Offset(1.0, 0.0);
//                             const end = Offset.zero;
//                             const curve = Curves.ease;

//                             var tween = Tween(
//                               begin: begin,
//                               end: end,
//                             ).chain(CurveTween(curve: curve));

//                             return SlideTransition(
//                               position: animation.drive(tween),
//                               child: child,
//                             );
//                           },
//                         ),
//                       );
//                     },
//                     child: const CircleAvatar(
//                       radius: 20,
//                       backgroundImage: AssetImage(
//                         "assets/images/user_avatar.png",
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   // Username and time
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "霸气小肥鹅",
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             fontFamily: "Inter-Regular",
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           "五分钟以前",
//                           style: TextStyle(
//                             fontSize: 13,
//                             fontFamily: "Inter-Regular",
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // Article content
//               const Text(
//                 "社区有个小伙伴，刚跟我吐槽职场环境，结果上周他自己的 App 爆发，得到了应用市场的推荐，数据爆炸。他的产品其实已经默默开发 2 年多了，去年还问我怎么把收到的100 刀提出来，如今已经在琢磨如何利用好这 破天富贵，期待他有空了发个帖子分享一下。做独立开发者就是这样，有努力、有运气，有坚持。",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                   fontFamily: "Inter-Regular",
//                   height: 1.5,
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // Article images
//               ArticleImage(
//                 imageUrls: [
//                   "lib/assets/images/3.jpg",
//                   "lib/assets/images/3.jpg",
//                   "lib/assets/images/3.jpg",
//                   "lib/assets/images/3.jpg",
//                   "lib/assets/images/3.jpg",
//                   "lib/assets/images/3.jpg",
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // Like and comment count
//               Row(
//                 children: [
//                   Icon(Icons.favorite, size: 18, color: Colors.grey[600]),
//                   const SizedBox(width: 4),
//                   Text(
//                     "10",
//                     style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                   ),
//                   const SizedBox(width: 16),
//                   Icon(
//                     Icons.mode_comment_outlined,
//                     size: 18,
//                     color: Colors.grey[600],
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     "3",
//                     style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),

//               const Divider(height: 32, thickness: 1),

//               // Comments section
//               const Text(
//                 "评论",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 16),

//               // Comment list
//               _buildCommentItem(
//                 username: "张三",
//                 content: "这篇文章很有启发！",
//                 time: "2分钟前",
//               ),

//               _buildCommentItem(
//                 username: "李四",
//                 content: "独立开发确实需要坚持，佩服！",
//                 time: "10分钟前",
//               ),

//               _buildCommentItem(
//                 username: "王五",
//                 content: "期待后续的分享！",
//                 time: "30分钟前",
//               ),

//               const SizedBox(height: 16),

//               // Comment input area
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         decoration: InputDecoration(
//                           hintText: "写评论...",
//                           border: InputBorder.none,
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                           ),
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.send),
//                       color: Theme.of(context).primaryColor,
//                       onPressed: () {},
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCommentItem({
//     required String username,
//     required String content,
//     required String time,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const CircleAvatar(
//             radius: 16,
//             backgroundImage: AssetImage("assets/images/user_avatar.png"),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   username,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(content, style: const TextStyle(fontSize: 14)),
//                 const SizedBox(height: 4),
//                 Text(
//                   time,
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'articleimage.dart';
import '../components/userinfo.dart';

class Articledetail extends StatefulWidget {
  final String id;

  const Articledetail({super.key, required this.id});

  @override
  State<Articledetail> createState() => _ArticledetailState();
}

class _ArticledetailState extends State<Articledetail> {
  bool _isLiked = false;
  int _likeCount = 42;
  bool _isBookmarked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: const CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage(
                        "assets/images/user_avatar.png",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "霸气小肥鹅",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "@baqixiaofeie · 5m",
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                "社区有个小伙伴，刚跟我吐槽职场环境，结果上周他自己的 App 爆发，得到了应用市场的推荐，数据爆炸。他的产品其实已经默默开发 2 年多了，去年还问我怎么把收到的100 刀提出来，如今已经在琢磨如何利用好这破天富贵，期待他有空了发个帖子分享一下。做独立开发者就是这样，有努力、有运气，有坚持。",
                style: TextStyle(fontSize: 16, height: 1.4),
              ),
            ),

            // Images
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ArticleImage(
                imageUrls: [
                  "lib/assets/images/3.jpg",
                  "lib/assets/images/3.jpg",
                  "lib/assets/images/3.jpg",
                  "lib/assets/images/3.jpg",
                  "lib/assets/images/3.jpg",
                  "lib/assets/images/3.jpg",
                ],
              ),
            ),

            // Stats and actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    "10:30 AM · Mar 27, 2023",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    "1.2K Views",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
                    count: "24",
                    onPressed: () {},
                  ),
                  _buildActionButton(
                    icon: Icons.repeat,
                    count: "142",
                    onPressed: () {},
                  ),
                  _buildActionButton(
                    icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                    count: _likeCount.toString(),
                    isActive: _isLiked,
                    onPressed: () {
                      setState(() {
                        _isLiked = !_isLiked;
                        _likeCount += _isLiked ? 1 : -1;
                      });
                    },
                  ),
                  _buildActionButton(
                    icon:
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    onPressed: () {
                      setState(() {
                        _isBookmarked = !_isBookmarked;
                      });
                    },
                    isActive: _isBookmarked,
                  ),
                  _buildActionButton(icon: Icons.share, onPressed: () {}),
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
                  const Text(
                    "24 replies",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildReplyItem(
                    avatar: "assets/images/user_avatar.png",
                    name: "张三",
                    handle: "@zhangsan",
                    content: "这篇文章很有启发！独立开发确实需要坚持",
                    time: "2m",
                    likes: "12",
                  ),
                  _buildReplyItem(
                    avatar: "assets/images/user_avatar.png",
                    name: "李四",
                    handle: "@lisi",
                    content: "期待后续的分享！希望能看到更多这样的内容",
                    time: "10m",
                    likes: "8",
                  ),
                  _buildReplyItem(
                    avatar: "assets/images/user_avatar.png",
                    name: "王五",
                    handle: "@wangwu",
                    content: "已经分享给我的团队了，大家都很受启发",
                    time: "30m",
                    likes: "24",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Reply input
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage("assets/images/user_avatar.png"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Tweet your reply",
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
                  ),
                ),
              ),
            ],
          ),
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
    required String avatar,
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
          CircleAvatar(radius: 20, backgroundImage: AssetImage(avatar)),
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
                    Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      likes,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
