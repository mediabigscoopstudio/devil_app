import 'package:flutter/material.dart';
import '../repositories/profile_repository.dart';
import '../../../features/auth/models/auth_provider.dart';

class OnboardingProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final AuthProvider _authProvider;
  
  bool _isLoading = false;
  String? _errorMessage;

  // Local state
  String? displayName;
  String? dateOfBirth;
  String? gender;
  List<String> lookingFor = [];
  List<int> interests = [];
  String? bio;
  bool locationEnabled = false;
  double? latitude;
  double? longitude;
  String? city;
  String? country;
  bool notificationPermission = false;

  OnboardingProvider(this._profileRepository, this._authProvider) {
    _loadInitialProfile();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _loadInitialProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final profile = await _profileRepository.getMyProfile();
      // Populate local state
      displayName = profile.name;
      dateOfBirth = profile.birthDate;
      gender = profile.gender;
      // Assume profile has these or defaults
      bio = profile.bio;
      
    } catch (e) {
      _errorMessage = 'Failed to load profile data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveStep(String stepField) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (stepField == 'review') {
        return await completeProfile();
      }
      if (stepField == 'success' || stepField == 'notifications') {
        return true; 
      }
      
      // Update specific fields via PATCH /profile/me/
      // In a real app we would construct a map based on stepField
      // For MVP, we will just sync what we have
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeProfile() async {
    try {
      // call POST /api/v1/profile/complete/
      // then refresh auth state
      await _authProvider.checkAuthStatus();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
}
