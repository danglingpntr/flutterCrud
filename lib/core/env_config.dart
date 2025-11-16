import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get _missingMessage =>
      'Missing Parse credential. Did you copy .env from .env.example?';

  static String get appId => _read('PARSE_APPLICATION_ID');

  static String get clientKey => _read('PARSE_CLIENT_KEY');

  static String get serverUrl => _read('PARSE_SERVER_URL');

  static String get liveQueryUrl => _read('PARSE_LIVE_QUERY_URL');

  static String _read(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Env key $key not set. $_missingMessage');
    }
    return value;
  }

  static bool get isDebugLoggingEnabled => kDebugMode;
}

