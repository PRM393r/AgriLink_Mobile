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
import '../screens/wishlist/wishlist_screen.dart';
import '../screens/reviews/review_form_screen.dart';

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
  static const String reviewForm = '/review-form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen(), settings: settings);
      case login:
        return FadeScaleRoute(page: const LoginScreen(), settings: settings);
      case register:
        return SlideRoute(page: const RegisterScreen(), settings: settings);
      case verifyEmail:
        return SlideRoute(
          page: const VerifyEmailScreen(),
          settings: settings,
        );
      case rolePicker:
        return FadeScaleRoute(page: const RolePickerScreen(), settings: settings);
      case home:
        return FadeScaleRoute(page: const HomeScreen(), settings: settings);
      case cart:
        return SlideUpRoute(page: const CartScreen(), settings: settings);
      case checkout:
        return SlideRoute(page: const CheckoutScreen(), settings: settings);
      case orderSuccess:
        return FadeScaleRoute(page: const OrderSuccessScreen(), settings: settings);
      case orderHistory:
        return SlideRoute(page: const OrderHistoryScreen(), settings: settings);
      case orderDetail:
        return SlideUpRoute(
          page: const OrderDetailScreen(),
          settings: settings,
        );
      case sellerOrders:
        return SlideRoute(page: const SellerOrderScreen(), settings: settings);
      case customer:
        return FadeScaleRoute(
            page: const CustomerDashboardScreen(), settings: settings);
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
      case reviewForm:
        return SlideUpRoute(page: const ReviewFormScreen(), settings: settings);
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
