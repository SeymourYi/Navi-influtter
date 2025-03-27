// post_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _postController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _attachedImages = [];
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
            children: [
              _buildUserInfo(),
              const SizedBox(height: 16),
              _buildPostInput(),
              if (_attachedImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildImageGrid(),
              ],
              const SizedBox(height: 16),
              _buildBottomToolbar(),
              const SizedBox(height: 8),
              _buildCharacterCounter(),
            ],
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
                '你的名字',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 2),
              Text(
                '@你的用户名',
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
                  hintText: '有什么新鲜事？',
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

  Widget _buildPostInput() {
    return const SizedBox(); // 已合并到_buildUserInfo中
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _attachedImages.length > 1 ? 2 : 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _attachedImages.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                _attachedImages[index],
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomToolbar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildToolbarButton(
              icon: Icons.image_outlined,
              onPressed: _attachImage,
            ),
            const SizedBox(width: 8),
            _buildToolbarButton(icon: Icons.gif_box_outlined, onPressed: () {}),
            const SizedBox(width: 8),
            _buildToolbarButton(icon: Icons.poll_outlined, onPressed: () {}),
            const SizedBox(width: 8),
            _buildToolbarButton(
              icon: Icons.emoji_emotions_outlined,
              onPressed: () {},
            ),
          ],
        ),
        SvgPicture.asset(
          'assets/icons/verified.svg', // 替换为你的SVG路径
          width: 20,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 24),
      color: Colors.blue,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: onPressed,
    );
  }

  Widget _buildCharacterCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_characterCount > _maxCharacters - 20)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color:
                    _characterCount > _maxCharacters
                        ? Colors.red
                        : Colors.grey.shade400,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_maxCharacters - _characterCount}',
              style: TextStyle(
                color:
                    _characterCount > _maxCharacters
                        ? Colors.red
                        : Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _attachImage() async {
    // 实际项目中应使用image_picker选择图片
    setState(() {
      _attachedImages.add('assets/images/sample.jpg'); // 替换为你的图片路径
    });
  }

  void _removeImage(int index) {
    setState(() {
      _attachedImages.removeAt(index);
    });
  }

  void _handlePost() {
    // 实际项目中应调用API发布内容
    debugPrint('发布内容: ${_postController.text}');
    if (_attachedImages.isNotEmpty) {
      debugPrint('附带${_attachedImages.length}张图片');
    }
    Navigator.pop(context);
  }
}
