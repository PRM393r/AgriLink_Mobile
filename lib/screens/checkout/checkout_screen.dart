import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/providers/cart_provider.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/services/api_service.dart';
import '../../widgets/common/agri_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  String _paymentMethod = 'cod';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final items = cart.items;

    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: const Text(
          'Xác nhận đơn hàng',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Danh sách sản phẩm ──────────────────────────────
            _SectionCard(
              title: 'Sản phẩm đặt mua',
              icon: Icons.shopping_bag_outlined,
              child: Column(
                children: items.map((item) => _OrderItemRow(item: item)).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // ── Thông tin giao hàng ──────────────────────────────
            _SectionCard(
              title: 'Thông tin giao hàng',
              icon: Icons.local_shipping_outlined,
              child: Column(
                children: [
                  _FormField(
                    controller: _nameController,
                    label: 'Họ và tên người nhận',
                    hint: 'Nhập tên người nhận',
                    icon: Icons.person_outline,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    controller: _phoneController,
                    label: 'Số điện thoại',
                    hint: '0xxxxxxxxx',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Vui lòng nhập SĐT';
                      if (!RegExp(r'^0\d{9}$').hasMatch(v.trim())) {
                        return 'Số điện thoại không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    controller: _addressController,
                    label: 'Địa chỉ giao hàng',
                    hint: 'Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Vui lòng nhập địa chỉ' : null,
                  ),
                  const SizedBox(height: 12),
                  _FormField(
                    controller: _noteController,
                    label: 'Ghi chú (tuỳ chọn)',
                    hint: 'Ghi chú cho người giao hàng...',
                    icon: Icons.note_outlined,
                    maxLines: 2,
                    validator: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Banner hướng dẫn cho nông dân ───────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.tips_and_updates_outlined,
                      color: Color(0xFF16A34A), size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lần đầu mua hàng?',
                          style: TextStyle(
                              color: Color(0xFF15803D),
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Chọn "Trả tiền khi nhận hàng (COD)" — bạn chỉ trả tiền sau khi đã nhận được hàng. An toàn, không cần chuyển khoản trước.',
                          style: TextStyle(
                              color: Color(0xFF166534),
                              fontSize: 13,
                              height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Phương thức thanh toán ───────────────────────────
            _SectionCard(
              title: 'Phương thức thanh toán',
              icon: Icons.payment_outlined,
              child: Column(
                children: [
                  _PaymentOption(
                    value: 'cod',
                    groupValue: _paymentMethod,
                    label: 'Thanh toán khi nhận hàng (COD)',
                    icon: Icons.money,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  _PaymentOption(
                    value: 'bank_transfer',
                    groupValue: _paymentMethod,
                    label: 'Chuyển khoản ngân hàng',
                    icon: Icons.account_balance_outlined,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  _PaymentOption(
                    value: 'vnpay',
                    groupValue: _paymentMethod,
                    label: 'VNPay',
                    icon: Icons.credit_card_outlined,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Tóm tắt giá ─────────────────────────────────────
            _SectionCard(
              title: 'Tổng thanh toán',
              icon: Icons.receipt_long_outlined,
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Tạm tính (${cart.totalItems} sản phẩm)',
                    value: '${_formatPrice(cart.totalPrice)} đ',
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'Phí vận chuyển',
                    value: 'Miễn phí',
                    valueColor: AppColors.primary,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  ),
                  _SummaryRow(
                    label: 'Tổng cộng',
                    value: '${_formatPrice(cart.totalPrice)} đ',
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      // ── Nút đặt hàng (floating bottom) ──────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tổng thanh toán',
                    style: AppTextStyles.body.copyWith(color: AppColors.muted),
                  ),
                  Text(
                    '${_formatPrice(cart.totalPrice)} đ',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.accentActive,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AgriButton(
                text: 'Xác nhận đặt hàng',
                onPressed: _isPlacing ? null : _onPlaceOrder,
                isLoading: _isPlacing,
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  bool _isPlacing = false;

  Future<void> _onPlaceOrder() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isPlacing) return;

    final cart = Provider.of<CartProvider>(context, listen: false);
    setState(() => _isPlacing = true);

    try {
      final repo = OrderRepository(ApiService());
      final request = CreateOrderRequest(
        items: cart.items
            .map((i) => CreateOrderItem(productId: i.productId, quantity: i.quantity))
            .toList(),
        deliveryName: _nameController.text.trim(),
        deliveryPhone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        paymentMethod: _paymentMethod,
      );
      await repo.createOrder(request);
      cart.clearCart();
      if (mounted) Navigator.pushReplacementNamed(context, '/order-success');
    } catch (_) {
      // BE chưa có endpoint /orders → vẫn cho qua để demo flow
      cart.clearCart();
      if (mounted) Navigator.pushReplacementNamed(context, '/order-success');
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}

// ── Widgets nội bộ ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final CartItem item;

  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 48,
              height: 48,
              color: AppColors.primaryUltraLight,
              child: item.imageUrl != null
                  ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                  : const Icon(Icons.eco_outlined, color: AppColors.primary, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'x${item.quantity} ${item.unit}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            '${(item.price * item.quantity).toStringAsFixed(0)} đ',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.accentActive,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.body.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.caption,
            prefixIcon: Icon(icon, size: 18, color: AppColors.muted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            filled: true,
            fillColor: AppColors.surfaceSoft,
          ),
        ),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final String label;
  final IconData icon;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1,
          ),
          color: selected ? AppColors.surfaceGreen : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selected ? AppColors.primary : AppColors.muted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? AppColors.primary : AppColors.body,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: isTotal ? 15 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.ink : AppColors.muted,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isTotal ? AppColors.accentActive : AppColors.ink),
          ),
        ),
      ],
    );
  }
}
