import '../../../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationsRepository {
  final ApiClient _apiClient;

  NotificationsRepository(this._apiClient);

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.get('notifications/');
    List<dynamic> data;
    if (response is Map && response.containsKey('results')) {
      data = response['results'];
    } else if (response is List) {
      data = response;
    } else {
      data = [];
    }
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markAsRead(int notificationId) async {
    await _apiClient.patch('notifications/$notificationId/read/');
  }
}
