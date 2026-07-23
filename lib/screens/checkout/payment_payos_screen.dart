import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/order_model.dart';
import '../../data/providers/notification_provider.dart';
import '../../data/repositories/order_repository.dart';
import '../../router/app_router.dart';

class PaymentPayosScreen extends StatefulWidget {
  const PaymentPayosScreen({super.key, required this.orders});

  final List<OrderModel> orders;

  @override
  State<PaymentPayosScreen> createState() => _PaymentPayosScreenState();
}

class _PaymentPayosScreenState extends State<PaymentPayosScreen> {
  bool _isLoadingLink = false;
  bool _showWebView = false;
  String? _checkoutUrl;
  int _currentIndex = 0;
  Timer? _pollTimer;
  bool _paymentCompleted = false;
  WebViewController? _webViewController;

  OrderModel get _order => widget.orders[_currentIndex];

  @override
  void initState() {
    super.initState();
    _createLink();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _pollStatus();
    });
  }

  Future<void> _pollStatus() async {
    if (_paymentCompleted) return;
    try {
      final repo = context.read<OrderRepository>();
      final status = await repo.getPayosPaymentStatus(_order.id);
      debugPrint('[PayOS poll] orderId=${_order.id} status=$status');
      if (!mounted || _paymentCompleted) return;
      if (status == 'paid') await _onPaymentPaid();
    } catch (e) {
      debugPrint('[PayOS poll] ERROR: $e');
    }
  }

  Future<void> _createLink() async {
    _pollTimer?.cancel();
    setState(() {
      _isLoadingLink = true;
      _checkoutUrl = null;
      _showWebView = false;
    });
    try {
      final repo = context.read<OrderRepository>();
      final result = await repo.createPayosPaymentLink(_order.id);
      if (!mounted) return;
      final url = result['checkoutUrl'] as String?;
      if (url == null) throw Exception('Không lấy được đường dẫn thanh toán');
      setState(() => _checkoutUrl = url);
      _openWebView(url);
      _startPolling();
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

  void _openWebView(String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: (request) {
          final u = request.url;
          debugPrint('[PayOS WebView] nav request: $u');
          // PayOS redirect về returnUrl hoặc cancelUrl — tự đóng WebView
          final isSuccess = u.contains('payment/success') || u.contains('/success?') || u.contains('status=PAID');
          final isCancel = u.contains('payment/cancel') || u.contains('status=cancel');
          if (isSuccess || isCancel) {
            debugPrint('[PayOS WebView] intercept redirect -> close');
            setState(() => _showWebView = false);
            if (isSuccess) _pollStatus();
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageFinished: (_) {
          // Poll ngay khi page load xong đề phòng PayOS redirect nhanh
          _pollStatus();
        },
      ));
    controller.loadRequest(Uri.parse(url));
    setState(() {
      _webViewController = controller;
      _showWebView = true;
    });
  }

  Future<void> _onPaymentPaid() async {
    if (_currentIndex < widget.orders.length - 1) {
      setState(() {
        _currentIndex++;
        _showWebView = false;
      });
      await _createLink();
      return;
    }
    _paymentCompleted = true;
    _pollTimer?.cancel();
    if (!mounted) return;
    await context.read<NotificationProvider>().refresh();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.orderSuccess,
      (route) => route.settings.name == AppRouter.home,
    );
  }

  String _formatPrice(double price) => price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: Text(_showWebView ? 'Thanh toán PayOS' : 'Thanh toán PayOS'),
        leading: _showWebView
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _showWebView = false),
              )
            : null,
      ),
      body: _showWebView && _webViewController != null
          ? WebViewWidget(controller: _webViewController!)
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return ListView(
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _checkoutUrl == null ? null : () => _openWebView(_checkoutUrl!),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Mở trang thanh toán PayOS'),
                ),
              ),
          ]),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(12)),
          child: Text(
            'Sau khi thanh toán, app sẽ tự động kiểm tra và chuyển tiếp. '
            'Vui lòng giữ nguyên màn hình này.',
            style: AppTextStyles.caption.copyWith(color: AppColors.body),
          ),
        ),
        const SizedBox(height: 20),
        if (_pollTimer != null && _pollTimer!.isActive)
          const Center(
            child: Column(
              children: [
                SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
                SizedBox(height: 10),
                Text('Đang tự động kiểm tra thanh toán...', style: TextStyle(color: AppColors.muted, fontSize: 14)),
              ],
            ),
          ),
        TextButton(
          onPressed: _isLoadingLink ? null : _createLink,
          child: const Text('Tạo lại liên kết thanh toán'),
        ),
      ],
    );
  }
}
