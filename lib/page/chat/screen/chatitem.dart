// import 'dart:async';
// import 'package:Navi/Store/storeutils.dart';
// import 'package:Navi/api/userAPI.dart';
// import 'package:flutter/material.dart';
// import '../models/chat_message.dart';
// import '../services/chat_service.dart';
// import '../config/app_config.dart';
// import 'role_selection_screen.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ChatItem extends StatefulWidget {
//   const ChatItem({super.key, required this.chatWithusername});

//   final chatWithusername;
//   @override
//   State<ChatItem> createState() => _ChatItemState();
// }

// class _ChatItemState extends State<ChatItem> {
//   dynamic _selectedCharacter = {};
//   dynamic _chatWithCharacter = {};
//   UserService server = UserService();
//   late ChatService _chatService;
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   List<ChatMessage> _messages = [];
//   bool _isConnected = false;
//   bool _isLoading = true;
//   bool _isLoadingMore = false;
//   bool _hasMoreMessages = true;
//   String? _lastMessageTime;

//   Future<void> _fetchUserInfo() async {
//     final userInfo = await SharedPrefsUtils.getUserInfo();
//     var res = await server.getsomeUserinfo(userInfo!["username"]);
//     var res2 = await server.getsomeUserinfo(widget.chatWithusername);
//     setState(() {
//       _selectedCharacter = res["data"];
//       _chatWithCharacter = res2["data"];
//     });
//     _initializeChatService();
//   }

//   void _initializeChatService() {
//     _chatService = ChatService(
//       serverUrl: AppConfig.serverUrl,
//       character: CharacterRole(
//         id: _selectedCharacter["username"],
//         name: _selectedCharacter["nickname"],
//         description: "",
//         imageAsset: "",
//         color: Colors.blue,
//       ),
//       onMessageReceived: _handleMessageReceived,
//       onUsersReceived: (users) {},
//       onError: (error) {
//         setState(() {
//           _isConnected = false;
//         });
//       },
//     );

//     _chatService.onConnectedCallback = () {
//       setState(() {
//         _isConnected = true;
//       });
//       _loadChatMessages();
//     };

//     _chatService.connect();
//   }

//   void _handleMessageReceived(ChatMessage message) {
//     setState(() {
//       _messages.add(message);
//       _isConnected = true;
//     });
//     _scrollToBottom();
//   }

//   Future<void> _loadChatMessages() async {
//     try {
//       setState(() {
//         _isLoading = true;
//       });

//       await _chatService.loadHistoricalMessages(widget.chatWithusername);

//       final messages = _chatService.getPrivateChatMessages(
//         widget.chatWithusername,
//       );

//       if (messages.isNotEmpty) {
//         _lastMessageTime = messages.first.time;
//       }

//       setState(() {
//         _messages = messages;
//         _isLoading = false;
//         _hasMoreMessages = messages.isNotEmpty;
//       });

//       _scrollToBottom();
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('加载历史消息失败: $e'),
//           action: SnackBarAction(label: '重试', onPressed: _loadChatMessages),
//         ),
//       );
//     }
//   }

//   Future<void> _loadMoreMessages() async {
//     if (_isLoadingMore || !_hasMoreMessages || _lastMessageTime == null) return;

//     try {
//       setState(() {
//         _isLoadingMore = true;
//       });

//       // 保存当前滚动位置
//       final currentScrollPosition = _scrollController.position.pixels;
//       final currentItemCount = _messages.length;

//       // 构建带时间戳的URL
//       final url =
//           '${AppConfig.httpUrl}/api/messages/private?userId1=${_selectedCharacter["username"]}&userId2=${widget.chatWithusername}&beforeTime=$_lastMessageTime';

//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final responseBody = response.body;
//         if (responseBody.isNotEmpty) {
//           final messagesJson = jsonDecode(responseBody);
//           final newMessages =
//               messagesJson
//                   .map<ChatMessage>((json) => ChatMessage.fromJson(json))
//                   .toList();

//           if (newMessages.isNotEmpty) {
//             _lastMessageTime = newMessages.first.time;
//             setState(() {
//               _messages = [...newMessages, ..._messages];
//               _isLoadingMore = false;
//               _hasMoreMessages = newMessages.length >= 20; // 假设每页20条消息
//             });

//             // 恢复滚动位置
//             if (_messages.length > currentItemCount) {
//               final newScrollPosition =
//                   currentScrollPosition +
//                   (_messages.length - currentItemCount) * 100.0; // 估计的消息高度
//               _scrollController.jumpTo(newScrollPosition);
//             }
//           } else {
//             setState(() {
//               _isLoadingMore = false;
//               _hasMoreMessages = false;
//             });
//           }
//         }
//       }
//     } catch (e) {
//       setState(() {
//         _isLoadingMore = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('加载更多消息失败: $e'),
//           action: SnackBarAction(label: '重试', onPressed: _loadMoreMessages),
//         ),
//       );
//     }
//   }

//   void _sendMessage() {
//     if (_messageController.text.trim().isEmpty) return;

//     _chatService.sendPrivateMessage(
//       widget.chatWithusername,
//       _messageController.text,
//     );
//     _messageController.clear();
//     _scrollToBottom();
//   }

//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         _scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }

//   Widget _buildMessageItem(ChatMessage message) {
//     final isMe = message.sender == _selectedCharacter["username"];
//     final bgColor = isMe ? Colors.blue.withOpacity(0.1) : Colors.grey.shade200;
//     final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Column(
//         crossAxisAlignment: align,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: bgColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(message.content, style: const TextStyle(fontSize: 16)),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(top: 4),
//             child: Text(
//               message.time,
//               style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageInput() {
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             spreadRadius: 1,
//             blurRadius: 3,
//             offset: const Offset(0, -1),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               decoration: const InputDecoration(
//                 hintText: '输入消息...',
//                 border: InputBorder.none,
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//               ),
//               maxLines: null,
//               textInputAction: TextInputAction.send,
//               onSubmitted: (_) => _sendMessage(),
//             ),
//           ),
//           IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
//         ],
//       ),
//     );
//   }

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserInfo();
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels ==
//           _scrollController.position.minScrollExtent) {
//         _loadMoreMessages();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     _chatService.disconnect();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('与 ${_chatWithCharacter["nickname"]} 的私聊'),
//         centerTitle: true,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child:
//                 _isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : _messages.isEmpty
//                     ? const Center(
//                       child: Text(
//                         '暂无聊天记录',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                     )
//                     : ListView.builder(
//                       controller: _scrollController,
//                       itemCount: _messages.length + (_hasMoreMessages ? 1 : 0),
//                       padding: const EdgeInsets.all(8.0),
//                       itemBuilder: (context, index) {
//                         if (index == _messages.length) {
//                           return _isLoadingMore
//                               ? const Center(
//                                 child: Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: CircularProgressIndicator(),
//                                 ),
//                               )
//                               : const SizedBox.shrink();
//                         }
//                         return _buildMessageItem(_messages[index]);
//                       },
//                     ),
//           ),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }
// }
