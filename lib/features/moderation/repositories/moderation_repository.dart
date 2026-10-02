import '../../../core/network/api_client.dart';

class ModerationRepository {
  final ApiClient _apiClient;

  ModerationRepository(this._apiClient);

  Future<bool> blockUser(int userId) async {
    await _apiClient.post(
      'moderation/block/',
      body: {'blocked_user_id': userId},
    );
    return true; // Assume success if no exception
  }

  Future<bool> reportUser(int userId, String reason) async {
    await _apiClient.post(
      'moderation/report/',
      body: {
        'reported_user_id': userId,
        'reason': reason,
      },
    );
    return true; // Assume success if no exception
  }
}
