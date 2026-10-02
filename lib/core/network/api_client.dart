import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../config/env.dart';
import '../storage/secure_storage.dart';
import '../errors/api_exceptions.dart';

class ApiClient {
  final http.Client _client = http.Client();
  final SecureStorage _secureStorage = SecureStorage();
  final Logger _logger = Logger();

  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requireAuth) {
      final token = await _secureStorage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  void _logRequest(String method, String url, {Map<String, dynamic>? body}) {
    _logger.d('API REQUEST: [$method] $url\nBody: $body');
  }

  void _logResponse(http.Response response) {
    _logger.d('API RESPONSE: [${response.statusCode}] ${response.request?.url}\nBody: ${response.body}');
  }

  dynamic _handleResponse(http.Response response) {
    _logResponse(response);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body; // Return as string if not JSON
      }
    } else if (response.statusCode == 401) {
      throw UnauthorizedException('Unauthorized access', statusCode: 401, responseData: response.body);
    } else {
      dynamic errorData;
      try {
        errorData = jsonDecode(response.body);
      } catch (_) {
        errorData = response.body;
      }
      throw ApiException('API Error', statusCode: response.statusCode, responseData: errorData);
    }
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final uri = Uri.parse('${Env.baseUrl}auth/token/refresh/');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccess = data['access'];
        if (newAccess != null) {
          await _secureStorage.saveToken(newAccess);
          
          // Depending on API, a new refresh token might also be provided
          if (data['refresh'] != null) {
            await _secureStorage.saveRefreshToken(data['refresh']);
          }
          return true;
        }
      }
    } catch (_) {
      // Refresh failed for network or other reasons
    }
    
    // Clear tokens if refresh failed
    await _secureStorage.clearAll();
    return false;
  }

  Future<dynamic> _requestWithRetry(
    Future<http.Response> Function() requestFunc,
    {required bool requireAuth}
  ) async {
    try {
      final response = await requestFunc();
      return _handleResponse(response);
    } on UnauthorizedException {
      if (requireAuth) {
        final refreshSuccess = await _refreshToken();
        if (refreshSuccess) {
          // Retry original request
          final retryResponse = await requestFunc();
          return _handleResponse(retryResponse);
        }
      }
      rethrow;
    }
  }

  Future<dynamic> get(String endpoint, {bool requireAuth = true, Map<String, String>? queryParams}) async {
    try {
      var uri = Uri.parse('${Env.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }
      
      return await _requestWithRetry(() async {
        final headers = await _getHeaders(requireAuth: requireAuth);
        _logRequest('GET', uri.toString());
        return await _client.get(uri, headers: headers).timeout(const Duration(seconds: 15));
      }, requireAuth: requireAuth);

    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body, bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('${Env.baseUrl}$endpoint');
      
      return await _requestWithRetry(() async {
        final headers = await _getHeaders(requireAuth: requireAuth);
        _logRequest('POST', uri.toString(), body: body);
        return await _client.post(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(const Duration(seconds: 15));
      }, requireAuth: requireAuth);

    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body, bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('${Env.baseUrl}$endpoint');
      
      return await _requestWithRetry(() async {
        final headers = await _getHeaders(requireAuth: requireAuth);
        _logRequest('PUT', uri.toString(), body: body);
        return await _client.put(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(const Duration(seconds: 15));
      }, requireAuth: requireAuth);

    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body, bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('${Env.baseUrl}$endpoint');
      
      return await _requestWithRetry(() async {
        final headers = await _getHeaders(requireAuth: requireAuth);
        _logRequest('PATCH', uri.toString(), body: body);
        return await _client.patch(
          uri,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(const Duration(seconds: 15));
      }, requireAuth: requireAuth);

    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }

  Future<dynamic> delete(String endpoint, {bool requireAuth = true}) async {
    try {
      final uri = Uri.parse('${Env.baseUrl}$endpoint');
      
      return await _requestWithRetry(() async {
        final headers = await _getHeaders(requireAuth: requireAuth);
        _logRequest('DELETE', uri.toString());
        return await _client.delete(uri, headers: headers).timeout(const Duration(seconds: 15));
      }, requireAuth: requireAuth);

    } catch (e) {
      if (e is ApiException) rethrow;
      throw NetworkException(e.toString());
    }
  }
}
