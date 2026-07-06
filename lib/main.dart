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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        Provider<ApiService>(create: (_) => ApiService()),
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
