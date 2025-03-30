class ChatMessage {
  static const String TYPE_CHAT = "CHAT";
  static const String TYPE_PRIVATE = "PRIVATE";
  static const String TYPE_JOIN = "JOIN";
  static const String TYPE_LEAVE = "LEAVE";
  static const String TYPE_USERS = "USERS";

  String type;
  String content;
  String sender;
  String? receiver;
  String? role;
  String time;
  String id;

  ChatMessage({
    required this.type,
    required this.content,
    required this.sender,
    this.receiver,
    this.role,
    this.time = "",
    this.id = "",
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      type: json['type'] ?? TYPE_CHAT,
      content: json['content'] ?? "",
      sender: json['sender'] ?? "",
      receiver: json['receiver'],
      role: json['role'],
      time: json['time'] ?? "",
      id: json['id'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
      'sender': sender,
      if (receiver != null) 'receiver': receiver,
      if (role != null) 'role': role,
      'time': time,
      'id': id,
    };
  }
}
