import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/order_model.dart';
import '../../widgets/common/agri_button.dart';
import '../../router/app_router.dart';

class OrderSuccessScreen extends StatefulWidget {
  const OrderSuccessScreen({super.key});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<OrderModel> get _orders {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is List<OrderModel>) return args;
    if (args is OrderModel) return [args];
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final codes = _orders
        .map((o) => o.orderCode)
        .where((c) => c.isNotEmpty)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon tick xanh có animation
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryUltraLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 72,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    Text(
                      'Đặt hàng thành công!',
                      style: AppTextStyles.bigTitle.copyWith(
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    if (codes.isNotEmpty) ...[
                      Text(
                        codes.length == 1
                            ? 'Mã đơn: ${codes.first}'
                            : 'Mã đơn (${codes.length}):\n${codes.join('\n')}',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      'Cảm ơn bạn đã tin tưởng AgriLink.\nĐơn hàng của bạn đang chờ người bán xác nhận.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.muted,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Nút xem đơn hàng
                    AgriButton(
                      text: 'Xem đơn hàng của tôi',
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRouter.home,
                          (route) => false,
                        );
                        Navigator.pushNamed(context, AppRouter.orderHistory);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Nút về trang chủ
                    AgriButton(
                      text: 'Về trang chủ',
                      variant: AgriButtonVariant.outlined,
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRouter.home,
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
