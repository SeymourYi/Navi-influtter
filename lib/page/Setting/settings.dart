import 'package:flutter/material.dart';
import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/page/login/login.dart';
import 'package:Navi/page/login/user_agreement.dart';
import 'package:Navi/page/edit/editpage.dart';
import 'package:Navi/api/userAPI.dart';
import 'package:Navi/page/Setting/changePassword.dart';
import 'package:Navi/utils/route_utils.dart';

class settings extends StatefulWidget {
  const settings({super.key});

  @override
  State<settings> createState() => _settingsState();
}

class _settingsState extends State<settings> {
  final UserService _userService = UserService();
  bool _isLoading = false;
  String? _username;
  final Color _primaryColor = const Color(0xFF7461CA);
  final Color pinkColor = const Color(0xFFFFB6C1);

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
      var result = await _userService.deleteAccount(_username!);
      
      if (result != null && result['code'] == 0) {
        await SharedPrefsUtils.clearUserInfo();
        await SharedPrefsUtils.clearToken();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result?['msg'] ?? '注销账号失败，请稍后重试')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('注销账号失败: $e')),
        );
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '确认注销账号',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          '您确定要注销账号吗？此操作不可逆转，将永久删除您的账号及所有数据。',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              '取消',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              elevation: 0,
            ),
            child: const Text(
              '确认注销',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await SharedPrefsUtils.clearUserInfo();
    await SharedPrefsUtils.clearToken();
    if (mounted) {
      Navigator.pop(context);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: Colors.black87,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '设置',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SizedBox(height: 8),

                      // 账号部分
                      _buildSectionHeader('账号'),
                      const SizedBox(height: 8),

                      // 账号信息
                      _buildSettingItem(
                        title: '账号信息',
                        subtitle: '编辑昵称、位置、生日、头像',
                        onTap: () {
                          Navigator.push(
                            context,
                            RouteUtils.slideFromRight(const EditProfilePage()),
                          );
                        },
                      ),

                      const SizedBox(height: 8),

                      // 密码与安全
                      _buildSettingItem(
                        title: '密码与安全',
                        subtitle: '修改密码等账号相关设置',
                        onTap: () {
                          Navigator.push(
                            context,
                            RouteUtils.slideFromRight(ChangePasswordPage()),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // 其他部分
                      _buildSectionHeader('其他'),
                      const SizedBox(height: 8),

                      // 关于
                      _buildSettingItem(
                        title: '关于',
                        subtitle: '版本 1.0.0',
                        onTap: () {
                          // 可以显示版本信息对话框
                        },
                      ),

                      const SizedBox(height: 8),

                      // 隐私政策
                      _buildSettingItem(
                        title: '隐私政策',
                        subtitle: null,
                        onTap: () {
                          Navigator.push(
                            context,
                            RouteUtils.slideFromRight(const UserAgreementPage()),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // 退出登录按钮
                      Center(
                        child: TextButton(
                          onPressed: _logout,
                          child: const Text(
                            '退出登录',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: pinkColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // "中" 字在左上角
              Positioned(
                left: 10,
                top: 10,
                child: Text(
                  '中',
                  style: TextStyle(
                    color: const Color(0xFFE91E63), // 深粉色
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // "A" 字在中心
              const Text(
                'A',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showPasswordSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          '密码与安全',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '账号安全设置',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _confirmDeregister();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Colors.red[600],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '注销账号',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '永久删除账号及所有数据',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              '关闭',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
