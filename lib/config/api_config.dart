import 'package:flutter/foundation.dart';

class ApiConfig {
  // Optional override: flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
  static const String _override = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_override.isNotEmpty) return _override;
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000'; // Android emulator's address for your PC
    }
    return 'http://localhost:3000';
  }
}