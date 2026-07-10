import 'package:flutter/material.dart';
import '../../core/utils/token_storage.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/api_service.dart';
import 'notification_service.dart';

class AuthProvider extends ChangeNotifier {
  late final ApiService _apiService;
  late final AuthRepository _authRepository;
  late final NotificationService _notificationService;

  UserModel? _currentUser;
  bool _isLoading = false;

  // Giữ email tạm để truyền sang verify_email_screen
  String? _pendingEmail;

  AuthProvider() {
    _apiService = ApiService();
    _authRepository = AuthRepository(_apiService);
    _notificationService = NotificationService(_apiService);
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get pendingEmail => _pendingEmail;
  ApiService get apiService => _apiService;
  NotificationService get notificationService => _notificationService;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  // ── checkLogin ────────────────────────────────────────────────────────────
  Future<bool> checkLogin() async {
    final token = await TokenStorage.getToken();
    if (token == null) return false;
    try {
      final user = await _authRepository.getMe();
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      await TokenStorage.clearAll();
      _currentUser = null;
      notifyListeners();
      return false;
    }
  }

  // ── register ──────────────────────────────────────────────────────────────
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);
    try {
      await _authRepository.register(
        email: email,
        password: password,
        fullName: fullName,
      );
      _pendingEmail = email;
      _setLoading(false);
      onSuccess();
    } catch (e) {
      _setLoading(false);
      onError(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  // ── verifyEmail ───────────────────────────────────────────────────────────
  Future<void> verifyEmail({
    required String email,
    required String code,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);
    try {
      await _authRepository.verifyEmail(email: email, code: code);
      await TokenStorage.savePendingRoleEmail(email);
      _setLoading(false);
      onSuccess();
    } catch (e) {
      _setLoading(false);
      onError(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  // ── resendOtp ─────────────────────────────────────────────────────────────
  Future<void> resendOtp({
    required String email,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);
    try {
      await _authRepository.resendOtp(email);
      _setLoading(false);
      onSuccess();
    } catch (e) {
      _setLoading(false);
      onError(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  // ── login ─────────────────────────────────────────────────────────────────
  Future<void> login({
    required String email,
    required String password,
    required Function(bool isNewUser) onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);
    try {
      final user = await _authRepository.login(
        email: email,
        password: password,
      );
      _currentUser = user;
      _setLoading(false);
      final shouldChooseRole = await TokenStorage.isPendingRoleEmail(
        user.email,
      );
      onSuccess(shouldChooseRole);
    } catch (e) {
      _setLoading(false);
      onError(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  // ── updateRole ────────────────────────────────────────────────────────────
  Future<void> updateRole(
    String role, {
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);
    try {
      final updated = await _authRepository.updateRole(role);
      _currentUser = updated;
      await TokenStorage.clearPendingRoleEmail();
      _setLoading(false);
      onSuccess();
    } catch (e) {
      _setLoading(false);
      onError(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  // ── Profile ───────────────────────────────────────────────────────────────
  /// Updates the user's editable profile fields on the AgriLink Express backend.
  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
    String? address,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);

    if (_currentUser?.id == "mock_user_id") {
      _currentUser = _currentUser?.copyWith(
        fullName: fullName ?? _currentUser?.fullName,
        avatarUrl: avatarUrl ?? _currentUser?.avatarUrl,
        address: address ?? _currentUser?.address,
      );
      _setLoading(false);
      onSuccess();
      return;
    }

    try {
      final updatedUser = await _authRepository.updateProfile(
        fullName: fullName,
        avatarUrl: avatarUrl,
        address: address,
      );
      _currentUser = updatedUser;
      _setLoading(false);
      onSuccess();
    } catch (e) {
      _setLoading(false);
      onError(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  /// Signs out of the standalone backend session and clears local JWT tokens.
  Future<void> logout() async {
    _setLoading(true);
    try {
      _notificationService.disposeSocket();
      await _authRepository.logout();
    } catch (_) {
      await TokenStorage.clearAll();
    } finally {
      _currentUser = null;
      _pendingEmail = null;
      _setLoading(false);
    }
  }
}
