import 'package:flutter/material.dart';
import '../data/models/order_model.dart';
import '../core/utils/page_transitions.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/auth/role_picker_screen.dart';
import '../screens/auth/seller_pending_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/checkout/order_success_screen.dart';
import '../screens/checkout/payment_qr_screen.dart';
import '../screens/checkout/payment_payos_screen.dart';
import '../screens/orders/order_history_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/orders/seller_order_screen.dart';
import '../screens/dashboard/customer/customer_dashboard_screen.dart';
import '../screens/marketplace/marketplace_screen.dart';
import '../screens/marketplace/product_detail_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/orders/order_tracking_screen.dart';
import '../screens/support/faq_screen.dart';
import '../screens/support/terms_screen.dart';
import '../screens/support/privacy_screen.dart';
import '../screens/support/how_to_buy_screen.dart';

import '../screens/dashboard/farmer/my_products_screen.dart';
import '../screens/dashboard/farmer/product_form_screen.dart';
import '../screens/wishlist/wishlist_screen.dart';
import '../screens/reviews/review_form_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/prices/prices_screen.dart';
import '../screens/trace/trace_screen.dart';
import '../screens/trace/qr_scanner_screen.dart';
import '../screens/trace/trace_detail_screen.dart';
import '../screens/dashboard/admin/admin_dashboard_screen.dart';
import '../screens/dashboard/admin/admin_users_screen.dart';
import '../screens/dashboard/admin/admin_broadcast_screen.dart';
import '../screens/dashboard/admin/admin_pending_sellers_screen.dart';
import '../screens/dashboard/admin/admin_products_screen.dart';
import '../screens/dashboard/admin/admin_disputes_screen.dart';
import '../screens/dashboard/admin/admin_audit_log_screen.dart';

class AppRouter {
  const AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String rolePicker = '/role-picker';
  static const String sellerPending = '/seller-pending';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String paymentQr = '/payment-qr';
  static const String paymentPayos = '/payment-payos';
  static const String orderHistory = '/order-history';
  static const String orderDetail = '/order-detail';
  static const String sellerOrders = '/seller-orders';
  static const String customer = '/customer';
  static const String marketplace = '/marketplace';
  static const String productDetail = '/product-detail';
  static const String myProducts = '/my-products';
  static const String productForm = '/product-form';
  static const String wishlist = '/wishlist';
  static const String editProfile = '/edit-profile';
  static const String orderTracking = '/order-tracking';
  static const String faq = '/faq';
  static const String terms = '/terms';
  static const String privacy = '/privacy';
  static const String howToBuy = '/how-to-buy';
  static const String reviewForm = '/review-form';
  static const String notifications = '/notifications';
  static const String marketPrices = '/market-prices';
  static const String trace = '/trace';
  static const String qrScanner = '/trace/scanner';
  static const String traceDetail = '/trace/detail';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminBroadcast = '/admin/broadcast';
  static const String adminPendingSellers = '/admin/sellers/pending';
  static const String adminProducts = '/admin/products';
  static const String adminDisputes = '/admin/disputes';
  static const String adminAuditLog = '/admin/audit-log';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen(), settings: settings);
      case login:
        return FadeScaleRoute(page: const LoginScreen(), settings: settings);
      case register:
        return SlideRoute(page: const RegisterScreen(), settings: settings);
      case verifyEmail:
        return SlideRoute(page: const VerifyEmailScreen(), settings: settings);
      case rolePicker:
        return FadeScaleRoute(page: const RolePickerScreen(), settings: settings);
      case sellerPending:
        return FadeScaleRoute(page: const SellerPendingScreen(), settings: settings);
      case home:
        return FadeScaleRoute(page: const HomeScreen(), settings: settings);
      case cart:
        return SlideUpRoute(page: const CartScreen(), settings: settings);
      case checkout:
        return SlideRoute(page: const CheckoutScreen(), settings: settings);
      case orderSuccess:
        return FadeScaleRoute(page: const OrderSuccessScreen(), settings: settings);
      case paymentQr:
        return SlideUpRoute(
          page: PaymentQrScreen(orders: settings.arguments as List<OrderModel>),
          settings: settings,
        );
      case paymentPayos:
        return SlideUpRoute(
          page: PaymentPayosScreen(orders: settings.arguments as List<OrderModel>),
          settings: settings,
        );
      case orderHistory:
        return SlideRoute(page: const OrderHistoryScreen(), settings: settings);
      case orderDetail:
        return SlideUpRoute(page: const OrderDetailScreen(), settings: settings);
      case sellerOrders:
        return SlideRoute(page: const SellerOrderScreen(), settings: settings);
      case customer:
        return FadeScaleRoute(page: const CustomerDashboardScreen(), settings: settings);
      case marketplace:
        return SlideRoute(page: const MarketplaceScreen(), settings: settings);
      case productDetail:
        return SlideUpRoute(page: const ProductDetailScreen(), settings: settings);
      case myProducts:
        return SlideRoute(page: const MyProductsScreen(), settings: settings);
      case productForm:
        return SlideRoute(page: const ProductFormScreen(), settings: settings);
      case wishlist:
        return SlideRoute(page: const WishlistScreen(), settings: settings);
      case editProfile:
        return SlideRoute(page: const EditProfileScreen(), settings: settings);
      case orderTracking:
        final args = settings.arguments as Map<String, dynamic>;
        return SlideUpRoute(
          page: OrderTrackingScreen(
            orderId: args['orderId'] as String,
            orderCode: args['orderCode'] as String,
            token: args['token'] as String?,
          ),
          settings: settings,
        );
      case faq:
        return SlideRoute(page: const FaqScreen(), settings: settings);
      case terms:
        return SlideRoute(page: const TermsScreen(), settings: settings);
      case privacy:
        return SlideRoute(page: const PrivacyScreen(), settings: settings);
      case howToBuy:
        return SlideRoute(page: const HowToBuyScreen(), settings: settings);
      case reviewForm:
        return SlideUpRoute(page: const ReviewFormScreen(), settings: settings);
      case notifications:
        return SlideRoute(page: const NotificationsScreen(), settings: settings);
      case marketPrices:
        return SlideRoute(page: const PricesScreen(), settings: settings);
      case trace:
        return SlideRoute(page: const TraceScreen(), settings: settings);
      case qrScanner:
        return SlideUpRoute(page: const QrScannerScreen(), settings: settings);
      case traceDetail:
        return SlideRoute(page: const TraceDetailScreen(), settings: settings);
      case adminDashboard:
        return FadeScaleRoute(page: const AdminDashboardScreen(), settings: settings);
      case adminUsers:
        return SlideRoute(page: const AdminUsersScreen(), settings: settings);
      case adminBroadcast:
        return SlideUpRoute(page: const AdminBroadcastScreen(), settings: settings);
      case adminPendingSellers:
        return SlideRoute(page: const AdminPendingSellersScreen(), settings: settings);
      case adminProducts:
        return SlideRoute(page: const AdminProductsScreen(), settings: settings);
      case adminDisputes:
        return SlideRoute(page: const AdminDisputesScreen(), settings: settings);
      case adminAuditLog:
        return SlideRoute(page: const AdminAuditLogScreen(), settings: settings);
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Đường dẫn không tồn tại: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
