import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/services/api_service.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderModel? _order;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is OrderModel) {
      _order = arg;
      _isLoading = false;
    } else if (arg is String) {
      _loadOrder(arg);
    }
  }

  Future<void> _loadOrder(String id) async {
    try {
      final order = await OrderRepository(ApiService()).getOrderById(id);
      if (mounted) setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: Text(
          _order != null ? '#${_order!.orderCode}' : 'Chi tiết đơn hàng',
          style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _order == null
              ? const Center(child: Text('Không tìm thấy đơn hàng'))
              : _buildContent(_order!),
    );
  }

  Widget _buildContent(OrderModel order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status timeline
          _buildStatusTimeline(order),
          const SizedBox(height: 12),

          // Sản phẩm
          _SectionCard(
            title: 'Sản phẩm đặt mua',
            icon: Icons.shopping_bag_outlined,
            child: Column(
              children: order.items
                  .map((item) => _ItemRow(item: item))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),

          // Địa chỉ giao hàng
          if (order.shippingAddressSnapshot != null)
            _SectionCard(
              title: 'Địa chỉ giao hàng',
              icon: Icons.location_on_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(
                    label: 'Người nhận',
                    value: order.shippingAddressSnapshot!['recipientName'] as String? ?? '—',
                  ),
                  _InfoRow(
                    label: 'Điện thoại',
                    value: order.shippingAddressSnapshot!['phone'] as String? ?? '—',
                  ),
                  _InfoRow(
                    label: 'Địa chỉ',
                    value: order.shippingAddressSnapshot!['address'] as String? ?? '—',
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),

          // Thanh toán
          _SectionCard(
            title: 'Thanh toán',
            icon: Icons.payment_outlined,
            child: Column(
              children: [
                _InfoRow(label: 'Phương thức', value: _paymentLabel(order.paymentMethod)),
                _InfoRow(label: 'Trạng thái TT', value: _paymentStatusLabel(order.paymentStatus)),
                const Divider(height: 20),
                _InfoRow(label: 'Tạm tính', value: '${_fmt(order.subtotal)} đ'),
                _InfoRow(label: 'Phí vận chuyển', value: order.shippingFee == 0 ? 'Miễn phí' : '${_fmt(order.shippingFee)} đ'),
                const Divider(height: 8),
                _InfoRow(
                  label: 'Tổng cộng',
                  value: '${_fmt(order.totalAmount)} đ',
                  isBold: true,
                  valueColor: AppColors.accentActive,
                ),
              ],
            ),
          ),
          if (order.note != null && order.note!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Ghi chú',
              icon: Icons.note_outlined,
              child: Text(order.note!, style: AppTextStyles.body.copyWith(fontSize: 14)),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(OrderModel order) {
    final steps = [
      {'key': 'pending', 'label': 'Đặt hàng'},
      {'key': 'confirmed', 'label': 'Xác nhận'},
      {'key': 'shipping', 'label': 'Đang giao'},
      {'key': 'delivered', 'label': 'Hoàn thành'},
    ];

    final currentIdx = _statusIndex(order.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final lineIdx = i ~/ 2;
            return Expanded(
              child: Container(
                height: 2,
                color: lineIdx < currentIdx ? AppColors.primary : AppColors.primaryUltraLight,
              ),
            );
          }
          final stepIdx = i ~/ 2;
          final done = stepIdx <= currentIdx;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? AppColors.primary : AppColors.primaryUltraLight,
                ),
                child: Icon(
                  done ? Icons.check : Icons.circle,
                  size: done ? 16 : 8,
                  color: done ? Colors.white : AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIdx]['label']!,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: done ? FontWeight.bold : FontWeight.normal,
                  color: done ? AppColors.primary : AppColors.muted,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  int _statusIndex(String status) {
    switch (status) {
      case 'confirmed': case 'preparing': return 1;
      case 'handed_to_logistics': case 'shipping': return 2;
      case 'delivered': return 3;
      default: return 0;
    }
  }

  String _paymentLabel(String? method) {
    switch (method) {
      case 'cod': return 'Tiền mặt khi nhận hàng';
      case 'bank_transfer': return 'Chuyển khoản ngân hàng';
      case 'vnpay': case 'payos': return 'VNPay';
      default: return method ?? '—';
    }
  }

  String _paymentStatusLabel(String status) {
    switch (status) {
      case 'paid': return 'Đã thanh toán';
      case 'unpaid': return 'Chưa thanh toán';
      case 'refunded': return 'Đã hoàn tiền';
      default: return status;
    }
  }

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final OrderItemModel item;
  const _ItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 44,
            height: 44,
            color: AppColors.primaryUltraLight,
            child: item.productImageUrl != null
                ? Image.network(item.productImageUrl!, fit: BoxFit.cover)
                : const Icon(Icons.eco_outlined, color: AppColors.primary, size: 22),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.productName,
                style: AppTextStyles.caption.copyWith(color: AppColors.ink, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text('x${item.quantity.toInt()} ${item.productUnit}',
                style: AppTextStyles.caption),
          ]),
        ),
        Text('${item.totalPrice.toStringAsFixed(0)} đ',
            style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.bold, color: AppColors.accentActive)),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  const _InfoRow({required this.label, required this.value, this.isBold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.caption.copyWith(
                color: valueColor ?? AppColors.ink,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                fontSize: isBold ? 14 : 13,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
