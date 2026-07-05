import 'dart:async';
import 'package:dio/dio.dart';
import '../models/notification_model.dart';
import 'api_service.dart';
import '../../core/constants/api_constants.dart';

class NotificationService {
  final ApiService _apiService;

  // Socket bị tắt — backend mới không có WebSocket gateway
  final _notificationStreamController =
      StreamController<NotificationModel>.broadcast();
  Stream<NotificationModel> get newNotifications =>
      _notificationStreamController.stream;

  NotificationService(this._apiService);

  void initializeSocket() {
    // Socket tắt — dùng REST polling
  }

  void disposeSocket() {
    // no-op
  }

  // ── GET /notifications ────────────────────────────────────────────────────
  // Trả v�� { items[], total, unreadCount }
  Future<Map<String, dynamic>> fetchNotifications({bool? isRead}) async {
    try {
      final query = isRead != null ? {'isRead': isRead.toString()} : null;
      final response = await _apiService.get(
        ApiConstants.notifications,
        queryParameters: query,
      );
      final data = (response.data as Map<String, dynamic>?)?['data'];
      if (data is Map<String, dynamic>) return data;
      return {'items': [], 'total': 0, 'unreadCount': 0};
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Lấy thông báo thất bại');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  /// Tiện ích: chỉ lấy danh sách chưa đọc
  Future<List<NotificationModel>> fetchUnreadNotifications() async {
    final data = await fetchNotifications(isRead: false);
    final list = data['items'] as List? ?? [];
    return list
        .map((j) => NotificationModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Tiện ích: đếm chưa đọc (lấy từ unreadCount trả kèm mọi request)
  Future<int> fetchUnreadCount() async {
    try {
      final data = await fetchNotifications();
      return (data['unreadCount'] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  // ── PATCH /notifications/:id/read ─────────────────────────────────────────
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.patch(
        '${ApiConstants.notifications}/$notificationId/read',
      );
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Đánh dấu đã đọc thất bại');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  // ── PATCH /notifications/read-all ─────────────────────────────────────────
  Future<void> markAllAsRead() async {
    try {
      await _apiService.patch(ApiConstants.notificationsReadAll);
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Đánh dấu đọc tất cả thất bại');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }
}
