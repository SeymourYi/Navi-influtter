import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/api/getfriendlist.dart';
import 'package:Navi/page/chat/screen/privtschatcreen.dart';
import 'package:flutter/material.dart';

class UseSelectScreen extends StatefulWidget {
  const UseSelectScreen({super.key});

  @override
  State<UseSelectScreen> createState() => _UseSelectScreenState();
}

class _UseSelectScreenState extends State<UseSelectScreen> {
  List<dynamic> _friends = [];

  Future<void> _loadFriendList() async {
    GetFriendListService service = GetFriendListService();
    final username = await SharedPrefsUtils.getUsername();
    final friendList = await service.GetFriendList(username.toString());
    _friends = friendList['data'];
    print('好友列表: $_friends');
    print('好友列表长度:AAAAAAAAAAAAAAAAAAAAAAAAAA');
  }

  final Color redColor = Color(0xFFFB514F);
  final Color greenColor = Color(0xFF00C74E);
  final Color blueColor = Color(0xFF4288FC);
  @override
  void initState() {
    super.initState();
    _loadFriendList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _friends.length,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 6),
            itemBuilder: (context, index) {
              final character = _friends[index];

              // 每个联系人使用不同颜色
              final List<Color> colorOptions = [
                redColor,
                greenColor,
                blueColor,
              ];
              final mainColor = colorOptions[index % colorOptions.length];

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade100, width: 1),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    PrivtsChatScreen(character: character),
                          ),
                        ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                      child: Row(
                        children: [
                          // 简约头像
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: mainColor.withOpacity(0.6),
                                width: 1.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.network(
                                character['userPic'],
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (ctx, e, s) => CircleAvatar(
                                      backgroundColor: mainColor.withOpacity(
                                        0.15,
                                      ),
                                      child: Text(
                                        character['nickname']
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: mainColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 18),

                          // 简约信息
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  character['nickname'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (character['bio'].isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      character['bio'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // 简约箭头
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade300,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
