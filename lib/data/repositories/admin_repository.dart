import 'package:dio/dio.dart';
import '../services/api_service.dart';

class AdminRepository {
  final ApiService _apiService;

  AdminRepository(this._apiService);

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await _apiService.get('/admin/dashboard');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      throw Exception('Không tải được dữ liệu tổng quan');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không tải được dữ liệu tổng quan');
    }
  }

  Future<List<Map<String, dynamic>>> getMonthlyRevenue({String type = 'monthly'}) async {
    try {
      final response = await _apiService.get(
        '/admin/revenue/monthly',
        queryParameters: {'type': type},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      return [];
    } on DioException catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getUsers({
    String? role,
    bool? isActive,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (role != null && role.isNotEmpty) params['role'] = role;
      if (isActive != null) params['isActive'] = isActive.toString();
      if (search != null && search.isNotEmpty) params['search'] = search;

      final response = await _apiService.get('/admin/users', queryParameters: params);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      return {'items': [], 'total': 0};
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không tải được danh sách người dùng');
    }
  }

  Future<void> setUserActive(String userId, bool isActive) async {
    try {
      await _apiService.patch('/admin/users/$userId/active', data: {'isActive': isActive});
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không cập nhật được trạng thái tài khoản');
    }
  }

  Future<int> broadcastNotification({
    required String title,
    required String body,
    String? role,
  }) async {
    try {
      final payload = <String, dynamic>{'title': title, 'body': body};
      if (role != null && role.isNotEmpty) payload['role'] = role;

      final response = await _apiService.post('/admin/notifications/broadcast', data: payload);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map) {
        return (data['data']['sentCount'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không gửi được thông báo');
    }
  }

  Future<List<Map<String, dynamic>>> getUserGrowth() async {
    try {
      final response = await _apiService.get('/admin/analytics/user-growth');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      return [];
    } on DioException catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTopSellers({int limit = 5}) async {
    try {
      final response = await _apiService.get(
        '/admin/analytics/top-sellers',
        queryParameters: {'limit': limit},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      return [];
    } on DioException catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 5}) async {
    try {
      final response = await _apiService.get(
        '/admin/analytics/top-products',
        queryParameters: {'limit': limit},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      return [];
    } on DioException catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPendingSellers() async {
    try {
      final response = await _apiService.get('/admin/sellers/pending');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không tải được danh sách seller chờ duyệt');
    }
  }

  Future<void> setSellerApproval(String userId, String status) async {
    try {
      await _apiService.patch('/admin/sellers/$userId/approval', data: {'status': status});
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không cập nhật được trạng thái duyệt');
    }
  }

  Future<Map<String, dynamic>> getProducts({
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (search != null && search.isNotEmpty) params['search'] = search;

      final response = await _apiService.get('/admin/products', queryParameters: params);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      return {'items': [], 'total': 0};
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không tải được danh sách sản phẩm');
    }
  }

  Future<void> setProductVisibility(String productId, bool hidden) async {
    try {
      await _apiService.patch('/admin/products/$productId/visibility', data: {'hidden': hidden});
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không cập nhật được trạng thái sản phẩm');
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _apiService.delete('/admin/reviews/$reviewId');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không xóa được đánh giá');
    }
  }

  Future<List<Map<String, dynamic>>> getDisputes({String? status}) async {
    try {
      final params = <String, dynamic>{};
      if (status != null && status.isNotEmpty) params['status'] = status;

      final response = await _apiService.get('/admin/disputes', queryParameters: params);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data'] as List);
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không tải được danh sách khiếu nại');
    }
  }

  Future<void> resolveDispute(String disputeId, String status, String resolutionNote) async {
    try {
      await _apiService.patch(
        '/admin/disputes/$disputeId',
        data: {'status': status, 'resolutionNote': resolutionNote},
      );
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không xử lý được khiếu nại');
    }
  }

  Future<Map<String, dynamic>> getAuditLogs({int page = 1, int limit = 30}) async {
    try {
      final response = await _apiService.get(
        '/admin/audit-logs',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      return {'items': [], 'total': 0};
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Không tải được nhật ký hoạt động');
    }
  }
}
