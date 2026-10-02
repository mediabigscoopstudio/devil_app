import 'package:flutter/material.dart';
import '../repositories/discovery_repository.dart';
import '../../profile/models/profile.dart';

enum DiscoveryStatus { initial, loading, loaded, error }

class DiscoveryProvider extends ChangeNotifier {
  final DiscoveryRepository _repository;
  
  DiscoveryStatus _status = DiscoveryStatus.initial;
  String? _errorMessage;
  List<Profile> _feed = [];

  DiscoveryStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<Profile> get feed => _feed;

  DiscoveryProvider(this._repository);

  Future<void> fetchFeed() async {
    _status = DiscoveryStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _feed = await _repository.getFeed();
      _status = DiscoveryStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = DiscoveryStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> swipeRight(Profile profile) async {
    _feed.removeWhere((p) => p.id == profile.id);
    notifyListeners();
    
    try {
      final isMatch = await _repository.swipeRight(profile.id!);
      if (isMatch) {
        // Optionally trigger a match dialog/notification
        debugPrint('Its a match with ${profile.name}');
      }
    } catch (e) {
      _errorMessage = e.toString();
      // Optionally put them back in the feed if it failed
      _feed.insert(0, profile);
      notifyListeners();
    }
  }

  Future<void> swipeLeft(Profile profile) async {
    _feed.removeWhere((p) => p.id == profile.id);
    notifyListeners();

    try {
      await _repository.swipeLeft(profile.id!);
    } catch (e) {
      _errorMessage = e.toString();
      _feed.insert(0, profile);
      notifyListeners();
    }
  }
}
