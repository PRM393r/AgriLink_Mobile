import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/order_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_provider.dart';
import '../../../widgets/common/agri_card.dart';
import '../../../widgets/common/agri_button.dart';
import '../../../widgets/common/agri_text_field.dart';

class SupplierDashboardScreen extends StatefulWidget {
  const SupplierDashboardScreen({super.key});

  @override
  State<SupplierDashboardScreen> createState() => _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState extends State<SupplierDashboardScreen> {
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
        _productRepo.getProducts(sortBy: 'createdAt', order: 'desc', limit: 20),
        _orderRepo.getSellerOrders(),
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
      {'value': 'shipping', 'label': 'Đang giao hàng'},
      {'value': 'delivered', 'label': 'Đã giao hàng'},
      {'value': 'cancelled', 'label': 'Hủy đơn'},
    ];

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cập nhật trạng thái đơn hàng'),
        content: const Text('Chọn trạng thái mới cho đơn hàng này:'),
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

  void _showAddProductDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    String category = 'Phân bón & Thuốc BVTV';
    bool submitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Đăng bán vật tư mới'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AgriTextField(
                    controller: nameCtrl,
                    labelText: 'Tên vật tư',
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nhập tên' : null,
                  ),
                  const SizedBox(height: 12),
                  AgriTextField(
                    controller: priceCtrl,
                    labelText: 'Giá bán (VND)',
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Nhập giá';
                      if (double.tryParse(val.trim()) == null) return 'Không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  AgriTextField(
                    controller: unitCtrl,
                    labelText: 'Đơn vị (kg, túi, cuộn...)',
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nhập đơn vị' : null,
                  ),
                  const SizedBox(height: 12),
                  AgriTextField(
                    controller: stockCtrl,
                    labelText: 'Số lượng ban đầu',
                    keyboardType: TextInputType.number,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Nhập số lượng';
                      if (double.tryParse(val.trim()) == null) return 'Không hợp lệ';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'Loại vật tư'),
                    items: [
                      'Phân bón & Thuốc BVTV',
                      'Hạt giống & Cây giống',
                      'Nông cụ & Máy móc',
                    ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) { if (v != null) setDlgState(() => category = v); },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: submitting ? null : () async {
                if (!formKey.currentState!.validate()) return;
                setDlgState(() => submitting = true);
                try {
                  await _productRepo.createProduct(ProductModel(
                    id: '',
                    name: nameCtrl.text.trim(),
                    description: '',
                    pricePerUnit: double.parse(priceCtrl.text.trim()),
                    unit: unitCtrl.text.trim(),
                    availableQuantity: double.parse(stockCtrl.text.trim()),
                    minOrderQuantity: 1,
                    farmingType: 'conventional',
                    status: 'active',
                    viewCount: 0,
                    sellerId: '',
                    sellerType: '',
                    images: const [],
                    certifications: const [],
                    category: category,
                  ));
                  if (ctx.mounted) Navigator.pop(ctx);
                  _load();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã thêm vật tư mới thành công!')),
                    );
                  }
                } catch (e) {
                  setDlgState(() => submitting = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString().replaceAll('Exception: ', '')),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: Text(
                'Thêm mới',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) => price
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.accent;
      case 'confirmed': return AppColors.primaryLight;
      case 'preparing': return AppColors.harvest;
      case 'shipping': return const Color(0xFF2563EB);
      case 'delivered': return AppColors.primary;
      case 'cancelled': return AppColors.error;
      default: return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan Nhà Cung Cấp'),
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
                                'Cung cấp vật tư nông nghiệp,',
                                style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                              ),
                              Text(
                                user?.fullName ?? user?.email ?? 'Nhà cung cấp',
                                style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
                              ),
                            ],
                          ),
                          const CircleAvatar(
                            backgroundColor: AppColors.primaryUltraLight,
                            radius: 24,
                            child: Icon(Icons.store, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Stats
                      Text('Thống kê kho hàng',
                          style: AppTextStyles.sectionTitle.copyWith(fontSize: 16)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                                'Tổng vật tư', '${_products.length}', AppColors.primary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                                'Đơn hàng', '${_orders.length}', AppColors.accent),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildStatCard(
                              'Đang bán',
                              '${_products.where((p) => p.status == 'active').length}',
                              AppColors.harvest,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Inventory
                      Text('Kho hàng vật tư', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 12),

                      if (_products.isEmpty)
                        AgriCard(
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Chưa có vật tư nào',
                                  style: TextStyle(color: AppColors.muted)),
                            ),
                          ),
                        )
                      else
                        ..._products.map((p) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: _buildInventoryItem(p),
                            )),

                      const SizedBox(height: 16),
                      AgriButton(
                        text: 'Thêm vật tư mới',
                        onPressed: _showAddProductDialog,
                      ),
                      const SizedBox(height: 24),

                      // Orders
                      Text('Đơn đặt hàng từ Nông dân', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 12),

                      if (_orders.isEmpty)
                        AgriCard(
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('Chưa có đơn hàng nào',
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
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: statusColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              order.statusLabel,
                                              style: TextStyle(
                                                  color: statusColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
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
                                        '${order.items.length} mặt hàng',
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

  Widget _buildStatCard(String label, String value, Color color) {
    return AgriCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.caption.copyWith(color: AppColors.muted, fontSize: 11),
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

  Widget _buildInventoryItem(ProductModel p) {
    final color = p.category.contains('Phân') ? AppColors.primary
        : p.category.contains('giống') ? AppColors.accent
        : AppColors.harvest;

    return AgriCard(
      margin: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    p.category,
                    style: AppTextStyles.caption
                        .copyWith(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(p.name,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  'Tồn kho: ${p.availableQuantity.toStringAsFixed(0)} ${p.unit}',
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_formatPrice(p.pricePerUnit)}đ/${p.unit}',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.accentActive, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.edit_note, color: AppColors.muted),
            ],
          ),
        ],
      ),
    );
  }
}
