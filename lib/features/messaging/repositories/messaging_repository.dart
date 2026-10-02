import '../../../core/network/api_client.dart';
import '../models/messaging_models.dart';

class MessagingRepository {
  final ApiClient _apiClient;

  MessagingRepository(this._apiClient);

  Future<List<Conversation>> getConversations() async {
    final response = await _apiClient.get('conversations/');
    List<dynamic> data;
    if (response is Map && response.containsKey('results')) {
      data = response['results'];
    } else if (response is List) {
      data = response;
    } else {
      data = [];
    }
    return data.map((e) => Conversation.fromJson(e)).toList();
  }

  Future<List<Message>> getMessages(int conversationId) async {
    final response = await _apiClient.get('conversations/$conversationId/messages/');
    List<dynamic> data;
    if (response is Map && response.containsKey('results')) {
      data = response['results'];
    } else if (response is List) {
      data = response;
    } else {
      data = [];
    }
    return data.map((e) => Message.fromJson(e)).toList();
  }

  Future<Message> sendMessage(int conversationId, String content) async {
    final response = await _apiClient.post(
      'conversations/$conversationId/messages/',
      body: {'content': content},
    );
    return Message.fromJson(response);
  }
}
