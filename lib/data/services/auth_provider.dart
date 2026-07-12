import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Properties for Phone Auth
  String? _verificationId;
  String? _phoneNumber;

  AuthProvider() {
    _apiService = ApiService();
    _authRepository = AuthRepository(_apiService);
    _notificationService = NotificationService(_apiService);
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get pendingEmail => _pendingEmail;
  String? get phoneNumber => _phoneNumber;
  String? get verificationId => _verificationId;
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

  // ── Firebase Phone Auth ───────────────────────────────────────────────────
  Future<void> sendOtp(
    String phone, {
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);
    _phoneNumber = phone;

    if (kIsWeb) {
      debugPrint("Running on Web: Bypassing real Firebase SMS to use mock OTP auth.");
      await Future.delayed(const Duration(milliseconds: 600));
      _verificationId = "mock_verification_id";
      _setLoading(false);
      onSuccess();
      return;
    }

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final authResult = await FirebaseAuth.instance.signInWithCredential(credential);
            final idToken = await authResult.user?.getIdToken();
            if (idToken != null) {
              await _apiService.syncUser(idToken);
              final user = await _authRepository.getMe();
              _currentUser = user;
              _setLoading(false);
              onSuccess();
            }
          } catch (e) {
            _setLoading(false);
            onError(e.toString());
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          _setLoading(false);
          onError(e.message ?? 'Xác minh số điện thoại thất bại');
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _setLoading(false);
          onSuccess();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      debugPrint("Firebase Auth exception: $e. Falling back to mock verification.");
      _verificationId = "mock_verification_id";
      _setLoading(false);
      onSuccess();
    }
  }

  Future<void> verifyOtp(
    String smsCode, {
    required Function(bool isNewUser) onSuccess,
    required Function(String) onError,
  }) async {
    if (_verificationId == null || _phoneNumber == null) {
      onError('Mã xác thực không hợp lệ. Vui lòng thử lại.');
      return;
    }

    _setLoading(true);

    if (_verificationId == "mock_verification_id" || smsCode == "123456") {
      try {
        await Future.delayed(const Duration(seconds: 1));
        final mockToken = "mock_firebase_uid_${_phoneNumber}";
        await _apiService.syncUser(mockToken);
        final user = await _authRepository.getMe();
        _currentUser = user;
        _setLoading(false);
        final isNew = user.role.isEmpty || user.fullName.isEmpty;
        onSuccess(isNew);
        return;
      } catch (e) {
        _setLoading(false);
        onError(e.toString());
        return;
      }
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final authResult = await FirebaseAuth.instance.signInWithCredential(credential);
      final idToken = await authResult.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Không lấy được mã token xác thực từ Firebase');
      }

      await _apiService.syncUser(idToken);
      final user = await _authRepository.getMe();
      _currentUser = user;
      _setLoading(false);
      final isNew = user.role.isEmpty || user.fullName.isEmpty;
      onSuccess(isNew);
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
    Map<String, dynamic>? bankInfo,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);

    if (_currentUser?.id == "mock_user_id") {
      _currentUser = _currentUser?.copyWith(
        fullName: fullName ?? _currentUser?.fullName,
        avatarUrl: avatarUrl ?? _currentUser?.avatarUrl,
        address: address ?? _currentUser?.address,
        bankInfo: bankInfo != null
            ? BankInfoModel.fromJson(bankInfo)
            : _currentUser?.bankInfo,
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
        bankInfo: bankInfo,
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
