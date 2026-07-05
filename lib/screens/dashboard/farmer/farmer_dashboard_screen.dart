import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_provider.dart';
import '../../../widgets/common/agri_card.dart';
import '../../../widgets/common/agri_button.dart';
import 'add_product_screen.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  late final ProductRepository _productRepo;
  late final OrderRepository _orderRepo;

  List<ProductModel> _products = [];
  List<OrderModel> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _productRepo = ProductRepository(ApiService());
    _orderRepo = OrderRepository(ApiService());
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _productRepo.getProducts(sortBy: 'createdAt', order: 'desc', limit: 10),
        _orderRepo.getSellerOrders(status: 'pending'),
      ]);
      setState(() {
        _products = results[0] as List<ProductModel>;
        _orders = results[1] as List<OrderModel>;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateOrderStatus(OrderModel order) async {
    final statuses = [
      {'value': 'confirmed', 'label': 'Xác nhận'},
      {'value': 'preparing', 'label': 'Đang chuẩn bị'},
      {'value': 'shipping', 'label': 'Đang giao'},
      {'value': 'delivered', 'label': 'Hoàn thành'},
      {'value': 'cancelled', 'label': 'Hủy đơn'},
    ];

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật trạng thái đơn hàng'),
        content: const Text('Chọn trạng thái mới:'),
        actions: statuses.map((s) {
          return TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _orderRepo.updateOrderStatus(order.id, s['value']!);
                _load();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: Text(
              s['label']!,
              style: TextStyle(
                color: s['value'] == 'cancelled' ? AppColors.error : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan Nông dân'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.ink),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primary,
              child: Container(
                color: AppColors.surfaceSoft,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AppStrings.welcome},',
                                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                              ),
                              Text(
                                user?.fullName ?? user?.email ?? 'Nông dân',
                                style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
                              ),
                            ],
                          ),
                          const CircleAvatar(
                            backgroundColor: AppColors.primaryUltraLight,
                            radius: 24,
                            child: Icon(Icons.person, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Stats
                      Text('Thống kê tổng quan',
                          style: AppTextStyles.sectionTitle.copyWith(fontSize: 16)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                                'Sản phẩm', '${_products.length}', AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                                'Đơn chờ', '${_orders.length}', AppColors.accent),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard('Đang bán',
                                '${_products.where((p) => p.status == 'active').length}',
                                AppColors.harvest),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // My products
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Sản phẩm của tôi', style: AppTextStyles.sectionTitle),
                          TextButton(
                            onPressed: _load,
                            child: Text('Làm mới',
                                style: TextStyle(
                                    color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      _products.isEmpty
                          ? AgriCard(
                              child: const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text('Chưa có sản phẩm nào',
                                      style: TextStyle(color: AppColors.muted)),
                                ),
                              ),
                            )
                          : AgriCard(
                              child: Column(
                                children: _products.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final p = entry.value;
                                  return Column(
                                    children: [
                                      _buildProductRow(
                                        p.name,
                                        '${_formatPrice(p.pricePerUnit)}đ/${p.unit}',
                                        'Còn: ${p.availableQuantity.toStringAsFixed(0)} ${p.unit}',
                                      ),
                                      if (i < _products.length - 1) const Divider(),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                      const SizedBox(height: 16),

                      AgriButton(
                        text: 'Đăng bán nông sản mới',
                        onPressed: () async {
                          final added = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(builder: (_) => const AddProductScreen()),
                          );
                          if (added == true) _load();
                        },
                      ),
                      const SizedBox(height: 24),

                      // Pending orders
                      Text('Đơn hàng đang chờ xử lý', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 12),

                      if (_orders.isEmpty)
                        AgriCard(
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Không có đơn hàng nào đang chờ',
                                  style: TextStyle(color: AppColors.muted)),
                            ),
                          ),
                        )
                      else
                        ..._orders.map((order) {
                          final statusColor = _statusColor(order.status);
                          return AgriCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            onTap: () => _updateOrderStatus(order),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            order.orderCode,
                                            style: AppTextStyles.body
                                                .copyWith(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          _StatusChip(
                                              label: order.statusLabel, color: statusColor),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      if (order.items.isNotEmpty)
                                        Text(
                                          order.items.first.productSnapshot['name'] ?? '',
                                          style: AppTextStyles.body.copyWith(color: AppColors.ink),
                                        ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${order.items.length} sản phẩm',
                                        style: AppTextStyles.caption
                                            .copyWith(color: AppColors.muted),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${_formatPrice(order.totalAmount)}đ',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.accentActive,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.accent;
      case 'confirmed': return AppColors.primaryLight;
      case 'shipping': return const Color(0xFF2563EB);
      case 'delivered': return AppColors.primary;
      case 'cancelled': return AppColors.error;
      default: return AppColors.muted;
    }
  }

  String _formatPrice(double price) => price
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  Widget _buildStatCard(String label, String value, Color color) {
    return AgriCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.muted, fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Text(value,
              style: AppTextStyles.sectionTitle
                  .copyWith(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildProductRow(String title, String price, String qty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(qty,
                    style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          Text(price,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.accentActive, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
