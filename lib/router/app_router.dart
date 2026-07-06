import 'package:flutter/material.dart';
import '../core/utils/page_transitions.dart';
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

import '../screens/dashboard/farmer/my_products_screen.dart';
import '../screens/dashboard/farmer/product_form_screen.dart';
import '../screens/marketplace/wishlist_screen.dart';

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
  static const String myProducts = '/my-products';
  static const String productForm = '/product-form';
  static const String wishlist = '/wishlist';
  static const String editProfile = '/edit-profile';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case login:
        return FadeScaleRoute(page: const LoginScreen());
      case register:
        return SlideRoute(page: const RegisterScreen());
      case verifyEmail:
        return SlideRoute(
          page: const VerifyEmailScreen(),
        );
      case rolePicker:
        return FadeScaleRoute(page: const RolePickerScreen());
      case home:
        return FadeScaleRoute(page: const HomeScreen());
      case cart:
        return SlideUpRoute(page: const CartScreen());
      case checkout:
        return SlideRoute(page: const CheckoutScreen());
      case orderSuccess:
        return FadeScaleRoute(page: const OrderSuccessScreen());
      case orderHistory:
        return SlideRoute(page: const OrderHistoryScreen());
      case orderDetail:
        return SlideUpRoute(
          page: const OrderDetailScreen(),
        );
      case sellerOrders:
        return SlideRoute(page: const SellerOrderScreen());
      case customer:
        return FadeScaleRoute(
            page: const CustomerDashboardScreen());
      case marketplace:
        return SlideRoute(page: const MarketplaceScreen());
      case productDetail:
        return SlideUpRoute(page: const ProductDetailScreen());
      case myProducts:
        return SlideRoute(page: const MyProductsScreen());
      case productForm:
        return SlideRoute(page: const ProductFormScreen());
      case wishlist:
        return SlideRoute(page: const WishlistScreen());
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
