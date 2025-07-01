class ApiConfig {
  static const String baseUrl = 'http://103.193.179.6:3001/v1';
  static const Duration timeout = Duration(seconds: 30);
  static const String registerEndpoint = '${baseUrl}/auth/register';
}
