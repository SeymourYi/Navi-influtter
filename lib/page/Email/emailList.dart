import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/api/emailAPI.dart';
import 'package:Navi/page/Email/components/emailItem.dart';
import 'package:flutter/material.dart';

class EmailList extends StatefulWidget {
  const EmailList({super.key});

  @override
  State<EmailList> createState() => _EmailListState();
}

class _EmailListState extends State<EmailList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  SharedPrefsUtils sharedPrefsUtils = SharedPrefsUtils();
  EmailService service = EmailService();
  List<dynamic> emailList = [];
  @override
  void initState() {
    super.initState();
    getEmailList();
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
        title: Text('邮件列表'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.email))],
        centerTitle: true,
      ),
      body: Container(
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          cacheExtent: 2000, // 缓存额外 2000 像素的内容
          itemCount: emailList.length,
          itemBuilder: (context, index) {
            return Emailitem(email: emailList[index]);
          },
        ),
      ),
    );
  }
}
