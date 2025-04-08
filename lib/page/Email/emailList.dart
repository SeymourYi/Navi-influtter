import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/api/emailAPI.dart';
import 'package:Navi/api/userAPI.dart';
import 'package:Navi/page/Email/components/emailItem.dart';
import 'package:Navi/providers/notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmailList extends StatefulWidget {
  const EmailList({super.key});

  @override
  State<EmailList> createState() => _EmailListState();
}

class _EmailListState extends State<EmailList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final SharedPrefsUtils sharedPrefsUtils = SharedPrefsUtils();
  final EmailService service = EmailService();
  final UserService userService = UserService();

  List<dynamic> emailList = [];
  Map<String, dynamic> _userInfo = {};

  @override
  void initState() {
    super.initState();
    getEmailList();
  }

  Future<void> getUserInfo(int index) async {
    String senderId = emailList[index]['senderId'].toString();
    var result = await userService.getsomeUserinfo(senderId);
    setState(() {
      _userInfo = result['data'];
    });
  }

  Future<void> handleRead(int index) async {
    print("object1111111111");
    Provider.of<NotificationProvider>(context, listen: false).markAsRead();
    await getUserInfo(index);

    if (emailList[index]['isRead'] == false) {
      service.readsomeonenotification(
        emailList[index]['id'].toString(),
        emailList[index]['receiverId'].toString(),
      );
      setState(() {
        emailList = List.from(emailList); // 创建新列表
        emailList[index] = {...emailList[index], 'isRead': true}; // 创建新对象
      });
    }

    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   builder: (context) {
    //     return Container(
    //       padding: const EdgeInsets.only(
    //         top: 50, // 增加顶部padding为头像预留空间
    //         left: 16,
    //         right: 16,
    //       ),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           // 用户名和其他信息
    //           Text(
    //             _userInfo['nickname'],
    //             style: const TextStyle(
    //               fontSize: 22,
    //               fontWeight: FontWeight.bold,
    //             ),
    //           ),
    //           const SizedBox(height: 4),
    //           Text(
    //             _userInfo['nickname'],
    //             style: const TextStyle(fontSize: 16, color: Colors.grey),
    //           ),
    //           const SizedBox(height: 12),

    //           // 个人简介
    //           Text(_userInfo['nickname'], style: const TextStyle(fontSize: 16)),
    //           const SizedBox(height: 12),

    //           // 地点和加入日期
    //           Row(
    //             children: [
    //               Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
    //               const SizedBox(width: 4),
    //               Text(
    //                 _userInfo['nickname'],
    //                 style: TextStyle(color: Colors.grey[600]),
    //               ),
    //               const SizedBox(width: 16),
    //               Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
    //               const SizedBox(width: 4),
    //               Text(
    //                 _userInfo['nickname'],
    //                 style: TextStyle(color: Colors.grey[600]),
    //               ),
    //             ],
    //           ),
    //           const SizedBox(height: 12),

    //           // 关注和粉丝
    //           Row(
    //             children: [
    //               Text(
    //                 "542 ",
    //                 style: TextStyle(
    //                   fontWeight: FontWeight.bold,
    //                   color: Colors.grey[800],
    //                 ),
    //               ),
    //               Text("关注", style: TextStyle(color: Colors.grey[600])),
    //               const SizedBox(width: 16),
    //               Text(
    //                 "12.8K ",
    //                 style: TextStyle(
    //                   fontWeight: FontWeight.bold,
    //                   color: Colors.grey[800],
    //                 ),
    //               ),
    //               Text("粉丝", style: TextStyle(color: Colors.grey[600])),
    //               const Spacer(),
    //             ],
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // );
  }

  Future<void> getEmailList() async {
    final userInfo = await SharedPrefsUtils.getUserInfo();
    try {
      var result = await service.getEmailList(int.parse(userInfo!['username']));
      setState(() {
        emailList = result['data'];
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('邮件列表'),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min, // 避免占用过多空间
            children: [
              InkWell(
                onTap: () async {
                  final userInfo = await SharedPrefsUtils.getUserInfo();
                  service.readAllEmail(int.parse(userInfo!['username']));
                  setState(() {
                    emailList = List.from(emailList); // 创建新列表
                    emailList.forEach((element) {
                      element['isRead'] = true;
                    });
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      Text("全部已读", style: TextStyle(color: Colors.grey)),
                      Icon(Icons.email, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
        centerTitle: true,
      ),
      body: Container(
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          cacheExtent: 2000, // 缓存额外 2000 像素的内容
          itemCount: emailList.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                handleRead(index);
              },
              child: Emailitem(email: emailList[index]),
            );
          },
        ),
      ),
    );
  }
}
