import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/order_model.dart';
import '../../data/providers/notification_provider.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/services/payment_service.dart';
import '../../router/app_router.dart';
import '../../widgets/common/agri_button.dart';

class PaymentQrScreen extends StatefulWidget {
  const PaymentQrScreen({super.key, required this.orders});

  final List<OrderModel> orders;

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  bool _isConfirming = false;
  int _currentIndex = 0;

  OrderModel get _order => widget.orders[_currentIndex];

  Map<String, dynamic> get _recipient =>
      _order.paymentRecipient ?? const {};
  String get _bankCode => _recipient['bankCode'] as String? ?? 'VCB';
  String get _accountNumber =>
      _recipient['accountNumber'] as String? ?? '0123456789';
  String get _accountName =>
      _recipient['accountName'] as String? ?? 'AGRILINK DEMO';

  String get _vietQrUrl => Uri.https(
        'img.vietqr.io',
        '/image/$_bankCode-$_accountNumber-compact2.png',
        {
          'amount': _order.totalAmount.toInt().toString(),
          'addInfo': _order.orderCode,
          'accountName': _accountName,
        },
      ).toString();

  /// Demo policy: payment always completes successfully for the user.
  /// Best-effort call to BE `payment-confirm`; API errors are ignored.
  Future<void> _confirmPayment() async {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);
    final orderRepo = context.read<OrderRepository>();
    final notifications = context.read<NotificationProvider>();
    final orderId = _order.id;
    final amount = _order.totalAmount;
    final method = _order.paymentMethod ?? 'bank_transfer';

    try {
      await PaymentService.processPayment(
        orderId: orderId,
        amount: amount,
        method: method,
      );

      try {
        await orderRepo.confirmPayment(orderId);
      } catch (e) {
        // Demo: still proceed so student demos never block on payment gateway/API.
        debugPrint('Demo payment-confirm fallback (ignored): $e');
      }

      if (!mounted) return;
      try {
        await notifications.refresh();
      } catch (_) {}

      if (_currentIndex < widget.orders.length - 1) {
        setState(() {
          _currentIndex++;
          _isConfirming = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Demo: thanh toán đơn này thành công. Tiếp đơn sau.'),
            ),
          );
        }
        return;
      }

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRouter.home,
        (route) => false,
      );
      Navigator.pushNamed(
        context,
        AppRouter.orderSuccess,
        arguments: widget.orders,
      );
    } finally {
      if (mounted) setState(() => _isConfirming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(title: const Text('Chuyển khoản (Demo)')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryUltraLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    PaymentService.getDemoBannerText(),
                    style: AppTextStyles.caption.copyWith(color: AppColors.body),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceDivider),
            ),
            child: Column(children: [
              const Icon(Icons.account_balance_outlined,
                  size: 36, color: AppColors.primary),
              const SizedBox(height: 10),
              Text(
                widget.orders.length > 1
                    ? 'Thanh toán đơn ${_currentIndex + 1}/${widget.orders.length}'
                    : 'Quét mã bằng MoMo hoặc ứng dụng ngân hàng',
                style: AppTextStyles.sectionTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryUltraLight, width: 2),
                ),
                child: Image.network(
                  _vietQrUrl,
                  width: 280,
                  height: 360,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : const SizedBox(
                          width: 280,
                          height: 360,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                  errorBuilder: (_, __, ___) => const SizedBox(
                    width: 280,
                    height: 220,
                    child: Center(
                      child: Text(
                        'Không tải được VietQR. Vui lòng kiểm tra kết nối mạng.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Số tiền', style: AppTextStyles.caption),
              Text('${_formatPrice(_order.totalAmount)} đ',
                  style: AppTextStyles.bigTitle.copyWith(color: AppColors.accentActive, fontSize: 25)),
              const SizedBox(height: 8),
              Text('Mã đơn: ${_order.orderCode}', style: AppTextStyles.subtitle),
              const Divider(height: 28),
              _BankRow(label: 'Ngân hàng', value: _bankCode),
              _BankRow(label: 'Số tài khoản', value: _accountNumber, copyable: true),
              _BankRow(label: 'Chủ tài khoản', value: _accountName),
              _BankRow(label: 'Nội dung', value: _order.orderCode, copyable: true),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warningLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Demo: bạn có thể bỏ qua quét QR thật. Bấm nút bên dưới để '
              'đánh dấu đã thanh toán (luôn thành công).',
              style: AppTextStyles.caption.copyWith(color: AppColors.body),
            ),
          ),
          const SizedBox(height: 20),
          AgriButton(
            text: _currentIndex < widget.orders.length - 1
                ? 'Xác nhận demo — sang đơn tiếp'
                : 'Xác nhận thanh toán demo (thành công)',
            isLoading: _isConfirming,
            onPressed: _isConfirming ? null : _confirmPayment,
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) => price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      );
}

class _BankRow extends StatelessWidget {
  const _BankRow({required this.label, required this.value, this.copyable = false});

  final String label;
  final String value;
  final bool copyable;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        SizedBox(width: 105, child: Text(label, style: AppTextStyles.caption)),
        Expanded(child: Text(value, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w700))),
        if (copyable)
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.copy_rounded, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã sao chép')));
            },
          ),
      ]),
    );
  }
}
