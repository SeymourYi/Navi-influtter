import '../screen/role_selection_screen.dart';
import 'chat_message.dart';

class RecentChat {
  final String userId;
  final String userName;
  final CharacterRole userRole;
  final ChatMessage lastMessage;
  final int unreadCount;
  final DateTime lastActivityTime;

  RecentChat({
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.lastMessage,
    this.unreadCount = 0,
    DateTime? lastActivityTime,
  }) : lastActivityTime = lastActivityTime ?? DateTime.now();

  // 从最后一条消息的时间戳创建活动时间
  DateTime get activityTimeFromMessage {
    if (lastMessage.id.isNotEmpty && lastMessage.id.contains('_')) {
      try {
        // 尝试从消息ID中提取时间戳
        int timestamp = int.parse(lastMessage.id.split('_')[0]);
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } catch (e) {
        print('无法从消息ID解析时间戳: $e');
      }
    }
    return lastActivityTime;
  }

  // 获取显示的时间字符串
  String get displayTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      activityTimeFromMessage.year,
      activityTimeFromMessage.month,
      activityTimeFromMessage.day,
    );

    if (messageDate == today) {
      // 今天的消息只显示时间
      return '${activityTimeFromMessage.hour.toString().padLeft(2, '0')}:${activityTimeFromMessage.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      // 昨天的消息显示"昨天"
      return '昨天';
    } else if (now.difference(activityTimeFromMessage).inDays < 7) {
      // 一周内显示星期几
      List<String> weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      // 注意：DateTime.weekday 是1-7，1代表周一
      return weekdays[activityTimeFromMessage.weekday - 1];
    } else {
      // 更久远的显示年月日
      return '${activityTimeFromMessage.month}/${activityTimeFromMessage.day}';
    }
  }

  // 获取要显示的最后一条消息内容预览
  String get messagePreview {
    if (lastMessage.content.length > 20) {
      return lastMessage.content.substring(0, 20) + '...';
    }
    return lastMessage.content;
  }
}
