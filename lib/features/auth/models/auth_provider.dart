import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';
import '../models/auth_models.dart';

enum AuthStatus { initial, unauthenticated, loading, authenticated, onboardingRequired, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  AuthUser? _user;
  AccountState? _accountState;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  AuthUser? get user => _user;
  AccountState? get accountState => _accountState;

  AuthProvider(this._authRepository) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final hasToken = await _authRepository.hasToken();
      if (!hasToken) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      await _fetchMeAndDetermineState();
    } catch (e) {
      // If fetching /me fails (e.g. invalid token that failed to refresh), logout.
      await logout();
    }
  }

  Future<void> _fetchMeAndDetermineState() async {
    final response = await _authRepository.getMe();
    if (response != null) {
      _user = response.user;
      _accountState = response.account;

      if (_accountState!.requiresOnboarding || !_accountState!.profileCompleted) {
        _status = AuthStatus.onboardingRequired;
      } else {
        _status = AuthStatus.authenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> requestOtp(String phoneNumber) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authRepository.requestOtp(phoneNumber);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authRepository.verifyOtp(phoneNumber, otp);
      if (success) {
        await _fetchMeAndDetermineState();
      } else {
        _errorMessage = 'Invalid OTP';
        _status = AuthStatus.error;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authRepository.signInWithGoogle();
      if (success) {
        await _fetchMeAndDetermineState();
      } else {
        // User likely canceled
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();
    
    await _authRepository.logout();
    
    _user = null;
    _accountState = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
