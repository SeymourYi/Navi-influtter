// post_page.dart - 发布页面
import 'package:Navi/components/litarticle.dart';
import 'package:Navi/components/postlitarticle.dart';
import 'package:flutter/material.dart';
import 'dart:io';
// ignore: unused_import
import '../../models/post_article_model.dart';
import '../../Store/storeutils.dart';
import '../../api/postApi.dart';
import '../../utils/imagepick.dart';
import 'components/targlist.dart';

/// 发布页面的无状态组件
class PostPage extends StatefulWidget {
  const PostPage({
    Key? key,
    this.articelData, // Optional article data
    required this.type,
  }) : super(key: key);

  final dynamic
  articelData; // Consider using a specific type instead of dynamic
  final String
  type; // Changed from dynamic to String since we know it's a string

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
  // 用户数据
  Map<String, dynamic>? _userInfo;
  // 是否正在发布
  bool _isLoading = false;
  // 选中的标签
  String? _selectedTag;
  // 选择的图片
  File? _selectedImage;
  // 标签列表
  List<String> _tags = [];

  // 标签选择器是否显示
  bool _showTagSelector = false;
  // 文章服务
  final PostService _postService = PostService();

  @override
  void initState() {
    super.initState();
    // 界面加载完成后自动弹出键盘
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    // 获取用户信息
    _loadUserInfo();
  }

  // 获取用户信息
  Future<void> _loadUserInfo() async {
    final userInfo = await SharedPrefsUtils.getUserInfo();
    setState(() {
      _userInfo = userInfo;
      // 初始化标签列表
      _tags = [
        if (userInfo?['categoryName1'] != null) userInfo!['categoryName1'],
        if (userInfo?['categoryName2'] != null) userInfo!['categoryName2'],
        if (userInfo?['categoryName3'] != null) userInfo!['categoryName3'],
      ];
    });
  }

  // 选择图片
  Future<void> _pickImage() async {
    final File? pickedImage = await ImagePickerUtil.pickImageFromGallery();

    if (pickedImage != null) {
      setState(() {
        _selectedImage = pickedImage;
      });

      // 打印图片路径
      debugPrint('选择的图片路径: ${pickedImage.path}');
    }
  }

  @override
  void dispose() {
    // 释放资源，避免内存泄漏
    _postController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int? _getCategoryIdFromTag(String tag) {
    if (_userInfo == null) return null;

    final Map<String, int> tagToCategory = {
      if (_userInfo?['categoryName1'] != null)
        _userInfo!['categoryName1']: _userInfo?['categoryId1'] ?? 0,
      if (_userInfo?['categoryName2'] != null)
        _userInfo!['categoryName2']: _userInfo?['categoryId2'] ?? 0,
      if (_userInfo?['categoryName3'] != null)
        _userInfo!['categoryName3']: _userInfo?['categoryId3'] ?? 0,
    };

    return tagToCategory[tag];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 左侧关闭按钮
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        // 页面标题
        // title: Text(
        //   widget.type.toString(),
        //   style: TextStyle(fontWeight: FontWeight.bold),
        // ),
        // 右侧操作按钮
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              // 当有内容时才能点击发布
              onPressed:
                  (_characterCount > 0 || _selectedImage != null) &&
                          !_isLoading &&
                          _selectedTag != null
                      ? _handlePost
                      : null,
              style: ElevatedButton.styleFrom(
                // 根据是否有内容设置不同的按钮颜色
                backgroundColor:
                    (_characterCount > 0 || _selectedImage != null)
                        ? Colors.blue
                        : Colors.grey.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                elevation: 0,
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Text(
                        widget.type.toString(),
                        style: const TextStyle(
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
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 1.8,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: TextField(
                    // 输入框初始高度
                    minLines: 4,
                    controller: _postController,
                    focusNode: _focusNode,
                    autofocus: true,
                    maxLines: null, // 允许多行输入
                    maxLength: _maxCharacters, // 最大字符限制
                    decoration: const InputDecoration(
                      hintText: '想记下点什么？',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
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
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(height: 16),
                  _buildImagePreview(),
                ],
                const SizedBox(height: 16),
                _buildActionButtons(),
                const SizedBox(height: 20),
                _buildTagSelector(),

                // 添加足够的底部空间，防止内容被遮挡
                if (widget.type != "发布")
                  PostLitArticle(articleData: widget.articelData),
                // SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                _buildCharCounter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建标签选择器触发按钮
  Widget _buildTagSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () {
          // 点击时隐藏键盘
          FocusScope.of(context).unfocus();
          // 显示标签选择页面
          _showTagSelectionPage();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade200),
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              _selectedTag != null
                  ? Icon(
                    Icons.local_offer,
                    size: 20,
                    color: const Color.fromRGBO(111, 107, 204, 1),
                  )
                  : const Icon(
                    Icons.local_offer_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedTag ?? '添加标签',
                  style: TextStyle(
                    color:
                        _selectedTag != null
                            ? const Color.fromRGBO(111, 107, 204, 1)
                            : Colors.black87,
                    fontSize: 18,
                    fontWeight:
                        _selectedTag != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade500, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // 显示标签选择页面
  void _showTagSelectionPage() {
    if (_tags.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('标签加载中，请稍后再试')));
      return;
    }

    // 使用PageRouteBuilder创建从右侧滑入的动画效果
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => TagList(
              tags: _tags,
              selectedTag: _selectedTag,
              onTagSelected: (tag) {
                setState(() {
                  _selectedTag = tag;
                });
              },
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    // 如果已经选择图片了就不显示此按钮
    if (_selectedImage != null) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02),
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.16,
            height: MediaQuery.of(context).size.width * 0.16,
            decoration: BoxDecoration(
              color: const Color.fromARGB(103, 38, 196, 133),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF26C485), width: 3),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
                size: 28,
              ),
              onPressed: _pickImage,
              tooltip: '添加图片',
            ),
          ),
        ],
      ),
    );
  }

  /// 构建图片预览
  Widget _buildImagePreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(_selectedImage!),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // 整个区域可点击预览大图
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showFullScreenImage,
              borderRadius: BorderRadius.circular(12),
              child: Container(width: double.infinity, height: double.infinity),
            ),
          ),
          // 右上角删除按钮
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImage = null;
                });
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 显示全屏图片预览
  void _showFullScreenImage() {
    if (_selectedImage == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
                title: const Text(
                  '图片预览',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              body: Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.file(_selectedImage!, fit: BoxFit.contain),
                ),
              ),
            ),
      ),
    );
  }

  /// 构建字符计数器
  Widget _buildCharCounter() {
    // 计算剩余字符数
    final remainingChars = _maxCharacters - _characterCount;
    final isNearLimit = remainingChars <= 20;

    return Container(
      margin: const EdgeInsets.only(left: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$_characterCount/$_maxCharacters',
            style: TextStyle(
              color: isNearLimit ? Colors.red : Colors.grey,
              fontSize: 14,
            ),
          ),
          if (isNearLimit) ...[
            const SizedBox(width: 8),
            CircularProgressIndicator(
              value: _characterCount / _maxCharacters,
              strokeWidth: 2,
              color: remainingChars <= 0 ? Colors.red : Colors.orange,
              backgroundColor: Colors.grey.shade200,
            ),
          ],
        ],
      ),
    );
  }

  /// 处理发布操作
  void _handlePost() async {
    // 如果用户信息未加载，则不能发布
    if (_userInfo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('用户信息加载中，请稍后再试')));
      return;
    }

    // 设置加载状态
    setState(() {
      _isLoading = true;
    });

    try {
      // 准备发布内容
      final content = _postController.text;
      final tag = _selectedTag;

      // 如果选择了标签，则获取对应的分类ID
      int? categoryId;
      if (tag != null) {
        categoryId = _getCategoryIdFromTag(tag);
        if (categoryId == null) {
          throw Exception('无法获取标签对应的分类ID');
        }
      } else {
        // 默认分类ID，如果没有选择标签
        categoryId = 1;
      }

      // 调用API发布文章
      if (widget.type == '评论') {
        // 确保文章数据中的 ID 是整数类型
        final int articleId =
            widget.articelData['id'] is int
                ? widget.articelData['id']
                : int.parse(widget.articelData['id'].toString());
        await _postService.postComment(
          content: content,
          userId: _userInfo!['id'],
          username: _userInfo!['username'],
          articleId: articleId,
          categoryId: categoryId,
          becommentarticleId: articleId,
          imageFile: _selectedImage, // 传递选择的图片文件
        );
      } else if (widget.type == '转发') {
        // 确保文章数据中的 ID 是整数类型
        final int articleId =
            widget.articelData['id'] is int
                ? widget.articelData['id']
                : int.parse(widget.articelData['id'].toString());
        await _postService.postShareArticle(
          originalArticleId: articleId,
          content: content,
          userId: _userInfo!['id'],
          username: _userInfo!['username'],
          categoryId: categoryId,
          imageFile: _selectedImage, // 传递选择的图片文件
        );
      } else {
        await _postService.postArticle(
          content: content,
          userId: _userInfo!['id'],
          username: _userInfo!['username'],
          categoryId: categoryId,
          imageFile: _selectedImage, // 传递选择的图片文件
        );
      }

      // 发布成功后返回上一页
      if (mounted) {
        Navigator.pop(context);

        // 显示发布成功提示
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('发布成功！')));
      }
    } catch (e) {
      // 处理错误
      debugPrint('发布失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('发布失败: $e')));
      }
    } finally {
      // 恢复状态
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
