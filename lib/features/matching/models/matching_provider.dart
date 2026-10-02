import 'package:flutter/material.dart';
import '../repositories/matching_repository.dart';
import '../../profile/models/profile.dart';

enum MatchingStatus { initial, loading, loaded, error }

class MatchingProvider extends ChangeNotifier {
  final MatchingRepository _repository;

  MatchingStatus _status = MatchingStatus.initial;
  String? _errorMessage;
  List<Profile> _matches = [];

  MatchingStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<Profile> get matches => _matches;

  MatchingProvider(this._repository);

  Future<void> fetchMatches() async {
    _status = MatchingStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _matches = await _repository.getMatches();
      _status = MatchingStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = MatchingStatus.error;
    } finally {
      notifyListeners();
    }
  }
}
