import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/api/userAPI.dart';
import 'package:flutter/material.dart';

class UserHomeMain extends StatefulWidget {
  const UserHomeMain({super.key});

  @override
  State<UserHomeMain> createState() => _UserHomeMainState();
}

class _UserHomeMainState extends State<UserHomeMain>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  dynamic _userinfo = {};
  UserService server = UserService();
  Future<void> _fetchUserInfo() async {
    final userInfo = await SharedPrefsUtils.getUserInfo();
    // server.getUserInfo(widget.userId).then((value) {
    //   print(value);
    // });
    var res = await server.getsomeUserinfo(userInfo!["username"]);
    setState(() {
      _userinfo = res["data"];
    });

    // .then((value) {
    //   setState(() {
    //     _userinfo = value;
    //   });

    // print(_userinfo['username']);
    // print("2222222222222233333333333");
    // });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("用户主页"), centerTitle: true),
      body: Hero(
        tag: 'user_home',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.01,
                left: MediaQuery.of(context).size.width * 0.05,
                right: MediaQuery.of(context).size.width * 0.05,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(44, 255, 254, 254),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                        _userinfo["userPic"] ??
                            "https://api.dicebear.com/9.x/adventurer/svg?seed=George",
                      ),
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
                                _userinfo["nickname"] ?? "",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Colors.black,
                                ),
                              ),

                              // if (true) ...[
                              //   const SizedBox(width: 4),
                              //   Icon(
                              //     Icons.verified,
                              //     size: 18,
                              //     color: Theme.of(context).primaryColor,
                              //   ),
                              // ],
                            ],
                          ),
                          Text(
                            '用户名：${_userinfo["username"]}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            _userinfo["bio"] ?? "",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: const Color.fromARGB(41, 158, 158, 158),
                  ),
                  bottom: BorderSide(
                    color: const Color.fromARGB(41, 158, 158, 158),
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Row(
                  children: [
                    Text(
                      "贴文",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter-Medium",
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: const Color.fromARGB(41, 158, 158, 158),
                  ),
                  bottom: BorderSide(
                    color: const Color.fromARGB(41, 158, 158, 158),
                  ),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.05,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Row(
                  children: [
                    Text(
                      "我的资料",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Inter-Medium",
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_outlined,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(color: Color.fromARGB(41, 158, 158, 158)),
            ),
          ],
        ),
      ),
    );
  }
}
