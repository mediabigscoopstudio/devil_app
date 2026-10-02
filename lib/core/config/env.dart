class Env {
  // Toggle this to true for production
  static const bool isProduction = true;

  static const String devBaseUrl = 'http://127.0.0.1:8000/api/v1/';
  static const String prodBaseUrl = 'https://devil.bigscooptesting2.online/api/v1/';

  static String get baseUrl => isProduction ? prodBaseUrl : devBaseUrl;
}
