import 'package:flutter/material.dart';
import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/page/login/login.dart';
import 'package:Navi/page/login/user_agreement.dart';
import 'package:Navi/api/userRegisterAPI.dart';

class settings extends StatefulWidget {
  const settings({super.key});

  @override
  State<settings> createState() => _settingsState();
}

class _settingsState extends State<settings> {
  final UserRegisterService _userRegisterService = UserRegisterService();
  bool _isLoading = false;
  String? _username;
  final Color _primaryColor = const Color(0xFF7461CA);

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              '确认注销账号',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text('您确定要注销账号吗？此操作不可逆转，将永久删除您的账号及所有数据。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deregisterAccount();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('确认注销'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('设置', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
        elevation: 0.5,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 0.5, color: Colors.grey[300]),
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: _primaryColor))
              : ListView(
                children: [
                  _buildSectionHeader('账号管理'),
                  _buildSettingItem(
                    icon: Icons.logout,
                    title: '退出登录',
                    onTap: () async {
                      await SharedPrefsUtils.clearUserInfo();
                      await SharedPrefsUtils.clearToken();
                      Navigator.pop(context);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false,
                      );
                    },
                  ),
                  _buildSettingItem(
                    icon: Icons.delete_outline,
                    title: '注销账号',
                    textColor: Colors.red,
                    onTap: _confirmDeregister,
                  ),

                  _buildSectionHeader('关于'),
                  _buildSettingItem(
                    icon: Icons.info_outline,
                    title: '版本信息',
                    subtitle: 'Navi v1.0.0',
                  ),
                  _buildSettingItem(
                    icon: Icons.code,
                    title: '开发者信息',
                    subtitle: 'Navi Team © 2024',
                  ),
                  _buildSettingItem(
                    icon: Icons.article_outlined,
                    title: '隐私政策',
                    showChevron: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UserAgreementPage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 40),
                ],
              ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    bool showChevron = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? _primaryColor, size: 22),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor ?? Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ),
            if (showChevron) Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
