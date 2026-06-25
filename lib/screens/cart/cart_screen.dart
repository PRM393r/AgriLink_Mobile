import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
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
      appBar: AppBar(
        title: const Text(
          'Giỏ hàng của tôi',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Giỏ hàng của bạn đang trống',
              message: 'Hãy lướt xem các sản phẩm nông sản tươi sạch của chúng tôi và chọn mua nhé!',
              actionLabel: 'Mua sắm ngay',
              onActionPressed: () {
                Navigator.pushNamed(context, AppRouter.marketplace);
              },
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  color: AppColors.primaryUltraLight,
                                  child: item.imageUrl != null
                                      ? Image.network(
                                          item.imageUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.eco_outlined,
                                          color: AppColors.primary,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Product Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.ink,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.price.toStringAsFixed(0)}đ / ${item.unit}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity controller
                              Row(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.muted),
                                    onPressed: () {
                                      cartProvider.updateQuantity(
                                        item.productId,
                                        item.quantity - 1,
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Text(
                                      '${item.quantity}',
                                      style: AppTextStyles.body.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                                    onPressed: () {
                                      cartProvider.updateQuantity(
                                        item.productId,
                                        item.quantity + 1,
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              // Delete button
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                onPressed: () {
                                  cartProvider.removeItem(item.productId);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Bottom Total and checkout
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 8,
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng cộng:',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.muted,
                              ),
                            ),
                            Text(
                              '${cartProvider.totalPrice.toStringAsFixed(0)} đ',
                              style: AppTextStyles.sectionTitle.copyWith(
                                color: AppColors.accentActive,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AgriButton(
                          text: 'Đặt hàng',
                          onPressed: () {
                            // Place order mock
                            cartProvider.clearCart();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đặt hàng thành công! Đơn hàng đang được chờ xử lý.'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                            Navigator.pop(context);
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
}
