// edit_profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:Navi/api/userAPI.dart';
import 'package:Navi/Store/storeutils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _userInfo;

  // 用于保存用户输入的文本控制器
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();

  // 用于处理图片
  File? _userPicFile;
  File? _bgImgFile;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
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
      // 获取本地存储的用户信息
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
        // 准备图片文件
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

        // 调用API更新用户信息
        final result = await _userService.updateUserInfo(
          id: _userInfo!['id'],
          username: _userInfo!['username'],
          nickname: _nicknameController.text,
          bio: _bioController.text,
          location: _locationController.text,
          profession: _professionController.text,
          userPicFile: userPicMultipartFile,
          bgImgFile: bgImgMultipartFile,
        );

        // 使用专用方法刷新用户信息
        bool refreshSuccessful = await _userService.refreshUserInfo();

        if (refreshSuccessful) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('个人信息已更新，数据已刷新')));
        } else {
          // 如果刷新失败，只更新本地修改的字段
          final updatedUserInfo = Map<String, dynamic>.from(_userInfo!);
          updatedUserInfo['nickname'] = _nicknameController.text;
          updatedUserInfo['bio'] = _bioController.text;
          updatedUserInfo['location'] = _locationController.text;
          updatedUserInfo['profession'] = _professionController.text;

          // 如果服务器返回了新的图片URL，更新本地存储
          if (result.containsKey('userPic') && result['userPic'] != null) {
            updatedUserInfo['userPic'] = result['userPic'];
          }
          if (result.containsKey('bgImg') && result['bgImg'] != null) {
            updatedUserInfo['bgImg'] = result['bgImg'];
          }

          await SharedPrefsUtils.saveUserInfo(updatedUserInfo);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('个人信息已更新')));
        }

        // 返回上一页，并传递true表示更新成功
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑个人资料'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          _isSaving
              ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
              : TextButton(
                onPressed: _saveUserInfo,
                child: const Text(
                  '保存',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfilePicture(),
                      const SizedBox(height: 24),
                      _buildBgImageSection(),
                      const SizedBox(height: 24),
                      _buildTextField('昵称', _nicknameController, true),
                      const SizedBox(height: 16),
                      _buildTextField('个人简介', _bioController, false),
                      const SizedBox(height: 16),
                      _buildTextField('职业', _professionController, false),
                      const SizedBox(height: 16),
                      _buildTextField('地点', _locationController, false),
                      const SizedBox(height: 24),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Column(
        children: [
          const Text('头像', style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 8),
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage:
                    _userPicFile != null
                        ? FileImage(_userPicFile!) as ImageProvider
                        : (_userInfo != null && _userInfo!['userPic'].isNotEmpty
                            ? CachedNetworkImageProvider(_userInfo!['userPic'])
                            : const AssetImage(
                              "lib/assets/images/userpic.jpg",
                            )),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.zero,
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.purple.shade400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => _showImagePickerModal(true),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBgImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('背景图', style: TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showImagePickerModal(false),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
              image:
                  _bgImgFile != null
                      ? DecorationImage(
                        image: FileImage(_bgImgFile!),
                        fit: BoxFit.cover,
                      )
                      : (_userInfo != null && _userInfo!['bgImg'].isNotEmpty
                          ? DecorationImage(
                            image: CachedNetworkImageProvider(
                              _userInfo!['bgImg'],
                            ),
                            fit: BoxFit.cover,
                          )
                          : null),
            ),
            child:
                _bgImgFile == null &&
                        (_userInfo == null || _userInfo!['bgImg'].isEmpty)
                    ? const Center(
                      child: Icon(
                        Icons.add_photo_alternate,
                        size: 50,
                        color: Colors.grey,
                      ),
                    )
                    : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool isRequired,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        TextFormField(
          controller: controller,
          maxLines: label == '个人简介' ? 3 : 1,
          decoration: const InputDecoration(
            isDense: true,
            border: UnderlineInputBorder(),
          ),
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label不能为空';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveUserInfo,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple.shade400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child:
            _isSaving
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : const Text(
                  '保存修改',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
      ),
    );
  }
}
