import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ReviewsSection extends StatelessWidget {
  final String productId;
  
  const ReviewsSection({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    // ponytail: simple mock reviews for MVP, since backend doesn't have it yet.
    // Avoids over-engineering a full review submission system when orders aren't even ready.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Đánh giá (2)', style: AppTextStyles.sectionTitle),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tính năng đánh giá sẽ mở sau khi mua hàng')),
                );
              },
              child: const Text('Viết đánh giá', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildReviewItem(
          name: 'Nguyễn Văn A',
          rating: 5,
          comment: 'Sản phẩm rất tươi, giao hàng nhanh. Sẽ ủng hộ shop dài dài.',
          date: '02/07/2026',
        ),
        const Divider(),
        _buildReviewItem(
          name: 'Trần Thị B',
          rating: 4,
          comment: 'Chất lượng ok, đóng gói cẩn thận. Giá hơi cao một chút.',
          date: '28/06/2026',
        ),
      ],
    );
  }

  Widget _buildReviewItem({
    required String name,
    required int rating,
    required String comment,
    required String date,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
              Text(date, style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                size: 16,
                color: Colors.amber,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(comment, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
