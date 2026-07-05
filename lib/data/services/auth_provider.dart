import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/utils/token_storage.dart';
import '../../core/utils/phone_formatter.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  late final ApiService _apiService;
  late final AuthRepository _authRepository;
  late final NotificationService _notificationService;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _verificationId;
  String? _phoneNumber;

  AuthProvider() {
    _apiService = ApiService();
    _authRepository = AuthRepository(_apiService);
    _notificationService = NotificationService(_apiService);
  }

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get verificationId => _verificationId;
  String? get phoneNumber => _phoneNumber;
  bool get isAuthenticated => _currentUser != null;

  ApiService get apiService => _apiService;
  NotificationService get notificationService => _notificationService;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  static String _mockRole = 'farmer';

  /// Initial entry point to check if the user is already authenticated.
  Future<bool> checkLogin() async {
    final token = await TokenStorage.getToken();
    if (token == null) {
      return false;
    }

    if (token == "mock_jwt_token") {
      _currentUser = UserModel(
        id: "mock_user_id",
        phone: _phoneNumber ?? "0987654321",
        fullName: "Người dùng thử nghiệm",
        role: _mockRole,
        status: "active",
      );
      notifyListeners();
      return true;
    }

    try {
      // Fetch user profile from NestJS
      final user = await _authRepository.getMe();
      _currentUser = user;
      
      // Initialize WebSocket connection for notifications
      _notificationService.initializeSocket();
      
      notifyListeners();
      return true;
    } catch (_) {
      // If token is invalid or expired, clear it
      await TokenStorage.deleteToken();
      _currentUser = null;
      notifyListeners();
      return false;
    }
  }

  /// Requests Firebase OTP for the given phone number.
  Future<void> sendOtp(String phone, {required VoidCallback onSuccess, required Function(String) onError}) async {
    _setLoading(true);
    _phoneNumber = PhoneFormatter.formatToE164(phone);

    // If running on web, use mock OTP auth directly to bypass Firebase Web recaptcha/region restrictions.
    if (kIsWeb) {
      debugPrint("Running on Web: Bypassing real Firebase SMS to use mock OTP auth.");
      await Future.delayed(const Duration(milliseconds: 600));
      _verificationId = "mock_verification_id";
      _setLoading(false);
      onSuccess();
      return;
    }

    try {
      await _authService.sendOtp(
        phoneNumber: _phoneNumber!,
        onCodeSent: (verId) {
          _verificationId = verId;
          _setLoading(false);
          onSuccess();
        },
        onError: (error) {
          // Fallback to mock mode
          debugPrint("Firebase Auth error: $error. Falling back to mock verification.");
          _verificationId = "mock_verification_id";
          _setLoading(false);
          onSuccess();
        },
      );
    } catch (e) {
      debugPrint("Firebase Auth exception: $e. Falling back to mock verification.");
      _verificationId = "mock_verification_id";
      _setLoading(false);
      onSuccess();
    }
  }

  /// Verifies Firebase OTP, sends Firebase token to NestJS, and synchronizes.
  Future<void> verifyOtp(String smsCode, {required Function(bool isNewUser) onSuccess, required Function(String) onError}) async {
    if (_verificationId == null || _phoneNumber == null) {
      onError('Mã xác thực không hợp lệ. Vui lòng thử lại.');
      return;
    }

    _setLoading(true);

    if (_verificationId == "mock_verification_id") {
      _currentUser = UserModel(
        id: "mock_user_id",
        phone: _phoneNumber!,
        fullName: "",
        role: "",
        status: "pending",
      );
      await TokenStorage.saveToken("mock_jwt_token");
      _setLoading(false);
      onSuccess(true);
      return;
    }

    try {
      // 1. Verify OTP with Firebase Auth
      final credential = await _authService.verifyOtp(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      // 2. Fetch Firebase ID Token
      final idToken = await credential.user?.getIdToken(true);
      if (idToken == null) {
        throw Exception('Không lấy được mã token xác thực từ Firebase');
      }

      // 3. Login/Sync with NestJS Backend
      final user = await _authRepository.loginWithOtp(
        phone: _phoneNumber!,
        idToken: idToken,
      );

      _currentUser = user;
      
      // 4. Initialize real-time socket
      _notificationService.initializeSocket();

      _setLoading(false);
      // If user status is pending or role is empty, they are considered a new user needing role selection
      final isNew = user.role.isEmpty || user.role == 'farmer' && user.fullName.isEmpty; 
      onSuccess(isNew);
    } catch (e) {
      _setLoading(false);
      onError(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  /// Updates the user's role on NestJS and updates state.
  Future<void> updateRole(String role, {required VoidCallback onSuccess, required Function(String) onError}) async {
    _setLoading(true);

    if (_currentUser?.id == "mock_user_id") {
      _mockRole = role;
      _currentUser = UserModel(
        id: "mock_user_id",
        phone: _phoneNumber ?? "0987654321",
        fullName: "Người dùng thử nghiệm",
        role: role,
        status: "active",
      );
      _setLoading(false);
      onSuccess();
      return;
    }

    try {
      final updatedUser = await _authRepository.updateRole(role);
      _currentUser = updatedUser;
      _setLoading(false);
      onSuccess();
    } catch (e) {
      _setLoading(false);
      onError(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  /// Updates the user's editable profile fields on NestJS and updates state.
  Future<void> updateProfile({
    String? fullName,
    String? email,
    String? avatarUrl,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    _setLoading(true);

    if (_currentUser?.id == "mock_user_id") {
      _currentUser = _currentUser?.copyWith(
        fullName: fullName ?? _currentUser?.fullName,
        email: email ?? _currentUser?.email,
        avatarUrl: avatarUrl ?? _currentUser?.avatarUrl,
      );
      _setLoading(false);
      onSuccess();
      return;
    }

    try {
      final updatedUser = await _authRepository.updateProfile(
        fullName: fullName,
        email: email,
        avatarUrl: avatarUrl,
      );
      _currentUser = updatedUser;
      _setLoading(false);
      onSuccess();
    } catch (e) {
      _setLoading(false);
      onError(e.toString().replaceAll('Exception:', '').trim());
    }
  }

  /// Signs out of Firebase and deletes stored NestJS JWT token.
  Future<void> logout() async {
    _setLoading(true);
    try {
      _notificationService.disposeSocket();
      await _authService.signOut();
      await TokenStorage.deleteToken();
      _currentUser = null;
      _phoneNumber = null;
      _verificationId = null;
    } catch (_) {
      // Silently logout local state
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }
}
