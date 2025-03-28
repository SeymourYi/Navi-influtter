// post_page.dart
import 'package:flutter/material.dart';
// ignore: unused_import
import '../../models/post_article_model.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _postController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _characterCount = 0;
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
    _postController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('发布', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: _characterCount > 0 ? _handlePost : null,
              style: ElevatedButton.styleFrom(
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
      body: GestureDetector(
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

  Widget _buildUserInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage(
            'https://pbs.twimg.com/profile_images/1489998192095043586/4VrvN5yt_400x400.jpg',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '霸气小肥鹅',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                '@1111',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _postController,
                focusNode: _focusNode,
                autofocus: true,
                maxLines: null,
                maxLength: _maxCharacters,
                decoration: const InputDecoration(
                  hintText: '想记下点什么？',
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(fontSize: 18),
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

  void _handlePost() {
    // 实际项目中应调用API发布内容
    debugPrint('发布内容: ${_postController.text}');
    Navigator.pop(context);
  }
}
