import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleInitialized = false;

  AuthRepository(this._apiClient, this._secureStorage);

  Future<void> _ensureGoogleInitialized() async {
    if (!_isGoogleInitialized) {
      await _googleSignIn.initialize();
      _isGoogleInitialized = true;
    }
  }

  Future<bool> requestOtp(String phoneNumber) async {
    try {
      await _apiClient.post(
        'auth/request-otp/',
        body: {'phone_number': phoneNumber},
        requireAuth: false,
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _apiClient.post(
        'auth/verify-otp/',
        body: {'phone_number': phoneNumber, 'otp': otp},
        requireAuth: false,
      );
      
      if (response != null && response is Map<String, dynamic>) {
        final tokens = response['tokens'];
        if (tokens != null) {
          final access = tokens['access'];
          final refresh = tokens['refresh'];
          
          if (access != null) {
            await _secureStorage.saveToken(access);
          }
          if (refresh != null) {
            await _secureStorage.saveRefreshToken(refresh);
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final GoogleSignInAccount? account = await _googleSignIn.authenticate();
      if (account == null) {
        // User canceled the sign-in flow
        return false;
      }
      
      final GoogleSignInAuthentication auth = account.authentication;
      final String? idToken = auth.idToken;
      
      if (idToken == null) {
        throw Exception('Google Sign-In failed to return an ID token');
      }

      final response = await _apiClient.post(
        'auth/google/',
        body: {'id_token': idToken},
        requireAuth: false,
      );

      if (response != null && response is Map<String, dynamic>) {
        final tokens = response['tokens'];
        if (tokens != null) {
          final access = tokens['access'];
          final refresh = tokens['refresh'];
          
          if (access != null) {
            await _secureStorage.saveToken(access);
          }
          if (refresh != null) {
            await _secureStorage.saveRefreshToken(refresh);
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthMeResponse?> getMe() async {
    try {
      final response = await _apiClient.get('auth/me/');
      if (response != null && response is Map<String, dynamic>) {
        return AuthMeResponse.fromJson(response);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('auth/logout/');
    } catch (e) {
      // Proceed to clear tokens even if backend logout fails
    } finally {
      try {
        await _ensureGoogleInitialized();
        await _googleSignIn.signOut();
      } catch (_) {}
      await _secureStorage.clearAll();
    }
  }

  Future<bool> hasToken() async {
    final token = await _secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
