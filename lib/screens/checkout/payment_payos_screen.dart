import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/order_model.dart';
import '../../data/providers/notification_provider.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/services/api_service.dart';
import '../../router/app_router.dart';
import '../../widgets/common/agri_button.dart';

class PaymentPayosScreen extends StatefulWidget {
  const PaymentPayosScreen({super.key, required this.orders});

  final List<OrderModel> orders;

  @override
  State<PaymentPayosScreen> createState() => _PaymentPayosScreenState();
}

class _PaymentPayosScreenState extends State<PaymentPayosScreen> {
  final _repo = OrderRepository(ApiService());

  bool _isLoadingLink = false;
  bool _isCheckingStatus = false;
  String? _checkoutUrl;
  int _currentIndex = 0;

  OrderModel get _order => widget.orders[_currentIndex];

  @override
  void initState() {
    super.initState();
    _createLink();
  }

  Future<void> _createLink() async {
    setState(() {
      _isLoadingLink = true;
      _checkoutUrl = null;
    });
    try {
      final result = await _repo.createPayosPaymentLink(_order.id);
      if (!mounted) return;
      setState(() => _checkoutUrl = result['checkoutUrl'] as String?);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception:', '').trim()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingLink = false);
    }
  }

  Future<void> _openCheckout() async {
    final url = _checkoutUrl;
    if (url == null) return;
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không mở được trang thanh toán. Vui lòng thử lại.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _checkStatus() async {
    if (_isCheckingStatus) return;
    setState(() => _isCheckingStatus = true);
    try {
      final status = await _repo.getPayosPaymentStatus(_order.id);
      if (!mounted) return;
      if (status == 'paid') {
        await context.read<NotificationProvider>().refresh();
        if (!mounted) return;
        if (_currentIndex < widget.orders.length - 1) {
          setState(() => _currentIndex++);
          await _createLink();
          return;
        }
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRouter.orderSuccess,
            (route) => route.settings.name == AppRouter.home,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa ghi nhận thanh toán. Vui lòng hoàn tất trên trang PayOS rồi thử lại.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception:', '').trim()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCheckingStatus = false);
    }
  }

  String _formatPrice(double price) => price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(title: const Text('Thanh toán PayOS')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.surfaceDivider),
            ),
            child: Column(children: [
              const Icon(Icons.qr_code_2_outlined, size: 36, color: AppColors.primary),
              const SizedBox(height: 10),
              Text(
                widget.orders.length > 1
                    ? 'Thanh toán đơn ${_currentIndex + 1}/${widget.orders.length}'
                    : 'Thanh toán an toàn qua PayOS',
                style: AppTextStyles.sectionTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Text('Số tiền', style: AppTextStyles.caption),
              Text('${_formatPrice(_order.totalAmount)} đ',
                  style: AppTextStyles.bigTitle.copyWith(color: AppColors.accentActive, fontSize: 25)),
              const SizedBox(height: 8),
              Text('Mã đơn: ${_order.orderCode}', style: AppTextStyles.subtitle),
              const SizedBox(height: 20),
              if (_isLoadingLink)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                )
              else
                AgriButton(
                  text: 'Mở trang thanh toán PayOS',
                  onPressed: _checkoutUrl == null ? null : _openCheckout,
                ),
            ]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(12)),
            child: Text(
              'Hoàn tất thanh toán trên trang PayOS vừa mở, sau đó quay lại đây và bấm "Tôi đã thanh toán xong" để hệ thống kiểm tra.',
              style: AppTextStyles.caption.copyWith(color: AppColors.body),
            ),
          ),
          const SizedBox(height: 20),
          AgriButton(
            text: 'Tôi đã thanh toán xong',
            isLoading: _isCheckingStatus,
            onPressed: _isCheckingStatus || _checkoutUrl == null ? null : _checkStatus,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: _isLoadingLink ? null : _createLink,
            child: const Text('Tạo lại liên kết thanh toán'),
          ),
        ],
      ),
    );
  }
}
