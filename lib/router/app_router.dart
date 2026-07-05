import 'package:flutter/material.dart';
import '../core/utils/page_transitions.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/role_picker_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/dashboard/customer/customer_dashboard_screen.dart';
import '../screens/marketplace/marketplace_screen.dart';
import '../screens/marketplace/product_detail_screen.dart';
import '../screens/profile/edit_profile_screen.dart';

class AppRouter {
  const AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String rolePicker = '/role-picker';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String customer = '/customer';
  static const String marketplace = '/marketplace';
  static const String productDetail = '/product-detail';
  static const String editProfile = '/edit-profile';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return FadeScaleRoute(page: const LoginScreen());
      case otp:
        return SlideRoute(page: const OtpScreen());
      case rolePicker:
        return FadeScaleRoute(page: const RolePickerScreen());
      case home:
        return FadeScaleRoute(page: const HomeScreen());
      case cart:
        return SlideUpRoute(page: const CartScreen());
      case customer:
        return FadeScaleRoute(
            page: const CustomerDashboardScreen());
      case marketplace:
        return SlideRoute(page: const MarketplaceScreen());
      case productDetail:
        return SlideUpRoute(
            page: const ProductDetailScreen());
      case editProfile:
        return SlideRoute(page: const EditProfileScreen());
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
