import 'dart:io';
import 'package:flutter/material.dart';
import '../repositories/profile_repository.dart';
import '../models/profile.dart';

enum ProfileStatus { initial, loading, loaded, error }

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  
  ProfileStatus _status = ProfileStatus.initial;
  String? _errorMessage;
  Profile? _profile;

  ProfileStatus get status => _status;
  String? get errorMessage => _errorMessage;
  Profile? get profile => _profile;

  ProfileProvider(this._profileRepository);

  Future<void> fetchProfile() async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.getMyProfile();
      _status = ProfileStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ProfileStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Profile updatedProfile) async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.updateProfile(updatedProfile);
      _status = ProfileStatus.loaded;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ProfileStatus.error;
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> uploadPhoto(File imageFile) async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.uploadProfilePhoto(imageFile);
      _status = ProfileStatus.loaded;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ProfileStatus.error;
      return false;
    } finally {
      notifyListeners();
    }
  }
}
