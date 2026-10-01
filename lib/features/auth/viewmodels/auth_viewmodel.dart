import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthViewModel extends ChangeNotifier {
  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyAuthUser = 'auth_username';

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  String? _currentUser;
  String? get currentUser => _currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthViewModel({bool initialAuthenticated = false}) {
    _isAuthenticated = initialAuthenticated;
  }

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isAuthenticated = prefs.getBool(_keyIsLoggedIn) ?? false;
      if (_isAuthenticated) {
        _currentUser = prefs.getString(_keyAuthUser) ?? 'demo';
      }
      notifyListeners();
    } catch (_) {
      // In case of any platform channel issue in tests, retain default
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Small delay to simulate credential verification
    await Future.delayed(const Duration(milliseconds: 300));

    final trimmedUser = username.trim().toLowerCase();
    final trimmedPass = password.trim();

    if (trimmedUser == 'demo' && trimmedPass == 'demo') {
      _isAuthenticated = true;
      _currentUser = 'demo';
      _errorMessage = null;
      _isLoading = false;

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyAuthUser, 'demo');
      } catch (_) {}

      notifyListeners();
      return true;
    } else {
      _isAuthenticated = false;
      _errorMessage = 'Invalid credentials. Please check your username and password.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _currentUser = null;
    _errorMessage = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyAuthUser);
    } catch (_) {}

    notifyListeners();
  }
}
