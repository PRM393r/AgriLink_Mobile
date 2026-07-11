import 'package:flutter/foundation.dart';

class ApiConstants {
  const ApiConstants._();

  static String get _host =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android
      ? '10.0.2.2'
      : 'localhost';

  static String get baseUrl => 'http://$_host:5000/api/v1';

  // ── Auth ──────────────────────────────────────────────────────────────────
  static const String register = '/auth/register';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendOtp = '/auth/resend-otp';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // ── Users ─────────────────────────────────────────────────────────────────
  static const String getMe = '/users/me';
  static const String updateMe = '/users/me';
  static const String updateRole = '/users/me/role';

  // ── Products ──────────────────────────────────────────────────────────────
  static const String products = '/products';
  static const String productCategories = '/products/categories';

  // ── Orders ────────────────────────────────────────────────────────────────
  static const String orders = '/orders';

  // ── Notifications (REST only — no WebSocket in MVP) ───────────────────────
  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';

  static const String marketPrices = '/market-prices';

  // ── Storage ───────────────────────────────────────────────────────────────
  static const String storage = '/storage';

  // ── WebSocket ─────────────────────────────────────────────────────────────
  static String get wsUrl => 'http://$_host:5000/notifications';
  static String get trackingSocketUrl => 'http://$_host:5000';
  static const bool enableNotificationSocket = false;
}
