import 'package:flutter/foundation.dart';

class AppConfig {
  static const currency = 'TND';
  static const _env = String.fromEnvironment('API_BASE_URL');

  /// Turns a server-relative path such as /api/vehicles/3/photo?v=x into a full URL.
  static String url(String path) => path.startsWith('http') ? path : '$baseUrl$path';

  static String get baseUrl {
    if (_env.isNotEmpty) return _env;
    if (kIsWeb) return 'http://localhost:8080';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }
}
