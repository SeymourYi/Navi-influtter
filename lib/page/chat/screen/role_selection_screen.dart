import 'package:flutter/material.dart';

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

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  CharacterRole? _selectedRole;
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _customDescController = TextEditingController();
  bool _showCustomForm = false;

  // 预定义的角色列表 - 三国人物
  final List<CharacterRole> _roles = [
    CharacterRole(
      id: 'lvbu',
      name: '吕布',
      description: '三国第一猛将，"人中吕布，马中赤兔"',
      imageAsset: 'assets/images/lvbu.jpg', // 假设有这个图片
      color: Colors.red.shade700,
    ),
    CharacterRole(
      id: 'zhangfei',
      name: '张飞',
      description: '蜀国猛将，"万人敌"，三英战吕布之一',
      imageAsset: 'assets/images/zhangfei.jpg',
      color: Colors.black,
    ),
    CharacterRole(
      id: 'guanyu',
      name: '关羽',
      description: '蜀国名将，"美髯公"，忠义无双',
      imageAsset: 'assets/images/guanyu.jpg',
      color: Colors.green.shade800,
    ),
    CharacterRole(
      id: 'caocao',
      name: '曹操',
      description: '魏国开国皇帝，乱世枭雄，"宁教我负天下人，不教天下人负我"',
      imageAsset: 'assets/images/caocao.jpg',
      color: Colors.blue.shade900,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择你的角色'),
        backgroundColor: Colors.amber.shade800,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '请选择一个三国角色进入聊天:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade800,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _roles.length + 1, // 加一个创建自定义角色的卡片
              itemBuilder: (context, index) {
                if (index == _roles.length) {
                  // 最后一个卡片是创建自定义角色
                  return _buildCreateCustomRoleCard();
                }
                final role = _roles[index];
                final isSelected = _selectedRole == role;
                return _buildRoleCard(role, isSelected);
              },
            ),
          ),
          if (_showCustomForm) _buildCustomRoleForm(),
          if (!_showCustomForm)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed:
                    _selectedRole == null
                        ? null
                        : () => widget.onRoleSelected(_selectedRole!),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor:
                      _selectedRole?.color ?? Colors.amber.shade800,
                ),
                child: Text(
                  '以 ${_selectedRole?.name ?? ''} 身份进入聊天',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(CharacterRole role, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
          _showCustomForm = false;
        });
      },
      child: Card(
        elevation: isSelected ? 8 : 2,
        color: isSelected ? role.color.withOpacity(0.2) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? role.color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 角色图片 - 使用占位符或 CircleAvatar
              CircleAvatar(
                radius: 40,
                backgroundColor: role.color.withOpacity(0.3),
                child: Text(
                  role.name.substring(0, 1),
                  style: TextStyle(
                    fontSize: 36,
                    color: role.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                role.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: role.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                role.description,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (role.isCustom)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Chip(
                    label: const Text('自定义角色'),
                    backgroundColor: Colors.amber.shade100,
                    labelStyle: TextStyle(
                      fontSize: 10,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateCustomRoleCard() {
    return InkWell(
      onTap: () {
        setState(() {
          _showCustomForm = true;
          _selectedRole = null;
        });
      },
      child: Card(
        elevation: 2,
        color: Colors.amber.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Colors.amber.shade300,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 50,
              color: Colors.amber.shade800,
            ),
            const SizedBox(height: 12),
            Text(
              '创建自定义角色',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '创建你自己的三国角色',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomRoleForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '创建自定义角色',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _customNameController,
            decoration: const InputDecoration(
              labelText: '角色名称',
              border: OutlineInputBorder(),
              helperText: '例如: 赵云、黄忠、刘备等',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _customDescController,
            decoration: const InputDecoration(
              labelText: '角色描述',
              border: OutlineInputBorder(),
              helperText: '简短的角色描述',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _showCustomForm = false;
                  });
                },
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: _createCustomRole,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade800,
                ),
                child: const Text('创建角色'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _createCustomRole() {
    if (_customNameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入角色名称')));
      return;
    }

    // 创建自定义角色
    final customRole = CharacterRole(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: _customNameController.text,
      description:
          _customDescController.text.isEmpty
              ? '自定义角色'
              : _customDescController.text,
      imageAsset: '', // 无图片
      color: Colors.amber.shade800,
      isCustom: true,
    );

    // 添加到角色列表
    setState(() {
      _roles.add(customRole);
      _selectedRole = customRole;
      _showCustomForm = false;
      _customNameController.clear();
      _customDescController.clear();
    });
  }
}
