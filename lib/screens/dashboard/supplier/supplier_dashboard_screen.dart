import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
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
  // Mock inventory list
  final List<Map<String, dynamic>> _inventory = [
    {
      'name': 'Phân bón NPK Humic đầu trâu',
      'stock': 'Số lượng tồn kho: 1,500 kg',
      'price': '18,000đ/kg',
      'category': 'Phân bón',
      'color': AppColors.primary,
    },
    {
      'name': 'Hạt giống Cà chua cherry F1',
      'stock': 'Số lượng tồn kho: 450 túi',
      'price': '35,000đ/túi',
      'category': 'Hạt giống',
      'color': AppColors.accent,
    },
    {
      'name': 'Màng phủ nông nghiệp 1.2m',
      'stock': 'Số lượng tồn kho: 80 cuộn',
      'price': '380,000đ/cuộn',
      'category': 'Vật tư phủ',
      'color': AppColors.harvest,
    },
  ];

  // Mock orders from farmers
  final List<Map<String, String>> _farmerOrders = [
    {
      'id': 'SUP-5511',
      'item': 'Phân bón NPK Humic đầu trâu',
      'quantity': '100 kg',
      'total': '1,800,000đ',
      'farmer': 'Nông dân Nguyễn Văn A',
      'status': 'Chờ chuẩn bị',
    },
    {
      'id': 'SUP-5512',
      'item': 'Hạt giống Cà chua cherry F1',
      'quantity': '5 túi',
      'total': '175,000đ',
      'farmer': 'Nông dân Trần Thị B',
      'status': 'Đang giao hàng',
    },
  ];

  void _updateOrderStatus(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cập nhật trạng thái đơn hàng'),
          content: const Text('Chọn trạng thái mới cho đơn hàng này:'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _farmerOrders[index]['status'] = 'Đang giao hàng';
                });
                Navigator.pop(context);
              },
              child: const Text('Đang giao'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _farmerOrders[index]['status'] = 'Đã giao hàng';
                });
                Navigator.pop(context);
              },
              child: Text(
                'Hoàn thành',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _farmerOrders[index]['status'] = 'Đã hủy';
                });
                Navigator.pop(context);
              },
              child: const Text('Hủy đơn', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }

  void _showAddMaterialDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nhập giá' : null,
                  ),
                  const SizedBox(height: 12),
                  AgriTextField(
                    controller: stockCtrl,
                    labelText: 'Số lượng ban đầu',
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nhập số lượng' : null,
                  ),
                  const SizedBox(height: 12),
                  AgriTextField(
                    controller: categoryCtrl,
                    labelText: 'Loại vật tư',
                    validator: (val) => val == null || val.trim().isEmpty ? 'Nhập loại' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _inventory.add({
                      'name': nameCtrl.text.trim(),
                      'stock': 'Số lượng tồn kho: ${stockCtrl.text.trim()}',
                      'price': '${priceCtrl.text.trim()}đ',
                      'category': categoryCtrl.text.trim(),
                      'color': AppColors.primary,
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã thêm vật tư mới thành công!')),
                  );
                }
              },
              child: Text(
                'Thêm mới',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
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
      ),
      body: Container(
        color: AppColors.surfaceSoft,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cung cấp vật tư nông nghiệp,',
                          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                        ),
                        Text(
                          user?.fullName ?? user?.phone ?? 'Nhà cung cấp',
                          style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    backgroundColor: AppColors.primaryUltraLight,
                    radius: 24,
                    child: Icon(Icons.store, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Summary Stats
              Text('Thống kê kho hàng', style: AppTextStyles.sectionTitle.copyWith(fontSize: 16)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Tổng vật tư', '${_inventory.length}', AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Đơn hàng mới', '${_farmerOrders.length}', AppColors.accent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Doanh thu', '2.5M đ', AppColors.harvest),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Inventory Section
              Text('Kho hàng vật tư', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 12),
              ..._inventory.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: _buildInventoryItem(
                    name: item['name'] as String,
                    stock: item['stock'] as String,
                    price: item['price'] as String,
                    category: item['category'] as String,
                    color: item['color'] as Color,
                  ),
                );
              }),
              const SizedBox(height: 16),

              AgriButton(
                text: 'Thêm vật tư mới',
                onPressed: _showAddMaterialDialog,
              ),
              const SizedBox(height: 24),

              // Orders from farmers Section
              Text('Đơn đặt hàng từ Nông dân', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 12),
              ..._farmerOrders.map((order) {
                final idx = _farmerOrders.indexOf(order);
                final statusColor = order['status'] == 'Chờ chuẩn bị'
                    ? AppColors.accent
                    : order['status'] == 'Đang giao hàng'
                        ? AppColors.primaryLight
                        : order['status'] == 'Đã giao hàng'
                            ? AppColors.primary
                            : AppColors.error;

                return AgriCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  onTap: () => _updateOrderStatus(idx),
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
                                  order['id']!,
                                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    order['status']!,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              order['item']!,
                              style: AppTextStyles.body.copyWith(color: AppColors.ink),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Số lượng: ${order['quantity']} | Người mua: ${order['farmer']}',
                              style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        order['total']!,
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
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.muted, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.sectionTitle.copyWith(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItem({
    required String name,
    required String stock,
    required String price,
    required String category,
    required Color color,
  }) {
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
                    category,
                    style: AppTextStyles.caption.copyWith(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  stock,
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: AppTextStyles.body.copyWith(color: AppColors.accentActive, fontWeight: FontWeight.bold),
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
