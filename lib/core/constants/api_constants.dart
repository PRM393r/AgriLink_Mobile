import 'package:flutter/foundation.dart';

class ApiConstants {
  const ApiConstants._();

  // Backend audit: NestJS runs on APP_PORT=5000 with global prefix /api/v1.
  // Android Emulator reaches the host machine through 10.0.2.2.
  static String get _host =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? '10.0.2.2'
      : 'localhost';

  static String get baseUrl => 'http://$_host:5000/api/v1';
  static String get wsUrl => 'http://$_host:5000/notifications';
  static const bool enableNotificationSocket = false;

  // Auth Endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String login = '/auth/login';
  static const String loginOtp = '/auth/login-otp';
  static const String syncUser = '/auth/sync';
  static const String getMe = '/users/me';
  static const String updateMe = '/users/me';
  static const String updateRole =
      '/users/me/role'; // From the initial specs, PUT /users/me/role

  // Products Endpoints
  static const String products = '/products';
  static const String productCategories = '/products/categories';

  // Cooperatives Endpoints
  static const String bulkListings = '/cooperatives/bulk-listings';
  static const String myBulkListings = '/cooperatives/me/bulk-listings';
  static const String members = '/cooperatives/me/members';
  static const String harvestSchedules = '/cooperatives/harvest-schedules';

  // Notifications Endpoints
  static const String notificationsUnread = '/notifications/unread';
  static const String notificationsCount = '/notifications/count';
  static const String notificationsRead =
      '/notifications'; // /notifications/:id/read
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';
}
