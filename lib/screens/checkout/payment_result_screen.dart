import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../router/app_router.dart';
import '../../widgets/common/agri_button.dart';

// Màn hiển thị khi PayOS đưa buyer quay lại app qua deep link agrilink://payment-result.
// Chỉ mang tính thông báo — trạng thái thanh toán thật lấy từ backend qua webhook/polling,
// không tin cậy trực tiếp vào query param 'status' của deep link này.
class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({super.key, required this.status});

  final String status;

  // PayOS trả status='PAID' khi thành công, 'CANCELLED' khi hủy — không phải 'success'/'cancel'.
  bool get _isSuccess => status.toUpperCase() == 'PAID';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isSuccess ? Icons.check_circle_outline : Icons.info_outline,
                size: 72,
                color: _isSuccess ? AppColors.primary : AppColors.muted,
              ),
              const SizedBox(height: 20),
              Text(
                _isSuccess ? 'Đã quay lại từ PayOS' : 'Thanh toán chưa hoàn tất',
                style: AppTextStyles.sectionTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Vui lòng bấm "Tôi đã thanh toán xong" trên màn thanh toán để hệ thống xác nhận chính xác.',
                style: AppTextStyles.body.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              AgriButton(
                text: 'Về trang chủ',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.home,
                  (route) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
