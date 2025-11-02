// post_page.dart - 发布页面
import 'package:Navi/components/class/utils/DialogUtils.dart';
import 'package:Navi/components/litarticle.dart';
import 'package:Navi/components/postlitarticle.dart';
import 'package:Navi/page/post/components/imagepicker.dart';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';
// ignore: unused_import
import '../../models/post_article_model.dart';
import '../../Store/storeutils.dart';
import '../../api/postApi.dart';
// import '../../utils/imagepick.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'components/targlist.dart';

/// 发布页面的无状态组件
class PostPage extends StatefulWidget {
  const PostPage({
    Key? key,
    this.articelData, // Optional article data
    this.uparticledata,
    required this.type,
  }) : super(key: key);

  final dynamic
  articelData; // Consider using a specific type instead of dynamic
  final dynamic
  uparticledata; // Consider using a specific type instead of dynamic
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
  // 图片列表，用于支持多张图片
  List<File> _selectedImages = [];
  // 标签列表
  List<String> _tags = [];

  // 标签选择器是否显示
  bool _showTagSelector = false;
  // 文章服务
  final PostService _postService = PostService();
  // 标记是否是第一次使用图片选择器
  bool _isFirstTimeUsingImagePicker = true;

  @override
  void initState() {
    super.initState();
    // 界面加载完成后自动弹出键盘
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    // 获取用户信息
    _loadUserInfo();
    // 检查是否第一次使用图片选择器
    _checkFirstTimeUsingImagePicker();
  }

  void _showAgreementDialog() {
    DialogUtils.showPrivacyDialog(
      context: context,
      title: '请阅读下方隐私政策',
      content: "SAD",
      onAgree: () {
        setState(() {});
        Navigator.of(context).pop();
      },
      onDisagree: () {
        Navigator.of(context).pop();
      },
    );
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

  // 检查是否第一次使用图片选择器
  Future<void> _checkFirstTimeUsingImagePicker() async {
    final prefs = await SharedPreferences.getInstance();
    final firstTime = prefs.getBool('first_time_using_image_picker') ?? true;
    setState(() {
      _isFirstTimeUsingImagePicker = firstTime;
    });
    if (firstTime) {
      // 延迟显示提示，让界面先加载完成
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          _showImagePickerTutorial();
          // _showAgreementDialog();
        }
      });
    }
  }

  // 显示图片选择器教程
  void _showImagePickerTutorial() {
    showDialog(
      context: context,
      builder:
          (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Color(0xFF6201E7),
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '图片选择器使用提示',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTipItem('📸', '点击相机图标打开图片选择器'),
                const SizedBox(height: 8),
                _buildTipItem('✅', '可以同时选择多张图片（最多9张）'),
                const SizedBox(height: 8),
                _buildTipItem('🔄', '长按图片可以进行编辑、预览等操作'),
                const SizedBox(height: 8),
                _buildTipItem('⬆️', '上滑关闭图片选择器'),
                const SizedBox(height: 8),
                _buildTipItem('📋', '点击"排序"可以调整图片顺序'),
                const SizedBox(height: 8),
                _buildTipItem('👆', '点击图片可以查看大图'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: Text(
                  '知道了',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // 标记为不再显示
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('first_time_using_image_picker', false);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6201E7),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  elevation: 0,
                ),
                child: const Text(
                  '不再提示',
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

  Widget _buildTipItem(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  // 选择图片
  Future<void> _pickImage() async {
    try {
      // 如果是第一次使用，先显示教程
      if (_isFirstTimeUsingImagePicker) {
        setState(() {
          _isFirstTimeUsingImagePicker = false;
        });
        // 保存用户已经看过教程
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('first_time_using_image_picker', false);
      }

      final result = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => ImagePickerScreen(
                initialImages: _selectedImages,
                onImagesSelected: (images) {
                  setState(() {
                    _selectedImages = images;
                  });
                },
                maxImages: 9,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
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

      // 如果返回了结果（选择了图片），则更新状态
      if (result != null && result is List<File>) {
        setState(() {
          _selectedImages = result;
        });
        debugPrint('选择了 ${_selectedImages.length} 张图片');
      }
    } catch (e) {
      debugPrint('打开图片选择器失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('打开图片选择器失败: $e')));
      }
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
    // 转发时，即使内容为空也可以发布（因为转发可能只是转发原内容）
    final bool canPublish = widget.type == "转发"
        ? (!_isLoading) // 转发时只要不在加载中就可以发布
        : ((_characterCount > 0 || _selectedImages.isNotEmpty) && !_isLoading);
    
    // 根据类型获取标题和按钮文案
    String getAppBarTitle() {
      switch (widget.type) {
        case '评论':
          return '评论';
        case '回复':
          return '回复';
        case '转发':
          return '转发';
        default:
          return '发布文章';
      }
    }
    
    String getButtonText() {
      switch (widget.type) {
        case '评论':
          return '评论';
        case '回复':
          return '回复';
        case '转发':
          return '转发';
        default:
          return '发表';
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // 左侧关闭按钮 - 朝下箭头
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 24, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // 中间标题 - 根据类型显示不同标题
        title: Text(
          getAppBarTitle(),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        // 右侧发表按钮 - 使用主题色
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: TextButton(
              onPressed: canPublish ? _handlePost : null,
              style: TextButton.styleFrom(
                backgroundColor: canPublish 
                    ? Color(0xFF6201E7) 
                    : Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      getButtonText(),
                      style: TextStyle(
                        color: canPublish ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(height: 0.5, color: Colors.grey.shade200),
        ),
      ),
      // 主体内容区域
      body: GestureDetector(
        // 点击空白区域隐藏键盘
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 被评论的文章预览 - 移到最上面
              if (widget.type != "发布") ...[
                // 提示文字
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        widget.type == "评论" 
                            ? Icons.chat_bubble_outline 
                            : widget.type == "回复"
                                ? Icons.reply
                                : Icons.repeat,
                        size: 16,
                        color: Color(0xFF6201E7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.type == "评论" 
                            ? "正在评论这条内容"
                            : widget.type == "回复"
                                ? "正在回复这条评论"
                                : "正在转发这条内容",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6201E7),
                        ),
                      ),
                    ],
                  ),
                ),
                PostLitArticle(articleData: widget.articelData),
                const SizedBox(height: 20),
                Divider(height: 1, color: Colors.grey.shade200),
                const SizedBox(height: 16),
              ],

              // 用户信息区域：头像 + 用户名 - 推特风格
              if (_userInfo != null) ...[
                Row(
                  children: [
                    // 用户头像 - 方形圆角（减小圆角）
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: _userInfo!['userPic'] != null &&
                              _userInfo!['userPic'].toString().isNotEmpty
                          ? Image.network(
                              _userInfo!['userPic'],
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 40,
                                  height: 40,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                );
                              },
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 24,
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    // 用户名
                    Text(
                      _userInfo!['nickname'] ?? '用户',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              
              // 内容输入框 - 推特风格（增加高度）
              TextField(
                controller: _postController,
                focusNode: _focusNode,
                autofocus: true,
                maxLines: null, // 允许多行输入
                minLines: 4, // 设置最小行数，增加初始高度
                maxLength: _maxCharacters, // 最大字符限制
                decoration: InputDecoration(
                  hintText: widget.type == "评论" 
                      ? '写下你的评论...'
                      : widget.type == "回复"
                          ? '写下你的回复...'
                          : widget.type == "转发"
                              ? '添加评论（可选）...'
                              : '这一刻的想法...',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                  border: InputBorder.none,
                  counterText: '', // 隐藏默认的字符计数器
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
                // 监听文本变化，更新字符计数
                onChanged: (text) {
                  setState(() => _characterCount = text.length);
                },
              ),
              
              const SizedBox(height: 12),
              
              // 媒体附件区域
              _buildMediaAttachmentArea(),
              
              const SizedBox(height: 16),
              
              // 标签管理区域
              _buildTagSelector(),
              
              // 底部空白区域 - 确保有足够空间，特别是转发/评论时
              SizedBox(height: widget.type != "发布" ? 100 : 40),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建标签选择器触发按钮 - 推特风格
  Widget _buildTagSelector() {
    return InkWell(
      onTap: () {
        // 点击时隐藏键盘
        FocusScope.of(context).unfocus();
        // 显示标签选择页面
        _showTagSelectionPage();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 左侧：添加标签文字
            const Text(
              '添加标签',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            // 右侧：标签名称或无 + 右箭头
            Row(
              children: [
                Text(
                  _selectedTag ?? '无',
                  style: TextStyle(
                    color: _selectedTag != null 
                        ? Color(0xFF6201E7) 
                        : Colors.grey[600],
                    fontSize: 15,
                    fontWeight: _selectedTag != null 
                        ? FontWeight.w500 
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ],
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

  /// 构建媒体附件区域
  Widget _buildMediaAttachmentArea() {
    // 如果有图片，显示图片网格
    if (_selectedImages.isNotEmpty) {
      return _buildImagesGrid();
    }
    
    // 如果没有图片，显示占位符 - 推特风格
    return GestureDetector(
      onTap: _selectedImages.length < 9 ? _pickImage : null,
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Center(
          child: Icon(
            Icons.add_photo_alternate_outlined,
            size: 32,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  /// 构建图片网格显示 - 支持拖拽排序和拖动到垃圾桶
  Widget _buildImagesGrid() {
    return _DraggableImageGrid(
      images: _selectedImages,
      maxImages: 9,
      onImageReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final item = _selectedImages.removeAt(oldIndex);
          _selectedImages.insert(newIndex, item);
        });
      },
      onImageDelete: (index) {
        setState(() {
          _selectedImages.removeAt(index);
        });
      },
      onImageTap: (index) => _showFullScreenImage(index),
      onAddImageTap: _pickImage,
    );
  }

  /// 构建单个图片瓦片 - 已移至_DraggableImageGrid内部
  Widget _buildImageTile(File image, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: FileImage(image), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            // 整个区域可点击预览大图
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showFullScreenImage(index),
                borderRadius: BorderRadius.circular(8),
                child: Hero(
                  tag: 'preview_image_$index',
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
            ),
            // 右上角删除按钮 - 优化样式
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImages.removeAt(index);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建字符计数器
  Widget _buildCharCounter() {
    // 计算剩余字符数
    final remainingChars = _maxCharacters - _characterCount;
    final isNearLimit = remainingChars <= 20;

    // 获取当前时间
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;
    final hour = now.hour;
    final minute = now.minute;

    // 确定时间段
    String period;
    if (hour >= 5 && hour < 12) {
      period = "上午";
    } else if (hour >= 12 && hour < 18) {
      period = "下午";
    } else if (hour >= 18 && hour < 22) {
      period = "晚上";
    } else {
      period = "凌晨";
    }

    // 格式化时间，确保分钟为两位数
    final minuteStr = minute < 10 ? "0$minute" : minute.toString();
    final timeString = "$month月$day日 $period$hour:$minuteStr";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            timeString,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Text(
                "$_characterCount字",
                style: TextStyle(
                  color: isNearLimit ? Colors.red : Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (isNearLimit) ...[
                const SizedBox(width: 8),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    value: _characterCount / _maxCharacters,
                    strokeWidth: 2,
                    color: remainingChars <= 0 ? Colors.red : Colors.orange,
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
              ],
            ],
          ),
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
        // 获取被评论文章的作者用户名
        final tousername = widget.articelData['username'] ?? '';
        await _postService.postComment(
          content: content,
          userId: _userInfo!['id'],
          username: _userInfo!['username'],
          articleId: articleId,
          categoryId: categoryId,
          becommentarticleId: articleId,
          tousername: tousername,
          imageFiles: _selectedImages, // 传递选择的图片文件列表
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
          imageFiles: _selectedImages, // 传递选择的图片文件列表
        );
      } else if (widget.type == '回复') {
        print(widget.articelData);
        print(widget.articelData);
        print(widget.articelData);
        final int articleId =
            widget.articelData['id'] is int
                ? widget.articelData['id']
                : int.parse(widget.articelData['id'].toString());

        // 获取被回复评论的作者用户名（必填）
        final tousername = widget.articelData['username'] ?? '';

        final uparticleId = int.parse(widget.uparticledata["id"]);
        await _postService.postComment(
          content: content,
          userId: _userInfo!['id'],
          username: _userInfo!['username'],
          articleId: articleId,
          categoryId: categoryId,
          becommentarticleId: uparticleId,
          tousername: tousername,
          imageFiles: _selectedImages, // 传递选择的图片文件列表
        );
      } else {
        // print("发布文章");
        // print(content);
        // print(_userInfo!['id']);
        // print(_userInfo!['username']);
        // print(categoryId);
        // print(_selectedImages);
        // print("发布文章");
        await _postService.postArticle(
          content: content,
          userId: _userInfo!['id'],
          username: _userInfo!['username'],
          categoryId: categoryId,
          imageFiles: _selectedImages, // 传递选择的图片文件列表
        );
      }

      // 发布成功后返回上一页
      if (mounted) {
        Navigator.pop(context);

        // 显示发布成功提示
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
          content: Text(
            widget.type == '评论' 
                ? '评论成功！'
                : widget.type == '回复'
                    ? '回复成功！'
                    : widget.type == '转发'
                        ? '转发成功！'
                        : '发布成功！'
          ),
        ));
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

  // 显示全屏图片预览
  void _showFullScreenImage([int index = 0]) {
    if (_selectedImages.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  '图片预览 ${index + 1}/${_selectedImages.length}',
                  style: const TextStyle(color: Colors.white),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _selectedImages.removeAt(index);
                      });
                      if (_selectedImages.isEmpty ||
                          index >= _selectedImages.length) {
                        Navigator.pop(context);
                      }
                    },
                    tooltip: '删除图片',
                  ),
                ],
              ),
              body: PageView.builder(
                controller: PageController(initialPage: index),
                itemCount: _selectedImages.length,
                itemBuilder: (context, pageIndex) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: InteractiveViewer(
                        panEnabled: true,
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 0.5,
                        maxScale: 4,
                        child: Hero(
                          tag: 'preview_image_$pageIndex',
                          child: Image.file(
                            _selectedImages[pageIndex],
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      ),
    );
  }

  /// 构建图片预览 (弃用)
  Widget _buildImagePreview() {
    return const SizedBox.shrink();
  }
}

/// 可拖拽的图片网格组件 - 类似微信的实现
class _DraggableImageGrid extends StatefulWidget {
  final List<File> images;
  final int maxImages;
  final Function(int oldIndex, int newIndex) onImageReorder;
  final Function(int index) onImageDelete;
  final Function(int index) onImageTap;
  final VoidCallback onAddImageTap;

  const _DraggableImageGrid({
    required this.images,
    required this.maxImages,
    required this.onImageReorder,
    required this.onImageDelete,
    required this.onImageTap,
    required this.onAddImageTap,
  });

  @override
  State<_DraggableImageGrid> createState() => _DraggableImageGridState();
}

class _DraggableImageGridState extends State<_DraggableImageGrid> {
  int? _draggedIndex;
  int? _targetIndex;
  bool _isDragging = false;
  bool _isOverTrash = false;
  final GlobalKey _gridKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = 16.0;
    final spacing = 8.0;
    final itemSize = (screenWidth - padding * 2 - spacing * 2) / 3;

    return Stack(
      children: [
        // 图片网格
        Wrap(
          key: _gridKey,
          spacing: spacing,
          runSpacing: spacing,
          children: [
            ...widget.images.asMap().entries.map((entry) {
              final index = entry.key;
              final image = entry.value;
              return _buildDraggableImageItem(
                image: image,
                index: index,
                itemSize: itemSize,
              );
            }),
            // 添加图片按钮
            if (widget.images.length < widget.maxImages)
              _buildAddImageButton(itemSize),
          ],
        ),
        // 垃圾桶（仅在拖动时显示）
        if (_isDragging)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isOverTrash
                      ? Colors.red.withOpacity(0.9)
                      : Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _isOverTrash
                          ? Colors.red.withOpacity(0.5)
                          : Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDraggableImageItem({
    required File image,
    required int index,
    required double itemSize,
  }) {
    final isDragging = _draggedIndex == index;
    final isTarget = _targetIndex == index && _draggedIndex != index;

    return LongPressDraggable<File>(
      data: image,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.1,
          child: Opacity(
            opacity: 0.8,
            child: _buildImageTile(image: image, index: index, itemSize: itemSize),
          ),
        ),
      ),
      onDragStarted: () {
        setState(() {
          _draggedIndex = index;
          _isDragging = true;
        });
      },
      onDragEnd: (details) {
        // 检查是否拖动到垃圾桶区域（使用之前设置的_isOverTrash状态）
        if (_isOverTrash) {
          // 拖动到垃圾桶，删除图片
          widget.onImageDelete(index);
        } else if (_targetIndex != null && _draggedIndex != null && _targetIndex != _draggedIndex) {
          // 如果移动到了新位置，执行排序
          widget.onImageReorder(_draggedIndex!, _targetIndex!);
        }

        setState(() {
          _draggedIndex = null;
          _targetIndex = null;
          _isDragging = false;
          _isOverTrash = false;
        });
      },
      onDragUpdate: (details) {
        // 检查是否在垃圾桶区域
        final screenHeight = MediaQuery.of(context).size.height;
        final trashAreaBottom = screenHeight - 60;
        final trashAreaTop = trashAreaBottom - 80;
        final isInTrashArea = details.globalPosition.dy >= trashAreaTop;

        setState(() {
          _isOverTrash = isInTrashArea;
        });

        // 如果不在垃圾桶区域，计算目标位置进行排序
        if (!isInTrashArea) {
          final RenderBox? gridRenderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
          if (gridRenderBox != null) {
            final gridPosition = gridRenderBox.localToGlobal(Offset.zero);
            final localPosition = details.globalPosition - gridPosition;
            
            final screenWidth = MediaQuery.of(context).size.width;
            final padding = 16.0;
            final spacing = 8.0;
            final itemWidth = (screenWidth - padding * 2 - spacing * 2) / 3;

            // 计算列和行（考虑Wrap的实际布局）
            final column = ((localPosition.dx) / (itemWidth + spacing)).floor().clamp(0, 2);
            final row = ((localPosition.dy) / (itemWidth + spacing)).floor().clamp(0, 2);
            
            final newIndex = (row * 3 + column).clamp(0, widget.images.length - 1);

            if (newIndex != _targetIndex && newIndex != index && newIndex >= 0) {
              setState(() {
                _targetIndex = newIndex;
              });
            }
          }
        }
      },
      childWhenDragging: Container(
        width: itemSize,
        height: itemSize,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1, style: BorderStyle.solid),
        ),
      ),
      child: DragTarget<File>(
        onAccept: (data) {
          // 排序逻辑已在onDragUpdate中处理，这里主要是为了UI反馈
        },
        onWillAccept: (data) {
          // 提供视觉反馈
          return true;
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: itemSize,
            height: itemSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isTarget
                  ? Border.all(color: const Color(0xFF6201E7), width: 2)
                  : null,
            ),
            child: _buildImageTile(
              image: image,
              index: index,
              itemSize: itemSize,
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageTile({
    required File image,
    required int index,
    required double itemSize,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: itemSize,
        height: itemSize,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: FileImage(image),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // 点击预览
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => widget.onImageTap(index),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            // 删除按钮
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => widget.onImageDelete(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImageButton(double itemSize) {
    return GestureDetector(
      onTap: widget.onAddImageTap,
      child: Container(
        width: itemSize,
        height: itemSize,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Center(
          child: Icon(
            Icons.add_photo_alternate_outlined,
            size: 24,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}
