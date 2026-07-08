import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/review_model.dart';
import 'package:intl/intl.dart';

class ReviewsSection extends StatelessWidget {
  final List<ReviewModel> reviews;
  final bool isLoading;
  final VoidCallback onAddReview;

  const ReviewsSection({
    super.key,
    required this.reviews,
    required this.isLoading,
    required this.onAddReview,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(24.0),
        child: CircularProgressIndicator(),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Đánh giá (${reviews.length})', style: AppTextStyles.sectionTitle),
            TextButton.icon(
              onPressed: onAddReview,
              icon: const Icon(Icons.edit, size: 16, color: AppColors.primary),
              label: const Text('Viết đánh giá', style: TextStyle(color: AppColors.primary)),
            )
          ],
        ),
        const SizedBox(height: 16),
        if (reviews.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Chưa có đánh giá nào.',
                style: AppTextStyles.body.copyWith(color: AppColors.muted),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: reviews.length,
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return _buildReviewItem(review);
            },
          ),
      ],
    );
  }

  Widget _buildReviewItem(ReviewModel review) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: review.buyerAvatar.isNotEmpty
                  ? NetworkImage(review.buyerAvatar)
                  : null,
              child: review.buyerAvatar.isEmpty
                  ? const Icon(Icons.person, size: 20)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.buyerName, style: AppTextStyles.subtitle),
                  Row(
                    children: [
                      ...List.generate(5, (i) {
                        return Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 14,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('dd/MM/yyyy').format(review.createdAt),
                        style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (review.comment.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(review.comment, style: AppTextStyles.body),
        ],
      ],
    );
  }
}
