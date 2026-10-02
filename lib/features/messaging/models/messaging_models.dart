import '../../profile/models/profile.dart';

class Conversation {
  final int id;
  final Profile targetUser;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.targetUser,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      targetUser: Profile.fromJson(json['target_user']),
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'],
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

class Message {
  final int id;
  final int senderId;
  final String content;
  final String timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      content: json['content'],
      timestamp: json['timestamp'],
    );
  }
}
