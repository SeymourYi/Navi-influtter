// edit_profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:Navi/api/userAPI.dart';
import 'package:Navi/Store/storeutils.dart';
import 'package:Navi/api/userRegisterAPI.dart';
import 'package:Navi/page/login/login.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final UserService _userService = UserService();
  final UserRegisterService _userRegisterService = UserRegisterService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _userInfo;

  // Controllers for text fields
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();

  // Image files
  File? _userPicFile;
  File? _bgImgFile;

  // Character limits
  final int _nicknameMaxLength = 10;
  final int _bioMaxLength = 100;
  final int _locationMaxLength = 30;
  final int _professionMaxLength = 20;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _nicknameController.addListener(() => setState(() {}));
    _bioController.addListener(() => setState(() {}));
    _locationController.addListener(() => setState(() {}));
    _professionController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userInfo = await SharedPrefsUtils.getUserInfo();
      if (userInfo != null) {
        setState(() {
          _userInfo = userInfo;
          _nicknameController.text = userInfo['nickname'] ?? '';
          _bioController.text = userInfo['bio'] ?? '';
          _locationController.text = userInfo['location'] ?? '';
          _professionController.text = userInfo['profession'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载用户信息失败: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserInfo() async {
    if (_formKey.currentState!.validate() && _userInfo != null) {
      setState(() {
        _isSaving = true;
      });

      try {
        // Prepare image files
        MultipartFile? userPicMultipartFile;
        if (_userPicFile != null) {
          userPicMultipartFile = await MultipartFile.fromFile(
            _userPicFile!.path,
            filename: _userPicFile!.path.split('/').last,
          );
        }

        MultipartFile? bgImgMultipartFile;
        if (_bgImgFile != null) {
          bgImgMultipartFile = await MultipartFile.fromFile(
            _bgImgFile!.path,
            filename: _bgImgFile!.path.split('/').last,
          );
        }

        // Call API to update user info
        await _userService.updateUserInfo(
          id: _userInfo!['id'],
          username: _userInfo!['username'],
          nickname: _nicknameController.text,
          bio: _bioController.text,
          location: _locationController.text,
          profession: _professionController.text,
          userPicFile: userPicMultipartFile,
          bgImgFile: bgImgMultipartFile,
          categoryId1: _userInfo!['categoryId1'] ?? 0,
          categoryId2: _userInfo!['categoryId2'] ?? 0,
          categoryId3: _userInfo!['categoryId3'] ?? 0,
          categoryName1: _userInfo!['categoryName1'] ?? '',
          categoryName2: _userInfo!['categoryName2'] ?? '',
          categoryName3: _userInfo!['categoryName3'] ?? '',
        );

        // Refresh user info
        bool refreshSuccessful = await _userService.refreshUserInfo();

        if (refreshSuccessful) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('个人信息已更新')));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('个人信息已更新')));
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source, bool isProfilePic) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          if (isProfilePic) {
            _userPicFile = File(image.path);
          } else {
            _bgImgFile = File(image.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('选择图片失败: $e')));
    }
  }

  void _showImagePickerModal(bool isProfilePic) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('从相册选择'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery, isProfilePic);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('拍照'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera, isProfilePic);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '未设置';
    }
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.year}年${date.month}月${date.day}日加入';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _deregisterAccount() async {
    if (_userInfo == null || _userInfo!['username'] == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await _userRegisterService.register(_userInfo!['username']);
      await SharedPrefsUtils.clearUserInfo();
      await SharedPrefsUtils.clearToken();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
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
          _isSaving = false;
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

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF2196F3);

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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '账号信息',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveUserInfo,
            child: _isSaving
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                      color: Colors.grey,
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                child: const Text(
                  '保存',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                      ),
                  ),
                ),
              ),
        ],
      ),
      body: _isLoading
              ? const Center(child: CircularProgressIndicator())
          : Form(
                  key: _formKey,
              child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Banner Image with Profile Picture
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 背景图片 - 整个区域可点击
                        GestureDetector(
                          onTap: () => _showImagePickerModal(false),
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                            ),
                            child: _bgImgFile != null
                                ? Image.file(
                                    _bgImgFile!,
                                    fit: BoxFit.cover,
                                  )
                                : (_userInfo != null &&
                                        _userInfo!['bgImg'] != null &&
                                        _userInfo!['bgImg'].toString().isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: _userInfo!['bgImg'],
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: Colors.grey[200],
                                          child: const Center(
                                            child: Icon(
                                              Icons.image,
                                              size: 30,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.green[100]!,
                                              Colors.orange[100]!,
                                              Colors.yellow[100]!,
                                            ],
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.landscape,
                                            size: 30,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )),
                          ),
                        ),
                        // Profile Picture overlapping banner - 方形圆角，与ME界面一致
                        Positioned(
                          left: 16,
                          bottom: -40,
                          child: GestureDetector(
                            onTap: () => _showImagePickerModal(true),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: _userPicFile != null
                                    ? Image.file(
                                        _userPicFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : (_userInfo != null &&
                                            _userInfo!['userPic'] != null &&
                                            _userInfo!['userPic']
                                                .toString()
                                                .isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: _userInfo!['userPic'],
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(),
                                            errorWidget: (context, url, error) =>
                                                Container(
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.person,
                                                size: 32,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.person,
                                              size: 32,
                                              color: Colors.grey,
                                            ),
                                          )),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // Form Fields
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 昵称
                          _buildInputField(
                            label: '昵称',
                            controller: _nicknameController,
                            maxLength: _nicknameMaxLength,
                            hintText: '请输入昵称',
                          ),
                          const SizedBox(height: 24),

                          // 个人签名
                          _buildInputField(
                            label: '个人签名',
                            controller: _bioController,
                            maxLength: _bioMaxLength,
                            hintText: '介绍一下自己吧...',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),

                          // 位置
                          _buildInputField(
                            label: '位置',
                            controller: _locationController,
                            maxLength: _locationMaxLength,
                            hintText: '你在哪里?',
                          ),
                          const SizedBox(height: 24),

                          // 职业
                          _buildInputField(
                            label: '职业',
                            controller: _professionController,
                            maxLength: _professionMaxLength,
                            hintText: '请输入职业',
                          ),
                          const SizedBox(height: 24),

                          // 用户名 (只读)
                          _buildReadOnlyField(
                            label: '用户名',
                            value: _userInfo?['username'] ?? '',
                          ),
                          const SizedBox(height: 24),

                          // 生日 (只读)
                          _buildReadOnlyField(
                            label: '生日',
                            value: '未设置',
                          ),
                          const SizedBox(height: 24),

                          // 注册时间 (只读)
                          _buildReadOnlyField(
                            label: '注册时间',
                            value: _formatDate(_userInfo?['createTime']),
                          ),
                          const SizedBox(height: 24),

                          // 用户ID (只读)
                          _buildReadOnlyField(
                            label: '用户ID',
                            value: _userInfo?['id']?.toString() ?? '',
                          ),
                          const SizedBox(height: 32),

                          // 危险操作部分
                          const Text(
                            '危险操作',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.red[700],
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  '注销账号',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '注销后,您的所有数据将被永久删除,无法恢复',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red[300],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSaving
                                        ? null
                                        : _confirmDeregister,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      '注销账号',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                  ),
                ),
              ),
            ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
          ),
        ],
                ),
              ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required int maxLength,
    String? hintText,
    int maxLines = 1,
  }) {
    final int currentLength = controller.text.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLength: maxLength,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            counterText: '$currentLength/$maxLength',
            counterStyle: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const Divider(height: 32),
      ],
    );
  }
}
