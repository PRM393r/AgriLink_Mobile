import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../../core/utils/token_storage.dart';
import '../../core/constants/api_constants.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  // ── POST /auth/register ───────────────────────────────────────���──────────
  /// Tạo tài khoản mới, BE gửi OTP về email.
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      await _apiService.post(
        ApiConstants.register,
        data: {'email': email, 'password': password, 'fullName': fullName},
      );
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Đăng ký thất bại');
    } catch (e) {
      throw Exception('Đăng ký thất bại: $e');
    }
  }

  // ── POST /auth/verify-email ──────────────────────────────────────────────
  /// Xác nhận OTP email. BE trả accessToken + refreshToken sau khi verify.
  Future<Map<String, String>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.verifyEmail,
        data: {'email': email, 'code': code},
      );
      // BE chỉ trả { statusCode, data: null, message } — không trả token ở bước này.
      // Token có sau bước login.
      return {};
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Xác thực email thất bại');
    } catch (e) {
      throw Exception('Lỗi xác thực: $e');
    }
  }

  // ── POST /auth/resend-otp ────────────────────────────────────────────────
  Future<void> resendOtp(String email) async {
    try {
      await _apiService.post(
        ApiConstants.resendOtp,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Gửi lại OTP thất bại');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // ── POST /auth/login ─────────────────────────────────────────────────────
  /// Đăng nhập email + password → lưu token, trả UserModel.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final envelope = response.data as Map<String, dynamic>?;
      final data = envelope?['data'] as Map<String, dynamic>?;
      if (data == null) throw Exception('Phản hồi không hợp lệ từ máy chủ');

      final accessToken  = data['accessToken']  as String? ?? '';
      final refreshToken = data['refreshToken'] as String? ?? '';
      final userJson     = data['user']         as Map<String, dynamic>? ?? {};

      if (accessToken.isNotEmpty) {
        await TokenStorage.saveToken(accessToken);
      }
      if (refreshToken.isNotEmpty) {
        await TokenStorage.saveRefreshToken(refreshToken);
      }

      return UserModel.fromJson(userJson);
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Đăng nhập thất bại');
    } catch (e) {
      throw Exception('Đăng nhập thất bại: $e');
    }
  }

  // ── GET /users/me ────────────────────────────────────────────────────────
  Future<UserModel> getMe() async {
    try {
      final response = await _apiService.get(ApiConstants.getMe);
      final envelope = response.data as Map<String, dynamic>?;
      final data = envelope?['data'] as Map<String, dynamic>?;
      if (data == null) throw Exception('Phản hồi không hợp lệ');
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Lấy thông tin tài khoản thất bại');
    } catch (e) {
      throw Exception('Lỗi lấy thông tin: $e');
    }
  }

  // ── PUT /users/me/role ───────────────────────────────────────────────────
  Future<UserModel> updateRole(String role) async {
    try {
      final response = await _apiService.put(
        ApiConstants.updateRole,
        data: {'role': role},
      );
      final envelope = response.data as Map<String, dynamic>?;
      final data = envelope?['data'] as Map<String, dynamic>?;
      if (data == null) throw Exception('Cập nhật vai trò thất bại');
      // BE chỉ trả { role } — merge vào currentUser ở provider
      return getMe();
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Cập nhật vai trò thất bại');
    } catch (e) {
      throw Exception('Lỗi cập nhật vai trò: $e');
    }
  }

  // ── POST /auth/refresh ───────────────────────────────────────────────────
  Future<String> refreshAccessToken() async {
    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) throw Exception('Không có refresh token');
      final response = await _apiService.post(
        ApiConstants.refresh,
        data: {'refreshToken': refreshToken},
      );
      final envelope = response.data as Map<String, dynamic>?;
      final data = envelope?['data'] as Map<String, dynamic>?;
      final newAccess  = data?['accessToken']  as String? ?? '';
      final newRefresh = data?['refreshToken'] as String? ?? '';
      if (newAccess.isNotEmpty)  await TokenStorage.saveToken(newAccess);
      if (newRefresh.isNotEmpty) await TokenStorage.saveRefreshToken(newRefresh);
      return newAccess;
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Làm mới token thất bại');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // ── POST /auth/logout ────────────────────────────────────────────────────
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConstants.logout);
    } catch (_) {
      // Luôn clear local dù BE lỗi
    } finally {
      await TokenStorage.deleteToken();
      await TokenStorage.deleteRefreshToken();
  /// Updates the authenticated user's profile on the NestJS backend.
  Future<UserModel> updateProfile({
    String? fullName,
    String? email,
    String? avatarUrl,
  }) async {
    try {
      final response = await _apiService.patch(
        ApiConstants.updateMe,
        data: {'fullName': ?fullName, 'email': ?email, 'avatarUrl': ?avatarUrl},
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return UserModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Cập nhật hồ sơ thất bại');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Cập nhật hồ sơ thất bại');
    } catch (e) {
      throw Exception('Lỗi cập nhật hồ sơ: $e');
    }
  }
}
