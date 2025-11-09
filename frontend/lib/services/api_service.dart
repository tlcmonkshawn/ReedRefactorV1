// API Service
//
// Base HTTP client for all API requests to the Rails backend.
// Uses Dio for HTTP requests with automatic authentication and error handling.
//
// Features:
// - Automatic JWT token injection via AuthInterceptor
// - Error handling via ErrorInterceptor (handles 401 unauthorized)
// - Standardized timeout configuration
//
// @see docs/API.md for API endpoint documentation
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  final Dio _dio;
  final String baseUrl;

  // Initialize API service with base URL from ApiConfig
  // Sets up Dio with default headers and interceptors
  ApiService({String? baseUrl})
      : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? ApiConfig.baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        )) {
    // Add authentication interceptor (injects JWT token)
    _dio.interceptors.add(AuthInterceptor());
    // Add error handling interceptor (handles 401, clears token)
    _dio.interceptors.add(ErrorInterceptor());
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.delete(path, queryParameters: queryParameters);
    } catch (e) {
      rethrow;
    }
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}

// AuthInterceptor
//
// Automatically injects JWT token from SharedPreferences into all API requests.
// Token is added to Authorization header as "Bearer <token>"
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// ErrorInterceptor
//
// Handles API errors, particularly 401 Unauthorized responses.
// When a 401 is received, clears the stored auth token (user must re-login).
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle unauthorized - clear token and redirect to login
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove('auth_token');
      });
    }
    handler.next(err);
  }
}

