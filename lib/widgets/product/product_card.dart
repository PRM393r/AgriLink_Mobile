import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_shadows.dart';
import '../../data/models/product_model.dart';
import '../../data/services/auth_provider.dart';
import '../../data/providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  /// Get category emoji based on product category
  String _getCategoryEmoji() {
    switch (product.category.toLowerCase()) {
      case 'rau củ':
        return '🥬';
      case 'trái cây':
        return '🍊';
      case 'lúa gạo':
        return '🌾';
      case 'thủy sản':
        return '🐟';
      case 'vật tư':
        return '🌱';
      default:
        return '🌿';
    }
  }

  /// Get gradient colors based on category
  List<Color> _getCategoryGradient() {
    switch (product.category.toLowerCase()) {
      case 'rau củ':
        return const [Color(0xFF2D6A4F), Color(0xFF52B788)];
      case 'trái cây':
        return const [Color(0xFFF4A261), Color(0xFFFFB703)];
      case 'lúa gạo':
        return const [Color(0xFFD4A373), Color(0xFFFAEDCD)];
      case 'thủy sản':
        return const [Color(0xFF3B82F6), Color(0xFF60A5FA)];
      default:
        return const [Color(0xFF40916C), Color(0xFF95D5B2)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = product.images.isNotEmpty;
    final authProvider = Provider.of<AuthProvider>(context);
    final isCustomer =
        (authProvider.currentUser?.role ?? 'customer') == 'customer';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.surfaceDivider.withValues(alpha: 0.25),
          ),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image or premium placeholder
            AspectRatio(
              aspectRatio: 1.3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    hasImage
                        ? Image.network(
                            product.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildPremiumPlaceholder(),
                          )
                        : _buildPremiumPlaceholder(),
                    // Certification badge overlay (top-left)
                    if (product.certifications.isNotEmpty)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.canvas.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified,
                                  size: 12, color: AppColors.primary),
                              const SizedBox(width: 3),
                              Text(
                                product.certifications.first,
                                style: AppTextStyles.badge
                                    .copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (isCustomer)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.favorite_border, size: 20, color: AppColors.error),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã thêm vào yêu thích!'), duration: Duration(seconds: 1)),
                              );
                            },
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.category,
                        style: AppTextStyles.badge
                            .copyWith(color: AppColors.muted),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Product Name
                    Text(
                      product.name,
                      style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Price row with cart button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_formatPrice(product.pricePerUnit)}đ',
                                style: AppTextStyles.price.copyWith(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                '/${product.unit}',
                                style: AppTextStyles.badge.copyWith(
                                  color: AppColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCustomer)
                          _buildCartButton(context),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartButton(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () {
          Provider.of<CartProvider>(context, listen: false)
              .addItem(product, 1);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.canvas, size: 18),
                  const SizedBox(width: 8),
                  Text('Đã thêm ${product.name}'),
                ],
              ),
              duration: const Duration(seconds: 1),
              backgroundColor: AppColors.primary,
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(
            Icons.add_shopping_cart_rounded,
            color: AppColors.canvas,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumPlaceholder() {
    final gradient = _getCategoryGradient();
    final emoji = _getCategoryEmoji();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradient[0].withValues(alpha: 0.15),
            gradient[1].withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(
              product.farmingType,
              style: AppTextStyles.badge.copyWith(
                color: gradient[0].withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      final formatted = price.toStringAsFixed(0);
      final buffer = StringBuffer();
      for (int i = 0; i < formatted.length; i++) {
        if (i > 0 && (formatted.length - i) % 3 == 0) {
          buffer.write(',');
        }
        buffer.write(formatted[i]);
      }
      return buffer.toString();
    }
    return price.toStringAsFixed(0);
  }
}
