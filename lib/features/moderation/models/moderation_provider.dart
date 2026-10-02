import 'package:flutter/material.dart';
import '../repositories/moderation_repository.dart';

enum ModerationStatus { initial, loading, success, error }

class ModerationProvider extends ChangeNotifier {
  final ModerationRepository _repository;

  ModerationStatus _status = ModerationStatus.initial;
  String? _errorMessage;

  ModerationStatus get status => _status;
  String? get errorMessage => _errorMessage;

  ModerationProvider(this._repository);

  Future<bool> blockUser(int userId) async {
    _status = ModerationStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.blockUser(userId);
      _status = ModerationStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ModerationStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> reportUser(int userId, String reason) async {
    _status = ModerationStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.reportUser(userId, reason);
      _status = ModerationStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ModerationStatus.error;
      notifyListeners();
      return false;
    }
  }
}
