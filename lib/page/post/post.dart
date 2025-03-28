// post_page.dart - 发布页面
import 'package:flutter/material.dart';
// ignore: unused_import
import '../../models/post_article_model.dart';

/// 发布页面的无状态组件
class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

/// 发布页面的状态管理类
class _PostPageState extends State<PostPage> {
  // 文本编辑控制器，用于管理输入内容
  final TextEditingController _postController = TextEditingController();
  // 焦点节点，用于管理键盘焦点
  final FocusNode _focusNode = FocusNode();
  // 当前输入字符数
  int _characterCount = 0;
  // 最大允许字符数
  final int _maxCharacters = 280;

  @override
  void initState() {
    super.initState();
    // 界面加载完成后自动弹出键盘
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  @override
  void dispose() {
    // 释放资源，避免内存泄漏
    _postController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 左侧关闭按钮
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        // 页面标题
        title: const Text('发布', style: TextStyle(fontWeight: FontWeight.bold)),
        // 右侧操作按钮
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              // 当有内容时才能点击发布
              onPressed: _characterCount > 0 ? _handlePost : null,
              style: ElevatedButton.styleFrom(
                // 根据是否有内容设置不同的按钮颜色
                backgroundColor:
                    _characterCount > 0 ? Colors.blue : Colors.blue.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                '发布',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      // 主体内容区域
      body: GestureDetector(
        // 点击空白区域隐藏键盘
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [_buildUserInfo(), const SizedBox(height: 16)],
          ),
        ),
      ),
    );
  }

  /// 构建用户信息和输入区域
  Widget _buildUserInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 用户头像
        const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage(
            'https://pbs.twimg.com/profile_images/1489998192095043586/4VrvN5yt_400x400.jpg',
          ),
        ),
        const SizedBox(width: 12),
        // 用户信息和输入框
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户名称
              const Text(
                '霸气小肥鹅',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 2),
              // 用户ID
              Text(
                '@1111',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              // 输入框
              TextField(
                controller: _postController,
                focusNode: _focusNode,
                autofocus: true,
                maxLines: null, // 允许多行输入
                maxLength: _maxCharacters, // 最大字符限制
                decoration: const InputDecoration(
                  hintText: '想记下点什么？',
                  border: InputBorder.none,
                  counterText: '', // 隐藏默认的字符计数器
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 18),
                // 监听文本变化，更新字符计数
                onChanged: (text) {
                  setState(() => _characterCount = text.length);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 处理发布操作
  void _handlePost() {
    // 实际项目中应调用API发布内容
    debugPrint('发布内容: ${_postController.text}');
    Navigator.pop(context); // 发布后返回上一页
  }
}
