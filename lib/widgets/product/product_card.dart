import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/product_model.dart';
import '../../data/services/auth_provider.dart';
import '../../data/providers/cart_provider.dart';
import '../common/agri_card.dart';
import 'product_badge.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = product.images.isNotEmpty;
    final authProvider = Provider.of<AuthProvider>(context);
    final isCustomer = (authProvider.currentUser?.role ?? 'customer') == 'customer';

    return AgriCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Product Image or placeholder
          AspectRatio(
            aspectRatio: 1.4,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: hasImage
                  ? Image.network(
                      product.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badges — Wrap để không overflow khi text dài
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    ProductBadge(label: product.category),
                    ProductBadge(
                      label: product.farmingType,
                      backgroundColor: AppColors.surfaceGreen,
                      textColor: AppColors.primaryActive,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Product Name
                Text(
                  product.name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Price + cart button trên cùng 1 hàng
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${product.pricePerUnit.toStringAsFixed(0)}đ',
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentActive,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '/${product.unit}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCustomer)
                      GestureDetector(
                        onTap: () {
                          Provider.of<CartProvider>(context, listen: false).addItem(product, 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã thêm ${product.name} vào giỏ hàng!'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.primaryUltraLight,
      child: Center(
        child: Icon(
          Icons.eco_outlined,
          size: 40,
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

