import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/verify_email_screen.dart';
import '../screens/auth/role_picker_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/checkout/order_success_screen.dart';
import '../screens/orders/order_history_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/orders/seller_order_screen.dart';
import '../screens/dashboard/customer/customer_dashboard_screen.dart';
import '../screens/marketplace/marketplace_screen.dart';
import '../screens/marketplace/product_detail_screen.dart';
import '../screens/profile/edit_profile_screen.dart';

class AppRouter {
  const AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String rolePicker = '/role-picker';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';
  static const String orderHistory = '/order-history';
  static const String orderDetail = '/order-detail';
  static const String sellerOrders = '/seller-orders';
  static const String customer = '/customer';
  static const String marketplace = '/marketplace';
  static const String productDetail = '/product-detail';
  static const String editProfile = '/edit-profile';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case verifyEmail:
        return MaterialPageRoute(
          builder: (_) => const VerifyEmailScreen(),
          settings: settings,
        );
      case rolePicker:
        return MaterialPageRoute(builder: (_) => const RolePickerScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case orderSuccess:
        return MaterialPageRoute(builder: (_) => const OrderSuccessScreen());
      case orderHistory:
        return MaterialPageRoute(builder: (_) => const OrderHistoryScreen());
      case orderDetail:
        return MaterialPageRoute(
          builder: (_) => const OrderDetailScreen(),
          settings: settings,
        );
      case sellerOrders:
        return MaterialPageRoute(builder: (_) => const SellerOrderScreen());
      case customer:
        return MaterialPageRoute(
          builder: (_) => const CustomerDashboardScreen(),
        );
      case marketplace:
        return MaterialPageRoute(builder: (_) => const MarketplaceScreen());
      case productDetail:
        return MaterialPageRoute(builder: (_) => const ProductDetailScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
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
