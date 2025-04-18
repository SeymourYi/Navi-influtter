import 'package:Navi/api/getfriendlist.dart';
import 'package:Navi/page/chat/screen/useseletscreen.dart';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';
import '../config/app_config.dart';
import 'role_selection_screen.dart';
import '../../../Store/storeutils.dart';

class ChatScreen extends StatefulWidget {
  final dynamic initialChatCharacter; // 添加初始聊天角色参数

  const ChatScreen({super.key, this.initialChatCharacter});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  dynamic _selectedCharacter;
  dynamic _chatWithCharacter; // 当前选择聊天的角色
  late ChatService _chatService;
  bool _isConnected = false;
  bool _isConnecting = false;
  List<CharacterRole> _onlineCharacters = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    //TODO 确保在退出前保存聊天记录

    if (_isConnected && _selectedCharacter != null) {
      _chatService.saveChatsToStorage();
    }

    if (_isConnected) {
      _chatService.disconnect();
    }
    _messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // 可以在这里添加定期保存的逻辑，例如每5分钟保存一次
    _setupAutoSaving();
  }

  void _setupAutoSaving() {
    // 每5分钟自动保存一次聊天记录
    const duration = Duration(minutes: 5);
    Future.delayed(duration, () {
      if (mounted && _isConnected) {
        _chatService.saveChatsToStorage();
        _setupAutoSaving(); // 递归调用以实现定期执行
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (_selectedCharacter == null) {
    //   return RoleSelectionScreen(onRoleSelected: _handleCharacterSelected);
    // }
    return Scaffold(appBar: AppBar(title: Text('聊天')), body: UseSelectScreen());
  }
}
