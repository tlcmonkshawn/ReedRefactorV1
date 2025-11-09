import 'package:shared_preferences/shared_preferences.dart';
import 'package:bootiehunter/services/api_service.dart';

class AuthService {
  final ApiService apiService;

  AuthService({required this.apiService});

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await apiService.post(
      '/auth/register',
      data: {
        'user': {
          'email': email,
          'password': password,
          'password_confirmation': password,
          'name': name,
        }
      },
    );

    if (response.statusCode == 201) {
      final token = response.data['token'];
      final user = response.data['user'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      apiService.setAuthToken(token);

      return {'success': true, 'user': user, 'token': token};
    }

    throw Exception(response.data['error']?['message'] ?? 'Registration failed');
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiService.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      print('Login response status: ${response.statusCode}');
      print('Login response data: ${response.data}');

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final user = response.data['user'];

        if (token == null) {
          throw Exception('No token received from server');
        }

        if (user == null) {
          throw Exception('No user data received from server');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        apiService.setAuthToken(token);

        print('Token saved, user: ${user['email']}');
        return {'success': true, 'user': user, 'token': token};
      }

      final errorMessage = response.data['error']?['message'] ?? 'Login failed';
      print('Login failed: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('Login exception: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    apiService.clearAuthToken();
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) return null;

      apiService.setAuthToken(token);
      final response = await apiService.get('/auth/me');

      if (response.statusCode == 200) {
        return response.data['user'];
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
