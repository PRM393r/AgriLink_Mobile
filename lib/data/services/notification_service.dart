import 'dart:async';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../models/notification_model.dart';
import 'api_service.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/token_storage.dart';

class NotificationService {
  final ApiService _apiService;
  io.Socket? _socket;

  // Stream controller to broadcast new real-time notifications to the UI
  final _notificationStreamController =
      StreamController<NotificationModel>.broadcast();
  Stream<NotificationModel> get newNotifications =>
      _notificationStreamController.stream;

  NotificationService(this._apiService);

  /// Initializes the WebSockets connection to the NestJS gateway.
  void initializeSocket() async {
    if (!ApiConstants.enableNotificationSocket) {
      return;
    }

    try {
      final token = await TokenStorage.getToken();
      if (token == null) return;

      // Close existing socket if any
      _socket?.disconnect();
      _socket?.dispose();

      _socket = io.io(
        ApiConstants.wsUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .setExtraHeaders({'Authorization': 'Bearer $token'})
            .enableAutoConnect()
            .build(),
      );

      _socket?.onConnect((_) {
        // Connected to notification gateway
      });

      _socket?.on('new_notification', (data) {
        if (data is Map<String, dynamic>) {
          final notification = NotificationModel.fromJson(data);
          _notificationStreamController.add(notification);
        }
      });

      _socket?.onDisconnect((_) {
        // Disconnected from notification gateway
      });
    } catch (_) {
      // Fail silently, fallback to REST
    }
  }

  /// Closes the WebSockets connection.
  void disposeSocket() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  /// Fetches the list of unread notifications via REST API.
  Future<List<NotificationModel>> fetchUnreadNotifications() async {
    try {
      final response = await _apiService.get(ApiConstants.notificationsUnread);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        final list = data['data'] as List;
        return list
            .map(
              (json) =>
                  NotificationModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Lấy thông tin thông báo thất bại');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  /// Fetches unread notification count.
  Future<int> fetchUnreadCount() async {
    try {
      final response = await _apiService.get(ApiConstants.notificationsCount);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return (data['data']['count'] as int?) ?? 0;
      }
      return 0;
    } catch (_) {
      return 0;
    }
  }

  /// Marks a specific notification as read.
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiService.patch(
        '${ApiConstants.notificationsRead}/$notificationId/read',
      );
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Đánh dấu đã đọc thất bại');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  /// Marks all notifications as read.
  Future<void> markAllAsRead() async {
    try {
      await _apiService.patch(ApiConstants.notificationsMarkAllRead);
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Đánh dấu đọc tất cả thất bại');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }
}
