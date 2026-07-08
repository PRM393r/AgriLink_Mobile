import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  const TokenStorage._();

  static const String _accessKey  = 'agrilink_token';
  static const String _refreshKey = 'agrilink_refresh_token';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Memory fallback for all platforms
  static String? _memoryAccess;
  static String? _memoryRefresh;

  // ── Access token ─────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    _memoryAccess = token;
    try { await _storage.write(key: _accessKey, value: token); } catch (_) {}
  }

  static Future<String?> getToken() async {
    if (_memoryAccess != null) return _memoryAccess;
    try { return await _storage.read(key: _accessKey); } catch (_) { return null; }
  }

  static Future<void> deleteToken() async {
    _memoryAccess = null;
    try { await _storage.delete(key: _accessKey); } catch (_) {}
  }

  // ── Refresh token ─────────────────────────────────────────────────────────

  static Future<void> saveRefreshToken(String token) async {
    _memoryRefresh = token;
    try { await _storage.write(key: _refreshKey, value: token); } catch (_) {}
  }

  static Future<String?> getRefreshToken() async {
    if (_memoryRefresh != null) return _memoryRefresh;
    try { return await _storage.read(key: _refreshKey); } catch (_) { return null; }
  }

  static Future<void> deleteRefreshToken() async {
    _memoryRefresh = null;
    try { await _storage.delete(key: _refreshKey); } catch (_) {}
  }

  // ── Clear all ─────────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    await deleteToken();
    await deleteRefreshToken();
  }
}
