import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  const TokenStorage._();

  static const String _accessKey = 'agrilink_token';
  static const String _refreshKey = 'agrilink_refresh_token';
  static const String _pendingRoleEmailKey = 'agrilink_pending_role_email';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Memory fallback for all platforms
  static String? _memoryAccess;
  static String? _memoryRefresh;
  static String? _memoryPendingRoleEmail;

  // ── Access token ─────────────────────────────────────────────────────────

  static Future<void> saveToken(String token) async {
    _memoryAccess = token;
    try {
      await _storage.write(key: _accessKey, value: token);
    } catch (_) {}
  }

  static Future<String?> getToken() async {
    if (_memoryAccess != null) return _memoryAccess;
    try {
      return await _storage.read(key: _accessKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> deleteToken() async {
    _memoryAccess = null;
    try {
      await _storage.delete(key: _accessKey);
    } catch (_) {}
  }

  // ── Refresh token ─────────────────────────────────────────────────────────

  static Future<void> saveRefreshToken(String token) async {
    _memoryRefresh = token;
    try {
      await _storage.write(key: _refreshKey, value: token);
    } catch (_) {}
  }

  static Future<String?> getRefreshToken() async {
    if (_memoryRefresh != null) return _memoryRefresh;
    try {
      return await _storage.read(key: _refreshKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> deleteRefreshToken() async {
    _memoryRefresh = null;
    try {
      await _storage.delete(key: _refreshKey);
    } catch (_) {}
  }

  // ── Pending role selection ───────────────────────────────────────────────

  static Future<void> savePendingRoleEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return;

    _memoryPendingRoleEmail = normalized;
    try {
      await _storage.write(key: _pendingRoleEmailKey, value: normalized);
    } catch (_) {}
  }

  static Future<bool> isPendingRoleEmail(String email) async {
    final normalized = email.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    if (_memoryPendingRoleEmail != null) {
      return _memoryPendingRoleEmail == normalized;
    }

    try {
      return await _storage.read(key: _pendingRoleEmailKey) == normalized;
    } catch (_) {
      return false;
    }
  }

  static Future<void> clearPendingRoleEmail() async {
    _memoryPendingRoleEmail = null;
    try {
      await _storage.delete(key: _pendingRoleEmailKey);
    } catch (_) {}
  }

  // ── Clear all ─────────────────────────────────────────────────────────────

  static Future<void> clearAll() async {
    await deleteToken();
    await deleteRefreshToken();
  }
}
