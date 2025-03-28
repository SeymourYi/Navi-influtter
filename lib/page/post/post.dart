// post_page.dart - 发布页面
import 'package:flutter/material.dart';
// ignore: unused_import
import '../../models/post_article_model.dart';
import '../../Store/storeutils.dart';
import '../../api/postApi.dart';

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
  // 用户数据
  Map<String, dynamic>? _userInfo;
  // 是否正在发布
  bool _isLoading = false;
  // 选中的标签
  String? _selectedTag;
  // 标签列表
  final List<String> _tags = [
    '技术交流',
    '生活随笔',
    '学习笔记',
    '旅行日记',
    '美食分享',
    '热点话题',
    '职场经验',
  ];
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
    });
  }

  @override
  void dispose() {
    // 释放资源，避免内存泄漏
    _postController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // 获取标签对应的分类ID
  int? _getCategoryIdFromTag(String tag) {
    // 这里简化处理，实际应用中可能需要从API获取真实的分类ID
    final Map<String, int> tagToCategory = {
      '技术交流': 1,
      '生活随笔': 2,
      '学习笔记': 3,
      '旅行日记': 4,
      '美食分享': 5,
      '热点话题': 6,
      '职场经验': 7,
    };
    return tagToCategory[tag];
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
              onPressed:
                  _characterCount > 0 && !_isLoading ? _handlePost : null,
              style: ElevatedButton.styleFrom(
                // 根据是否有内容设置不同的按钮颜色
                backgroundColor:
                    _characterCount > 0 ? Colors.blue : Colors.grey.shade400,
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
                      : const Text(
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
      body: Stack(
        children: [
          GestureDetector(
            // 点击空白区域隐藏键盘和标签选择器
            onTap: () {
              FocusScope.of(context).unfocus();
              setState(() {
                _showTagSelector = false;
              });
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserInfo(),
                    const SizedBox(height: 20),
                    _buildTagSelector(),
                    const SizedBox(height: 16),
                    _buildCharCounter(),
                    // 添加足够的底部空间，防止内容被遮挡
                    SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                  ],
                ),
              ),
            ),
          ),
          // 标签选择器弹出层
          if (_showTagSelector) _buildTagSelectorPanel(),
        ],
      ),
    );
  }

  /// 构建用户信息和输入区域
  Widget _buildUserInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 用户头像
        CircleAvatar(
          radius: 24,
          backgroundImage:
              _userInfo != null && _userInfo!['userPic'].isNotEmpty
                  ? NetworkImage(_userInfo!['userPic'])
                  : const NetworkImage(
                    'https://pbs.twimg.com/profile_images/1489998192095043586/4VrvN5yt_400x400.jpg',
                  ),
          backgroundColor: Colors.grey.shade200,
        ),
        const SizedBox(width: 12),
        // 用户信息和输入框
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户名称
              Text(
                _userInfo != null ? _userInfo!['nickname'] : '加载中...',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              // 用户ID
              Text(
                _userInfo != null ? '@${_userInfo!['username']}' : '@加载中...',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 16),
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

  /// 构建标签选择器触发按钮
  Widget _buildTagSelector() {
    return Container(
      margin: const EdgeInsets.only(left: 60),
      child: InkWell(
        onTap: () {
          setState(() {
            _showTagSelector = !_showTagSelector;
          });
          // 点击时隐藏键盘
          FocusScope.of(context).unfocus();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                _selectedTag != null
                    ? const Color(0xFFE1F5FE)
                    : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  _selectedTag != null
                      ? const Color(0xFF2196F3)
                      : Colors.grey.shade300,
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_offer_outlined,
                size: 16,
                color:
                    _selectedTag != null
                        ? const Color(0xFF2196F3)
                        : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                _selectedTag ?? '添加标签',
                style: TextStyle(
                  color:
                      _selectedTag != null
                          ? const Color(0xFF2196F3)
                          : Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight:
                      _selectedTag != null
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                color:
                    _selectedTag != null
                        ? const Color(0xFF2196F3)
                        : Colors.grey.shade600,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建标签选择器面板
  Widget _buildTagSelectorPanel() {
    return Positioned(
      top: 180, // 位置根据实际UI调整
      left: 16,
      right: 16,
      child: Card(
        elevation: 8,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Text(
                      '选择标签',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        setState(() {
                          _showTagSelector = false;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [for (String tag in _tags) _buildTagChip(tag)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建标签选择芯片
  Widget _buildTagChip(String tag) {
    final isSelected = _selectedTag == tag;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTag = isSelected ? null : tag;
              _showTagSelector = false;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color:
                  isSelected ? const Color(0xFFE3F2FD) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Text(
                  tag,
                  style: TextStyle(
                    color:
                        isSelected
                            ? const Color(0xFF2196F3)
                            : Colors.grey.shade800,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Color(0xFF2196F3),
                  ),
              ],
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
      await _postService.postArticle(
        content: content,
        userId: _userInfo!['id'],
        username: _userInfo!['username'],
        categoryId: categoryId,
      );

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
