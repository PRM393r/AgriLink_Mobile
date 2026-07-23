import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'data/services/auth_provider.dart';
import 'data/providers/cart_provider.dart';

import 'data/services/api_service.dart';
import 'data/repositories/product_repository.dart';
import 'data/services/product_service.dart';
import 'data/services/wishlist_service.dart';
import 'data/providers/wishlist_provider.dart';
import 'data/repositories/order_repository.dart';
import 'data/services/order_service.dart';
import 'data/services/review_service.dart';
import 'data/services/notification_service.dart';
import 'data/providers/notification_provider.dart';
import 'data/services/market_price_service.dart';
import 'data/providers/market_price_provider.dart';
import 'data/services/trace_service.dart';
import 'data/providers/trace_provider.dart';
import 'data/repositories/admin_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Restore local cart before first frame so badge/count is correct on Home.
  final cartProvider = CartProvider();
  await cartProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider<CartProvider>.value(value: cartProvider),
        Provider<ApiService>(create: (_) => ApiService()),
        ProxyProvider<ApiService, NotificationService>(
          update: (_, api, __) => NotificationService(api),
        ),
        ChangeNotifierProxyProvider<NotificationService, NotificationProvider>(
          create: (context) => NotificationProvider(context.read<NotificationService>()),
          update: (_, service, provider) => provider ?? NotificationProvider(service),
        ),
        ProxyProvider<ApiService, MarketPriceService>(
          update: (_, api, __) => MarketPriceService(api),
        ),
        ChangeNotifierProxyProvider<MarketPriceService, MarketPriceProvider>(
          create: (context) => MarketPriceProvider(context.read<MarketPriceService>()),
          update: (_, service, provider) => provider ?? MarketPriceProvider(service),
        ),
        ProxyProvider<ApiService, TraceService>(
          update: (_, api, __) => TraceService(api),
        ),
        ChangeNotifierProxyProvider<TraceService, TraceProvider>(
          create: (context) => TraceProvider(context.read<TraceService>()),
          update: (_, service, provider) => provider ?? TraceProvider(service),
        ),
        ProxyProvider<ApiService, ProductRepository>(
          update: (_, api, __) => ProductRepository(api),
        ),
        ProxyProvider<ProductRepository, ProductService>(
          update: (_, repo, __) => ProductService(repo),
        ),
        ProxyProvider<ApiService, WishlistService>(
          update: (_, api, __) => WishlistService(api),
        ),
        ChangeNotifierProxyProvider<WishlistService, WishlistProvider>(
          create: (_) => WishlistProvider(WishlistService(ApiService())),
          update: (_, service, provider) => provider ?? WishlistProvider(service),
        ),
        ProxyProvider<ApiService, OrderRepository>(
          update: (_, api, __) => OrderRepository(api),
        ),
        ProxyProvider<OrderRepository, OrderService>(
          update: (_, repo, __) => OrderService(repo),
        ),
        ProxyProvider<ApiService, ReviewService>(
          update: (_, api, __) => ReviewService(api),
        ),
        ProxyProvider<ApiService, AdminRepository>(
          update: (_, api, __) => AdminRepository(api),
        ),
      ],
      child: const AgriLinkApp(),
    ),
  );
}

class AgriLinkApp extends StatelessWidget {
  const AgriLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
