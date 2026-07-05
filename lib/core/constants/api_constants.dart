class ApiConstants {
  const ApiConstants._();

  // For Android Emulator, use 'http://10.0.2.2:3001/api/v1'
  // For Web/Chrome and iOS Simulator, use 'http://localhost:3001/api/v1'
  static const String baseUrl = 'http://localhost:3001/api/v1';
  static const String wsUrl = 'http://localhost:3001/notifications';

  // Auth Endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String login = '/auth/login';
  static const String loginOtp = '/auth/login-otp';
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
  static const String notificationsRead = '/notifications'; // /notifications/:id/read
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';
}
