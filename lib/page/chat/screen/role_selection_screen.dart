import 'package:flutter/material.dart';
import '../../../Store/storeutils.dart';

class CharacterRole {
  final String id;
  final String name;
  final String description;
  final String imageAsset; // 角色图片路径
  final Color color;
  bool isCustom; // 是否是自定义角色

  CharacterRole({
    required this.id,
    required this.name,
    required this.description,
    required this.imageAsset,
    required this.color,
    this.isCustom = false,
  });
}

class RoleSelectionScreen extends StatefulWidget {
  final Function(CharacterRole) onRoleSelected;

  const RoleSelectionScreen({super.key, required this.onRoleSelected});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  CharacterRole? _userRole;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    if (_isInitialized) return; // 防止重复初始化

    final userInfo = await SharedPrefsUtils.getUserInfo();
    if (userInfo != null) {
      setState(() {
        _userRole = CharacterRole(
          id: userInfo['username'],
          name: userInfo['nickname'] ?? userInfo['username'] ?? '我自己',
          description: '以自己的身份进行聊天',
          imageAsset: userInfo['userPic'] ?? '',
          color: Colors.purple.shade700,
          isCustom: false,
        );
        _isInitialized = true;
      });
      // 自动选择用户角色并进入聊天
      widget.onRoleSelected(_userRole!);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用 super.build
    return Scaffold(
      appBar: AppBar(
        title: const Text('准备进入聊天'),
        backgroundColor: Colors.amber.shade800,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              '正在加载用户信息...',
              style: TextStyle(fontSize: 18, color: Colors.amber.shade800),
            ),
          ],
        ),
      ),
    );
  }
}
