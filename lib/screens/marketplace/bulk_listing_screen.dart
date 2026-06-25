import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../widgets/common/agri_card.dart';

class BulkListingScreen extends StatelessWidget {
  const BulkListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn gom hàng bán buôn'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Các đợt gom hàng HTX',
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 12),
          _buildBulkItem(
            title: 'Gom súp lơ xanh VietGAP vụ Hè',
            coop: 'HTX Nông sản Lâm Đồng',
            progress: 0.75,
            progressText: 'Đã gom: 7.5 / 10 tấn',
            targetPrice: '22,000đ/kg',
            farmingType: 'VietGAP',
          ),
          const SizedBox(height: 12),
          _buildBulkItem(
            title: 'Gom cà rốt hữu cơ xuất khẩu',
            coop: 'HTX Nông nghiệp Đà Lạt',
            progress: 0.40,
            progressText: 'Đã gom: 2 / 5 tấn',
            targetPrice: '28,000đ/kg',
            farmingType: 'Hữu cơ (Organic)',
          ),
        ],
      ),
    );
  }

  Widget _buildBulkItem({
    required String title,
    required String coop,
    required double progress,
    required String progressText,
    required String targetPrice,
    required String farmingType,
  }) {
    return AgriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(coop, style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hình thức: $farmingType',
                style: AppTextStyles.caption.copyWith(color: AppColors.body),
              ),
              Text(
                targetPrice,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.accentActive,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceSoft,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(progressText, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
              Text('${(progress * 100).toInt()}%', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
