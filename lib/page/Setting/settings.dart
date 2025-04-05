import 'package:flutter/material.dart';
import 'package:flutterlearn2/Store/storeutils.dart';
import 'package:flutterlearn2/page/login/login.dart';
import 'package:flutterlearn2/page/login/user_agreement.dart';
import 'package:flutterlearn2/api/userRegisterAPI.dart';

class settings extends StatefulWidget {
  const settings({super.key});

  @override
  State<settings> createState() => _settingsState();
}

class _settingsState extends State<settings> {
  final UserRegisterService _userRegisterService = UserRegisterService();
  bool _isLoading = false;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      if (userInfo != null) {
        setState(() {
          _username = userInfo['username'];
        });
      }
    } catch (e) {
      print('加载用户信息出错: $e');
    }
  }

  Future<void> _deregisterAccount() async {
    if (_username == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _userRegisterService.register(_username!);
      await SharedPrefsUtils.clearUserInfo();
      await SharedPrefsUtils.clearToken();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('注销账号失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _confirmDeregister() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('确认注销账号'),
            content: Text('您确定要注销账号吗？此操作不可逆转，将永久删除您的账号及所有数据。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deregisterAccount();
                },
                child: Text('确认注销', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF7461CA),
        elevation: 0,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
                color: Colors.grey[50],
                child: ListView(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        '系统设置',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7461CA),
                        ),
                      ),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '账号管理',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7461CA),
                              ),
                            ),
                            SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _confirmDeregister,
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              label: Text(
                                '注销账号',
                                style: TextStyle(color: Colors.red),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.red.withOpacity(0.5),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '关于',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7461CA),
                              ),
                            ),
                            SizedBox(height: 16),
                            ListTile(
                              leading: Icon(
                                Icons.info_outline,
                                color: Color(0xFF7461CA),
                              ),
                              title: Text('版本信息'),
                              subtitle: Text('Navi v1.0.0'),
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 8,
                              endIndent: 8,
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.code,
                                color: Color(0xFF7461CA),
                              ),
                              title: Text('开发者信息'),
                              subtitle: Text('Navi Team © 2024'),
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 8,
                              endIndent: 8,
                            ),
                            ListTile(
                              leading: Icon(
                                Icons.article_outlined,
                                color: Color(0xFF7461CA),
                              ),
                              title: Text('用户协议与隐私政策'),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              dense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const UserAgreementPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
