import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/services/auth_provider.dart';
import '../../router/app_router.dart';
import '../../widgets/common/agri_button.dart';

// Hiển thị khi farmer/supplier mới chọn role, chưa được admin duyệt (hoặc bị từ chối).
// Chặn không cho vào Home cho tới khi sellerApprovalStatus == 'approved'.
class SellerPendingScreen extends StatelessWidget {
  const SellerPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final isRejected = user?.isSellerRejected ?? false;

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isRejected ? Icons.cancel_outlined : Icons.hourglass_top_rounded,
                size: 72,
                color: isRejected ? AppColors.error : AppColors.primary,
              ),
              const SizedBox(height: 20),
              Text(
                isRejected ? 'Tài khoản bán hàng bị từ chối' : 'Tài khoản đang chờ duyệt',
                style: AppTextStyles.sectionTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                isRejected
                    ? 'Yêu cầu bán hàng của bạn chưa được chấp thuận. Vui lòng liên hệ bộ phận hỗ trợ để biết thêm chi tiết.'
                    : 'Admin đang xem xét tài khoản của bạn. Bạn sẽ nhận được thông báo ngay khi được duyệt và có thể bắt đầu đăng bán sản phẩm.',
                style: AppTextStyles.body.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              AgriButton(
                text: 'Đăng xuất',
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
