import 'package:flutter/foundation.dart';
import 'package:bootiehunter/services/auth_service.dart';
import 'package:bootiehunter/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService authService;

  bool _isAuthenticated = false;
  bool _isLoading = true;
  User? _currentUser;
  bool? _hasCompletedOnboarding;

  AuthProvider({required this.authService});

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  bool? get hasCompletedOnboarding => _hasCompletedOnboarding;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    final userData = await authService.getCurrentUser();
    if (userData != null) {
      _currentUser = User.fromJson(userData);
      _isAuthenticated = true;
      await _loadOnboardingStatus();
    } else {
      _currentUser = null;
      _isAuthenticated = false;
      _hasCompletedOnboarding = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadOnboardingStatus() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    _hasCompletedOnboarding = prefs.getBool(
          'onboarding_completed_${_currentUser!.id}',
        ) ??
        false;
  }

  Future<void> markOnboardingComplete() async {
    if (_currentUser == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      'onboarding_completed_${_currentUser!.id}',
      true,
    );
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('AuthProvider: Starting login for $email');
      final result = await authService.login(email: email, password: password);
      debugPrint('AuthProvider: Login successful, setting user');
      _currentUser = User.fromJson(result['user']);
      _isAuthenticated = true;
      await _loadOnboardingStatus();
      debugPrint('AuthProvider: User set, isAuthenticated: $_isAuthenticated');
    } catch (e) {
      debugPrint('AuthProvider: Login error: $e');
      _isAuthenticated = false;
      _currentUser = null;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('AuthProvider: Login complete, isAuthenticated: $_isAuthenticated');
    }
  }

  Future<void> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await authService.register(
        email: email,
        password: password,
        name: name,
      );
      _currentUser = User.fromJson(result['user']);
      _isAuthenticated = true;
      await _loadOnboardingStatus();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authService.logout();
    _currentUser = null;
    _isAuthenticated = false;
    _hasCompletedOnboarding = null;
    notifyListeners();
  }
}
