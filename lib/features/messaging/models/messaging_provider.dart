import 'package:flutter/material.dart';
import '../repositories/messaging_repository.dart';
import '../models/messaging_models.dart';

enum MessagingStatus { initial, loading, loaded, error }

class MessagingProvider extends ChangeNotifier {
  final MessagingRepository _repository;

  MessagingStatus _status = MessagingStatus.initial;
  String? _errorMessage;
  
  List<Conversation> _conversations = [];
  List<Message> _currentMessages = [];

  MessagingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<Conversation> get conversations => _conversations;
  List<Message> get currentMessages => _currentMessages;

  MessagingProvider(this._repository);

  Future<void> fetchConversations() async {
    _status = MessagingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _conversations = await _repository.getConversations();
      _status = MessagingStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = MessagingStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchMessages(int conversationId) async {
    _status = MessagingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentMessages = await _repository.getMessages(conversationId);
      _status = MessagingStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = MessagingStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> sendMessage(int conversationId, String content) async {
    try {
      final newMessage = await _repository.sendMessage(conversationId, content);
      _currentMessages.insert(0, newMessage); // Assuming list shows latest at bottom, we'll configure ListView
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
