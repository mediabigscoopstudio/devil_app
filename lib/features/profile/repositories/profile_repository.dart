import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/network/api_client.dart';
import '../../../core/config/env.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/profile.dart';

class ProfileRepository {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  ProfileRepository(this._apiClient, this._secureStorage);

  Future<Profile> getMyProfile() async {
    final response = await _apiClient.get('profiles/me/');
    return Profile.fromJson(response);
  }

  Future<Profile> updateProfile(Profile profile) async {
    final response = await _apiClient.patch('profiles/me/', body: profile.toJson());
    return Profile.fromJson(response);
  }

  Future<Profile> uploadProfilePhoto(File imageFile) async {
    final token = await _secureStorage.getToken();
    final uri = Uri.parse('${Env.baseUrl}profiles/me/photo/');
    
    final request = http.MultipartRequest('POST', uri);
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    request.files.add(await http.MultipartFile.fromPath('profile_photo', imageFile.path));
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Profile.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to upload photo: ${response.statusCode}');
    }
  }
}
