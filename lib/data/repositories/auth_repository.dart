import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../../core/utils/token_storage.dart';
import '../../core/constants/api_constants.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  /// Standardized success response structure: { data: T }
  /// Returns the UserModel and saves the backend JWT token.
  Future<UserModel> loginWithOtp({
    required String phone,
    required String idToken,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.loginOtp,
        data: {'phone': phone, 'idToken': idToken},
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        final innerData = data['data'] as Map<String, dynamic>;
        final token = innerData['token'] as String? ?? '';
        final userJson = innerData['user'] as Map<String, dynamic>? ?? {};

        // Save token to secure storage
        if (token.isNotEmpty) {
          await TokenStorage.saveToken(token);
        }

        return UserModel.fromJson(userJson);
      }
      throw Exception('Định dạng phản hồi không hợp lệ từ máy chủ');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Đăng nhập OTP thất bại');
    } catch (e) {
      throw Exception('Đăng nhập thất bại: $e');
    }
  }

  /// Fetches current user profile from PostgreSQL via NestJS backend.
  Future<UserModel> getMe() async {
    try {
      final response = await _apiService.get(ApiConstants.getMe);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return UserModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Định dạng phản hồi không hợp lệ');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Lấy thông tin tài khoản thất bại');
    } catch (e) {
      throw Exception('Lỗi lấy thông tin: $e');
    }
  }

  /// Updates the user's role on the NestJS backend.
  Future<UserModel> updateRole(String role) async {
    try {
      final backendRole = role == 'customer' ? 'buyer' : role;
      final response = await _apiService.put(
        ApiConstants.updateRole,
        data: {'role': backendRole},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return UserModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Cập nhật vai trò thất bại');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Cập nhật vai trò thất bại');
    } catch (e) {
      throw Exception('Lỗi cập nhật vai trò: $e');
    }
  }

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
