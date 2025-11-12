import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'config_provider.g.dart';

class Config {
  // Singlton
  Config._internal();
  static final Config _instance = Config._internal();
  factory Config() => _instance;

  // Add all Config params ...
  final String _apiBaseUrl =
      dotenv.env['API_BASE_URL'] ?? 'https://default.example.com';

  String get apiBaseUrl => _apiBaseUrl;
}

@riverpod
Config config(Ref ref) {
  return Config();
}
