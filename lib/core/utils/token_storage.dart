import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  const TokenStorage._();

  static const String _key = 'agrilink_token';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Memory backup for Web/Chrome environments to ensure reliability
  static String? _webToken;

  /// Saves the JWT token to secure storage.
  static Future<void> saveToken(String token) async {
    if (kIsWeb) {
      _webToken = token;
      try {
        await _storage.write(key: _key, value: token);
      } catch (_) {
        // Fallback silently if web secure storage API is not supported in the current context
      }
    } else {
      await _storage.write(key: _key, value: token);
    }
  }

  /// Retrieves the stored JWT token.
  static Future<String?> getToken() async {
    if (kIsWeb) {
      if (_webToken != null) return _webToken;
      try {
        return await _storage.read(key: _key);
      } catch (_) {
        return null;
      }
    }
    return await _storage.read(key: _key);
  }

  /// Deletes the stored JWT token.
  static Future<void> deleteToken() async {
    if (kIsWeb) {
      _webToken = null;
    }
    try {
      await _storage.delete(key: _key);
    } catch (_) {
      // Fallback silently
    }
  }
}
