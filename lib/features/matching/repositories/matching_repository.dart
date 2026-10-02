import '../../../core/network/api_client.dart';
import '../../profile/models/profile.dart';

class MatchingRepository {
  final ApiClient _apiClient;

  MatchingRepository(this._apiClient);

  Future<List<Profile>> getMatches() async {
    final response = await _apiClient.get('matches/');
    
    List<dynamic> data;
    if (response is Map && response.containsKey('results')) {
      data = response['results'];
    } else if (response is List) {
      data = response;
    } else {
      data = [];
    }
    
    // In many matching endpoints, the response might contain match metadata
    // alongside the target user's profile. Assuming for MVP it returns a list of profiles
    // or a list of objects containing a 'matched_user' profile.
    return data.map((e) {
      if (e is Map && e.containsKey('matched_user')) {
        return Profile.fromJson(e['matched_user']);
      }
      return Profile.fromJson(e);
    }).toList();
  }
}
