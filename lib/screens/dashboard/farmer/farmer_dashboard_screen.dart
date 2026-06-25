import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
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
  // Mock products list for farmer
  final List<Map<String, String>> _myProducts = [
    {'title': 'Cà chua organic Lâm Đồng', 'price': '25,000đ/kg', 'qty': 'Có sẵn: 120 kg'},
    {'title': 'Sầu riêng Ri6 VietGAP', 'price': '120,000đ/kg', 'qty': 'Có sẵn: 500 kg'},
    {'title': 'Bắp cải hữu cơ', 'price': '15,000đ/cây', 'qty': 'Có sẵn: 80 cây'},
  ];

  // Mock orders list for farmer
  final List<Map<String, String>> _orders = [
    {
      'id': 'ORD-8821',
      'product': 'Cà chua organic Lâm Đồng',
      'quantity': '20 kg',
      'total': '500,000đ',
      'buyer': 'Nguyễn Văn A',
      'status': 'Đang chờ xử lý',
    },
    {
      'id': 'ORD-8822',
      'product': 'Bắp cải hữu cơ',
      'quantity': '10 cây',
      'total': '150,000đ',
      'buyer': 'Trần Thị B',
      'status': 'Đang xử lý',
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
                  _orders[index]['status'] = 'Đang xử lý';
                });
                Navigator.pop(context);
              },
              child: const Text('Đang xử lý'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _orders[index]['status'] = 'Đã hoàn thành';
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
                  _orders[index]['status'] = 'Đã hủy';
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
      ),
      body: Container(
        color: AppColors.surfaceSoft,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Header
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
                        user?.fullName ?? user?.phone ?? 'Nông dân',
                        style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.primaryUltraLight,
                    radius: 24,
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Statistics Section
              Text(
                'Thống kê tổng quan',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Sản phẩm', '${_myProducts.length}', AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Đơn hàng mới', '${_orders.length}', AppColors.accent),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Doanh thu', '3.4M đ', AppColors.harvest),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section Products
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sản phẩm của tôi',
                    style: AppTextStyles.sectionTitle,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Xem tất cả',
                      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // List of items
              AgriCard(
                child: Column(
                  children: _myProducts.map((p) {
                    final idx = _myProducts.indexOf(p);
                    return Column(
                      children: [
                        _buildProductRow(p['title']!, p['price']!, p['qty']!),
                        if (idx < _myProducts.length - 1) const Divider(),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Add Product Quick Button
              AgriButton(
                text: 'Đăng bán nông sản mới',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddProductScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Pending Orders Section
              Text(
                'Đơn hàng đang chờ xử lý',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 12),
              ..._orders.map((order) {
                final idx = _orders.indexOf(order);
                final statusColor = order['status'] == 'Đang chờ xử lý'
                    ? AppColors.accent
                    : order['status'] == 'Đang xử lý'
                        ? AppColors.primaryLight
                        : order['status'] == 'Đã hoàn thành'
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
                              order['product']!,
                              style: AppTextStyles.body.copyWith(color: AppColors.ink),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Số lượng: ${order['quantity']} | Người mua: ${order['buyer']}',
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

  Widget _buildProductRow(String title, String price, String qty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  qty,
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: AppTextStyles.body.copyWith(
              color: AppColors.accentActive,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
