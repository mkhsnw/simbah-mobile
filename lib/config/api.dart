import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ApiConfig {
  static const String baseUrl = 'https://your-api-base-url.com/api';
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late final Dio _dio;

  Dio get dio => _dio;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
      sendTimeout: Duration(milliseconds: ApiConfig.sendTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _addInterceptors();
  }

  void _addInterceptors() {
    // Logging interceptor (hanya untuk development)
    if (const bool.fromEnvironment('dart.vm.product') == false) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: true,
      ));
    }

    // Auth interceptor
    _dio.interceptors.add(AuthInterceptor());

    // Error handling interceptor
    _dio.interceptors.add(ErrorInterceptor());
  }
}

// Interceptor untuk menambahkan token secara otomatis
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // TODO: Ambil token dari secure storage
    const token = 'your-auth-token'; // Ganti dengan cara mengambil token yang sebenarnya
    
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    super.onRequest(options, handler);
  }
}

// Interceptor untuk error handling
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.response?.statusCode) {
      case 401:
        // Token expired atau invalid - redirect ke login
        _handleUnauthorized();
        break;
      case 403:
        // Forbidden
        _handleForbidden();
        break;
      case 404:
        // Not found
        _handleNotFound();
        break;
      case 500:
        // Server error
        _handleServerError();
        break;
      default:
        break;
    }
    
    super.onError(err, handler);
  }

  void _handleUnauthorized() {
    // TODO: Clear token dan redirect ke login
    print('Unauthorized - redirecting to login');
  }

  void _handleForbidden() {
    // TODO: Show forbidden message
    print('Access forbidden');
  }

  void _handleNotFound() {
    // TODO: Show not found message
    print('Resource not found');
  }

  void _handleServerError() {
    // TODO: Show server error message
    print('Server error occurred');
  }
}