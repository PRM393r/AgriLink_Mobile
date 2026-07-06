import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_shadows.dart';
import '../../data/services/auth_provider.dart';
import '../../data/providers/cart_provider.dart';
import '../dashboard/farmer/farmer_dashboard_screen.dart';
import '../dashboard/supplier/supplier_dashboard_screen.dart';
import '../dashboard/customer/customer_dashboard_screen.dart';
import '../marketplace/marketplace_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/order_history_screen.dart';
import '../orders/seller_order_screen.dart';
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

    // Build lists of screens and nav items based on role
    final List<Widget> screens = [];
    final List<_NavItem> navItems = [];

    if (role == 'customer') {
      screens.addAll([
        const CustomerDashboardScreen(),
        const MarketplaceScreen(),
        const CartScreen(),
        const OrderHistoryScreen(),
        const ProfileScreen(),
      ]);

      navItems.addAll([
        const _NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: 'Trang chủ',
        ),
        const _NavItem(
          icon: Icons.search_rounded,
          activeIcon: Icons.search_rounded,
          label: 'Khám phá',
        ),
        _NavItem(
          icon: Icons.shopping_cart_outlined,
          activeIcon: Icons.shopping_cart_rounded,
          label: 'Giỏ hàng',
          badgeCount: cartProvider.totalItems,
        ),
        const _NavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long_rounded,
          label: 'Đơn hàng',
        ),
        const _NavItem(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
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
        const SellerOrderScreen(),
        const ProfileScreen(),
      ]);

      navItems.addAll([
        const _NavItem(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard_rounded,
          label: 'Tổng quan',
        ),
        const _NavItem(
          icon: Icons.inventory_2_outlined,
          activeIcon: Icons.inventory_2_rounded,
          label: 'Sản phẩm',
        ),
        const _NavItem(
          icon: Icons.receipt_long_outlined,
          activeIcon: Icons.receipt_long_rounded,
          label: 'Đơn hàng',
        ),
        const _NavItem(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: 'Tài khoản',
        ),
      ]);
    }

    // Guard index out of range
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: _buildCustomBottomNav(navItems),
    );
  }

  Widget _buildCustomBottomNav(List<_NavItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        boxShadow: AppShadows.bottomBar,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = _currentIndex == index;

              return _buildNavItem(item, isActive, () {
                setState(() => _currentIndex = index);
              });
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? item.activeIcon : item.icon,
                    key: ValueKey(isActive),
                    size: 24,
                    color: isActive ? AppColors.primary : AppColors.muted,
                  ),
                ),
                // Badge
                if (item.badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.accentActive,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${item.badgeCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            // Label only when active
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                item.label,
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount = 0,
  });
}
