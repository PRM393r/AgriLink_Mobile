import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../widgets/common/agri_button.dart';
import '../../../widgets/product/product_badge.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder
            Container(
              height: 250,
              width: double.infinity,
              color: AppColors.primaryUltraLight,
              child: const Center(
                child: Icon(Icons.eco, size: 80, color: AppColors.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  const Row(
                    children: [
                      ProductBadge(label: 'Trái cây'),
                      SizedBox(width: 8),
                      ProductBadge(
                        label: 'VietGAP',
                        backgroundColor: AppColors.surfaceGreen,
                        textColor: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    'Dâu tây thủy canh Đà Lạt',
                    style: AppTextStyles.bigTitle.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  // Price
                  Text(
                    '180,000đ/kg',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.accentActive,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Description Section
                  Text('Mô tả sản phẩm', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 8),
                  Text(
                    'Dâu tây thủy canh công nghệ cao từ vườn Đà Lạt. Quả to đều, chín đỏ mọng, vị ngọt thanh tự nhiên xen lẫn vị chua nhẹ đặc trưng. Đảm bảo quy trình VietGAP an toàn tuyệt đối cho người tiêu dùng.',
                    style: AppTextStyles.body,
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Seller Info
                  Text('Thông tin nhà vườn', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        radius: 20,
                        child: const Icon(Icons.storefront, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('HTX Nông nghiệp sạch Đà Lạt', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
                          Text('Đức Trọng, Lâm Đồng', style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  // CTA button
                  AgriButton(
                    text: 'Liên hệ mua hàng',
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
