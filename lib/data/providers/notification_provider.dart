import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this._service);

  final NotificationService _service;

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasLoaded = false;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications({bool force = false}) async {
    if (_isLoading || (_hasLoaded && !force)) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.fetchNotifications();
      final items = data['items'] as List? ?? const [];
      _notifications = items
          .whereType<Map>()
          .map((item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      _unreadCount = (data['unreadCount'] as num?)?.toInt() ??
          _notifications.where((item) => !item.isRead).length;
      _hasLoaded = true;
    } catch (error) {
      _errorMessage = _messageFrom(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchNotifications(force: true);

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((item) => item.id == notificationId);
    if (index < 0 || _notifications[index].isRead) return;

    final previous = _notifications[index];
    _notifications[index] = previous.copyWith(isRead: true);
    _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
    notifyListeners();

    try {
      await _service.markAsRead(notificationId);
    } catch (error) {
      _notifications[index] = previous;
      _unreadCount++;
      _errorMessage = _messageFrom(error);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    if (_unreadCount == 0) return;
    final previous = List<NotificationModel>.from(_notifications);
    final previousCount = _unreadCount;
    _notifications = _notifications.map((item) => item.copyWith(isRead: true)).toList();
    _unreadCount = 0;
    notifyListeners();

    try {
      await _service.markAllAsRead();
    } catch (error) {
      _notifications = previous;
      _unreadCount = previousCount;
      _errorMessage = _messageFrom(error);
      notifyListeners();
    }
  }

  String _messageFrom(Object error) =>
      error.toString().replaceFirst('Exception:', '').trim();
}
