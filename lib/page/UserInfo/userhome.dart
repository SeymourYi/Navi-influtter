import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/api/userAPI.dart';
import 'package:Navi/page/UserInfo/components/userpage.dart';
import 'package:Navi/page/chat/screen/chat_screen.dart';
import 'package:Navi/page/chat/screen/chatitem.dart';
import 'package:flutter/material.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key, required this.userId});
  final String userId;

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  double _dragDistance = 0.0;
  double _screenWidth = 0.0;

  dynamic _userinfo = {};
  UserService server = UserService();
  Future<void> _fetchUserInfo() async {
    // final userInfo = await SharedPrefsUtils.getUserInfo();
    // server.getUserInfo(widget.userId).then((value) {
    //   print(value);
    // });
    var res = await server.getsomeUserinfo(widget.userId);
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.of(context).pop();
        }
      },
      child: GestureDetector(
        onHorizontalDragStart: (details) {
          _dragDistance = 0.0;
        },
        onHorizontalDragUpdate: (details) {
          setState(() {
            _dragDistance += details.delta.dx;
            if (_dragDistance < 0) _dragDistance = 0;
          });
        },
        onHorizontalDragEnd: (details) {
          if (_dragDistance > _screenWidth * 0.3) {
            Navigator.of(context).pop();
          } else {
            setState(() {
              _dragDistance = 0;
            });
          }
        },
        child: Transform.translate(
          offset: Offset(_dragDistance, 0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    0.9 * (_dragDistance / _screenWidth),
                  ),
                  blurRadius: 10.0 * (_dragDistance / _screenWidth),
                  spreadRadius: 15.0 * (_dragDistance / _screenWidth),
                  offset: Offset(-5.0 * (_dragDistance / _screenWidth), 0),
                ),
              ],
            ),
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.arrow_back_ios_new_outlined, size: 20),
                ),
              ),
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
                                    style: TextStyle(
                                      fontSize: 13,
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

                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProfilePage(
                                    username: _userinfo["username"],
                                  ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
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
                              "朋友资料",
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

                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(),
                            // ChatItem(
                            //   chatWithusername: _userinfo["username"],
                            // ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              width: 10,
                              color: Color.fromARGB(41, 158, 158, 158),
                            ),
                            bottom: BorderSide(
                              color: Color.fromARGB(41, 158, 158, 158),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                            vertical: MediaQuery.of(context).size.height * 0.02,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat,
                                size: 20,
                                color: const Color.fromRGBO(111, 107, 204, 1),
                              ),
                              Text(
                                "发消息",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: const Color.fromRGBO(111, 107, 204, 1),
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Inter-Medium",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Container(
                    //   decoration: BoxDecoration(
                    //     border: Border(
                    //       top: BorderSide(
                    //         width: 10,
                    //         color: Color.fromARGB(41, 158, 158, 158),
                    //       ),
                    //       bottom: BorderSide(
                    //         color: Color.fromARGB(41, 158, 158, 158),
                    //       ),
                    //     ),
                    //   ),
                    //   child: Padding(
                    //     padding: EdgeInsets.symmetric(
                    //       horizontal: MediaQuery.of(context).size.width * 0.05,
                    //       vertical: MediaQuery.of(context).size.height * 0.02,
                    //     ),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Icon(
                    //           Icons.chat,
                    //           size: 20,
                    //           color: const Color.fromRGBO(111, 107, 204, 1),
                    //         ),
                    //         Text(
                    //           "发消息",
                    //           style: TextStyle(
                    //             fontSize: 18,
                    //             color: const Color.fromRGBO(111, 107, 204, 1),
                    //             fontWeight: FontWeight.w500,
                    //             fontFamily: "Inter-Medium",
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Expanded(
                      child: Container(
                        color: Color.fromARGB(41, 158, 158, 158),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
