import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/api/emailAPI.dart';
import 'package:Navi/api/userAPI.dart';
import 'package:Navi/page/Email/components/emailItem.dart';
import 'package:Navi/providers/notification_provider.dart';
import 'package:Navi/utils/route_utils.dart';
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
  bool _isLoading = true;

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
      Provider.of<NotificationProvider>(context, listen: false).markAsRead();
    }
  }

  Future<void> getEmailList() async {
    setState(() {
      _isLoading = true;
    });
    
    final userInfo = await SharedPrefsUtils.getUserInfo();
    try {
      var result = await service.getEmailList(int.parse(userInfo!['username']));

      setState(() {
        emailList = result['data'];
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleMarkAllAsRead() async {
    final userInfo = await SharedPrefsUtils.getUserInfo();
    if (userInfo == null) return;

    await service.readAllEmail(int.parse(userInfo['username']));
    setState(() {
      emailList = List.from(emailList);
      emailList.forEach((element) {
        element['isRead'] = true;
      });
    });
    Provider.of<NotificationProvider>(context, listen: false).clearAll();
    await getEmailList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // 顶部标题栏
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '通知',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (emailList.isNotEmpty)
                    TextButton(
                      onPressed: _handleMarkAllAsRead,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text(
                        '全部已读',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // 通知列表
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (emailList.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '暂无通知',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          handleRead(index);
                        },
                        child: Emailitem(email: emailList[index]),
                      ),
                      if (index < emailList.length - 1)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey.shade200,
                        ),
                    ],
                  );
                },
                childCount: emailList.length,
              ),
            ),
        ],
      ),
    );
  }
}
