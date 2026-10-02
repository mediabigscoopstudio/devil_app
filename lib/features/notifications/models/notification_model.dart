class NotificationModel {
  final int id;
  final String title;
  final String body;
  final bool isRead;
  final String timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.timestamp,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      isRead: json['is_read'] ?? false,
      timestamp: json['created_at'] ?? '',
    );
  }
}
