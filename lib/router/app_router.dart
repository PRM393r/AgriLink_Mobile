import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/role_picker_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/dashboard/customer/customer_dashboard_screen.dart';
import '../screens/marketplace/marketplace_screen.dart';
import '../screens/marketplace/product_detail_screen.dart';

import '../screens/dashboard/farmer/my_products_screen.dart';
import '../screens/dashboard/farmer/product_form_screen.dart';
import '../screens/marketplace/wishlist_screen.dart';

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
  static const String myProducts = '/my-products';
  static const String productForm = '/product-form';
  static const String wishlist = '/wishlist';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case otp:
        return MaterialPageRoute(builder: (_) => const OtpScreen());
      case rolePicker:
        return MaterialPageRoute(builder: (_) => const RolePickerScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      case customer:
        return MaterialPageRoute(builder: (_) => const CustomerDashboardScreen());
      case marketplace:
        return MaterialPageRoute(builder: (_) => const MarketplaceScreen());
      case productDetail:
        return MaterialPageRoute(builder: (_) => const ProductDetailScreen());
      case myProducts:
        return MaterialPageRoute(builder: (_) => const MyProductsScreen());
      case productForm:
        return MaterialPageRoute(builder: (_) => const ProductFormScreen());
      case wishlist:
        return MaterialPageRoute(builder: (_) => const WishlistScreen());
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

