import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/services/auth_provider.dart';
import '../../data/providers/cart_provider.dart';
import '../dashboard/farmer/farmer_dashboard_screen.dart';
import '../dashboard/supplier/supplier_dashboard_screen.dart';
import '../dashboard/customer/customer_dashboard_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    // Default to 'customer' if role is not set
    final role = authProvider.currentUser?.role ?? 'customer';

    // Build lists of screens and bottom bar items based on role
    final List<Widget> screens = [];
    final List<BottomNavigationBarItem> navItems = [];

    if (role == 'customer') {
      screens.addAll([
        const CustomerDashboardScreen(),
        const MarketplaceScreen(),
        const CartScreen(),
        const ProfileScreen(),
      ]);

      navItems.addAll([
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Trang chủ',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          activeIcon: Icon(Icons.search_sharp),
          label: 'Khám phá',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart_outlined),
              if (cartProvider.totalItems > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.accentActive,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '${cartProvider.totalItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          activeIcon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart),
              if (cartProvider.totalItems > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.accentActive,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '${cartProvider.totalItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Giỏ hàng',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ]);
    } else {
      // farmer or supplier
      screens.addAll([
        role == 'farmer'
            ? const FarmerDashboardScreen()
            : const SupplierDashboardScreen(),
        const MarketplaceScreen(),
        _buildOrdersTab(role),
        const ProfileScreen(),
      ]);

      navItems.addAll([
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Tổng quan',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Sản phẩm',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Đơn hàng',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Tài khoản',
        ),
      ]);
    }

    // Guard index out of range if role changes dynamically
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.muted,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: navItems,
      ),
    );
  }

  Widget _buildOrdersTab(String role) {
    final title = role == 'farmer' ? 'Đơn hàng nông sản' : 'Đơn hàng vật tư';

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: AppColors.ink)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: AppColors.surfaceSoft,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Danh sách đơn hàng nhận được',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  _buildOrderCard(
                    'ORD-2201',
                    'Hoàn thành',
                    'Gạo ST25',
                    '100 kg',
                    '2,800,000đ',
                    'Đã giao thành công cho khách hàng',
                  ),
                  _buildOrderCard(
                    'ORD-2202',
                    'Đang giao',
                    'Xoài cát Hòa Lộc',
                    '20 kg',
                    '1,300,000đ',
                    'Đang trên đường vận chuyển',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(
    String code,
    String status,
    String item,
    String qty,
    String total,
    String note,
  ) {
    final statusColor = status == 'Hoàn thành'
        ? AppColors.primary
        : AppColors.accent;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  code,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              item,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Số lượng: $qty | Tổng cộng: $total',
              style: AppTextStyles.caption.copyWith(color: AppColors.body),
            ),
            const SizedBox(height: 8),
            Text(
              note,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.muted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
