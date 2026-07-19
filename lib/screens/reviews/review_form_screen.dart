import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/services/review_service.dart';
import '../../widgets/common/agri_button.dart';
import '../../widgets/common/agri_text_field.dart';

class ReviewFormScreen extends StatefulWidget {
  const ReviewFormScreen({super.key});

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _commentController = TextEditingController();
  double _rating = 5.0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview(String productId, String orderId) async {
    if (productId.isEmpty || orderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Thiếu thông tin đơn hàng. Chỉ đánh giá sau khi đã nhận hàng.',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final service = context.read<ReviewService>();
      await service.submitReview(
        productId: productId,
        orderId: orderId,
        rating: _rating,
        comment: _commentController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context, true); // true = success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đánh giá thành công!')),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              msg.isEmpty
                  ? 'Không gửi được đánh giá. Cần đã mua và nhận hàng.'
                  : msg,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nhận data từ ModalRoute arguments (yêu cầu Map có productId, orderId)
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final productId = args?['productId'] as String? ?? '';
    final orderId = args?['orderId'] as String? ?? '';
    final productName = args?['productName'] as String? ?? 'Sản phẩm';
    final canReview = productId.isNotEmpty && orderId.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.surfaceElevated,
      appBar: AppBar(
        title: Text('Đánh giá sản phẩm', style: AppTextStyles.sectionTitle),
        centerTitle: true,
        backgroundColor: AppColors.canvas,
        elevation: 0,
      ),
      body: !canReview
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Bạn chỉ có thể đánh giá sau khi đơn hàng đã giao thành công.\n'
                  'Mở chi tiết đơn (trạng thái Hoàn thành) để viết đánh giá.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.muted),
                ),
              ),
            )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              productName,
              style: AppTextStyles.subtitle.copyWith(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text('Chất lượng sản phẩm', style: AppTextStyles.body),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 32),
            AgriTextField(
              labelText: 'Chia sẻ nhận xét của bạn',
              hintText: 'Sản phẩm có tươi ngon không? Đóng gói thế nào?',
              controller: _commentController,
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            AgriButton(
              text: 'Gửi đánh giá',
              onPressed: _isSubmitting ? null : () => _submitReview(productId, orderId),
              isLoading: _isSubmitting,
            ),
          ],
        ),
      ),
    );
  }
}
