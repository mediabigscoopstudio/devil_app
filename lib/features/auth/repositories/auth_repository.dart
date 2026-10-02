import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AuthRepository(this._apiClient, this._secureStorage);

  Future<bool> requestOtp(String phoneNumber) async {
    try {
      // POST /api/v1/auth/request-otp/
      // Expecting body: {"phone_number": phoneNumber}
      await _apiClient.post(
        'auth/request-otp/',
        body: {'phone_number': phoneNumber},
        requireAuth: false,
      );
      // Assuming response indicates success
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    try {
      // POST /api/v1/auth/verify-otp/
      // Expecting body: {"phone_number": phoneNumber, "otp": otp}
      final response = await _apiClient.post(
        'auth/verify-otp/',
        body: {'phone_number': phoneNumber, 'otp': otp},
        requireAuth: false,
      );
      
      // If successful, extract tokens and save them
      if (response != null && response is Map<String, dynamic>) {
        final access = response['access'];
        final refresh = response['refresh'];
        
        if (access != null) {
          await _secureStorage.saveToken(access);
        }
        if (refresh != null) {
          await _secureStorage.saveRefreshToken(refresh);
        }
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _secureStorage.clearAll();
  }

  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
