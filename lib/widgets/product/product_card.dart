import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/product_model.dart';
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

    return AgriCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image or placeholder
          AspectRatio(
            aspectRatio: 1.3,
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
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Farming Type Badges
                Row(
                  children: [
                    ProductBadge(label: product.category),
                    const SizedBox(width: 4),
                    ProductBadge(
                      label: product.farmingType,
                      backgroundColor: AppColors.surfaceGreen,
                      textColor: AppColors.primaryActive,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Product Name
                Text(
                  product.name,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Seller info
                Row(
                  children: [
                    const Icon(Icons.storefront, size: 14, color: AppColors.muted),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'ID: ${product.sellerId.substring(0, product.sellerId.length > 8 ? 8 : product.sellerId.length)}...',
                        style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Price and Unit
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${product.pricePerUnit.toStringAsFixed(0)}đ',
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentActive,
                        ),
                      ),
                    ),
                    Text(
                      '/${product.unit}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.body),
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
