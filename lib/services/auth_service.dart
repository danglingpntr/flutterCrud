import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AuthService {
  Future<ParseUser?> getCachedUser() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    return user;
  }

  Future<ParseUser> login({
    required String email,
    required String password,
  }) async {
    final user = ParseUser(email.trim(), password, email.trim());
    final response = await user.login();
    _validate(response);
    return response.result as ParseUser;
  }

  Future<ParseUser> register({
    required String email,
    required String password,
  }) async {
    final user = ParseUser.createUser(email.trim(), password, email.trim());
    final response = await user.signUp();
    _validate(response);
    return response.result as ParseUser;
  }

  Future<void> logout() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user != null) {
      final response = await user.logout();
      _validate(response);
    }
  }

  void _validate(ParseResponse response) {
    if (!response.success) {
      throw StateError(response.error?.message ?? 'Unknown Parse error');
    }
  }
}

