import 'package:flutter/material.dart';
import '../repositories/notifications_repository.dart';
import '../models/notification_model.dart';

enum NotificationsStatus { initial, loading, loaded, error }

class NotificationsProvider extends ChangeNotifier {
  final NotificationsRepository _repository;

  NotificationsStatus _status = NotificationsStatus.initial;
  String? _errorMessage;
  List<NotificationModel> _notifications = [];

  NotificationsStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<NotificationModel> get notifications => _notifications;

  NotificationsProvider(this._repository);

  Future<void> fetchNotifications() async {
    _status = NotificationsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications();
      _status = NotificationsStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = NotificationsStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final old = _notifications[index];
        _notifications[index] = NotificationModel(
          id: old.id,
          title: old.title,
          body: old.body,
          isRead: true,
          timestamp: old.timestamp,
        );
        notifyListeners();
      }
    } catch (e) {
      // Handle error if needed
    }
  }
}
