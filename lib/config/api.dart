class ApiConfig {
  static const String baseUrl = 'http://192.168.1.6:3000/api';
  static const Duration timeout = Duration(seconds: 30);
  static const String registerEndpoint = '${baseUrl}/auth/register';
}
