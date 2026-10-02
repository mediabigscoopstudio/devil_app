import '../../../core/network/api_client.dart';
import '../../profile/models/profile.dart';

class DiscoveryRepository {
  final ApiClient _apiClient;

  DiscoveryRepository(this._apiClient);

  Future<List<Profile>> getFeed() async {
    final response = await _apiClient.get('discovery/feed/');
    // Assuming response is {"results": [{...}, {...}]} or a direct list
    List<dynamic> data;
    if (response is Map && response.containsKey('results')) {
      data = response['results'];
    } else if (response is List) {
      data = response;
    } else {
      data = [];
    }
    return data.map((e) => Profile.fromJson(e)).toList();
  }

  Future<bool> swipeRight(int profileId) async {
    // Return true if it's a match
    final response = await _apiClient.post('discovery/swipe/', body: {
      'target_user_id': profileId,
      'action': 'like'
    });
    return response['is_match'] == true;
  }

  Future<void> swipeLeft(int profileId) async {
    await _apiClient.post('discovery/swipe/', body: {
      'target_user_id': profileId,
      'action': 'pass'
    });
  }
}
