import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  const TokenStorage._();

  static const String _accessKey  = 'agrilink_token';
  static const String _refreshKey = 'agrilink_refresh_token';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Web memory fallback
  static String? _webAccess;
  static String? _webRefresh;

  // ── Access token ─────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    if (kIsWeb) {
      _webAccess = token;
      try { await _storage.write(key: _accessKey, value: token); } catch (_) {}
    } else {
      await _storage.write(key: _accessKey, value: token);
    }
  }

  static Future<String?> getToken() async {
    if (kIsWeb) {
      if (_webAccess != null) return _webAccess;
      try { return await _storage.read(key: _accessKey); } catch (_) { return null; }
    }
    return await _storage.read(key: _accessKey);
  }

  static Future<void> deleteToken() async {
    _webAccess = null;
    try { await _storage.delete(key: _accessKey); } catch (_) {}
  }

  // ── Refresh token ─────────────────────────────────────────────────────────

  static Future<void> saveRefreshToken(String token) async {
    if (kIsWeb) {
      _webRefresh = token;
      try { await _storage.write(key: _refreshKey, value: token); } catch (_) {}
    } else {
      await _storage.write(key: _refreshKey, value: token);
    }
  }

  static Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      if (_webRefresh != null) return _webRefresh;
      try { return await _storage.read(key: _refreshKey); } catch (_) { return null; }
    }
    return await _storage.read(key: _refreshKey);
  }

  static Future<void> deleteRefreshToken() async {
    _webRefresh = null;
    try { await _storage.delete(key: _refreshKey); } catch (_) {}
  }

  // ── Clear all ─────────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    await deleteToken();
    await deleteRefreshToken();
  }
}
