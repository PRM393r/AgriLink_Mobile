import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_shadows.dart';
import '../../data/providers/cart_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/agri_button.dart';
import '../../router/app_router.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final items = cartProvider.items;

    return Scaffold(
      backgroundColor: AppColors.surfaceElevated,
      appBar: AppBar(
        title: Text('Giỏ hàng', style: AppTextStyles.sectionTitle),
        backgroundColor: AppColors.canvas,
        elevation: 0,
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => cartProvider.clearCart(),
              child: Text('Xoá tất cả',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.error)),
            ),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Giỏ hàng trống',
              message: 'Hãy khám phá nông sản tươi sạch!',
              actionLabel: 'Mua sắm ngay',
              onActionPressed: () =>
                  Navigator.pushNamed(context, AppRouter.marketplace),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Dismissible(
                        key: Key(item.productId),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.errorLight,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.error),
                        ),
                        onDismissed: (_) =>
                            cartProvider.removeItem(item.productId),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.surfaceDivider
                                    .withValues(alpha: 0.3)),
                            boxShadow: AppShadows.card,
                          ),
                          child: Row(
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primaryUltraLight,
                                        AppColors.primaryLight
                                            .withValues(alpha: 0.15),
                                      ],
                                    ),
                                  ),
                                  child: item.imageUrl != null
                                      ? Image.network(item.imageUrl!,
                                          fit: BoxFit.cover)
                                      : const Center(
                                          child: Text('🌿',
                                              style:
                                                  TextStyle(fontSize: 24))),
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: AppTextStyles.subtitle.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.ink),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_fmt(item.price)}đ / ${item.unit}',
                                      style: AppTextStyles.caption.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              // Qty stepper
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceSoft,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    _stepperBtn(Icons.remove, () {
                                      cartProvider.updateQuantity(
                                          item.productId,
                                          item.quantity - 1);
                                    }),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text('${item.quantity}',
                                          style: AppTextStyles.subtitle
                                              .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.ink)),
                                    ),
                                    _stepperBtn(Icons.add, () {
                                      cartProvider.updateQuantity(
                                          item.productId,
                                          item.quantity + 1);
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Bottom
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    boxShadow: AppShadows.bottomBar,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20)),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tạm tính (${cartProvider.totalItems} SP)',
                                style: AppTextStyles.subtitle
                                    .copyWith(color: AppColors.muted)),
                            Text('${_fmt(cartProvider.totalPrice)}đ',
                                style: AppTextStyles.sectionTitle.copyWith(
                                    color: AppColors.accentActive,
                                    fontSize: 20)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AgriButton.gradient(
                          text: 'Tiến hành đặt hàng',
                          icon: Icons.shopping_bag_rounded,
                          onPressed: () {
                            Navigator.pushNamed(context, AppRouter.checkout);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _stepperBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
      ),
    );
  }

  String _fmt(double p) {
    final s = p.toStringAsFixed(0);
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}
