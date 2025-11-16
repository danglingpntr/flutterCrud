import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

import '../../../core/validators.dart';
import '../../../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required this.authService,
    ParseUser? initialUser,
  }) : _currentUser = initialUser;

  final AuthService authService;

  bool _isLoginMode = true;
  bool _isLoading = false;
  String? _errorMessage;
  ParseUser? _currentUser;

  bool get isLoginMode => _isLoginMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  ParseUser? get user => _currentUser;

  void toggleMode() {
    _isLoginMode = !_isLoginMode;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> submit({
    required String email,
    required String password,
    String? confirmPassword,
  }) async {
    final emailError = Validators.email(email);
    final passwordError = Validators.password(password);
    if (emailError != null || passwordError != null) {
      throw StateError(emailError ?? passwordError!);
    }

    if (!_isLoginMode) {
      if (confirmPassword == null || confirmPassword != password) {
        throw StateError('Passwords do not match');
      }
    }

    _setLoading(true);
    try {
      ParseUser user;
      if (_isLoginMode) {
        user = await authService.login(email: email, password: password);
      } else {
        user = await authService.register(email: email, password: password);
      }
      _currentUser = user;
      _errorMessage = null;
    } on Object catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await authService.logout();
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

