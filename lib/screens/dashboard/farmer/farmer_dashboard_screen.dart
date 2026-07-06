import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../data/services/auth_provider.dart';
import '../../../widgets/common/agri_button.dart';
import '../../../widgets/common/stat_card.dart';
import '../../../widgets/common/animated_list_item.dart';
import 'add_product_screen.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  final List<Map<String, String>> _myProducts = [
    {'title': 'Cà chua organic Lâm Đồng', 'price': '25,000đ/kg', 'qty': 'Có sẵn: 120 kg'},
    {'title': 'Sầu riêng Ri6 VietGAP', 'price': '120,000đ/kg', 'qty': 'Có sẵn: 500 kg'},
    {'title': 'Bắp cải hữu cơ', 'price': '15,000đ/cây', 'qty': 'Có sẵn: 80 cây'},
  ];

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
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật trạng thái'),
        content: const Text('Chọn trạng thái mới:'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _orders[index]['status'] = 'Đang xử lý');
              Navigator.pop(context);
            },
            child: const Text('Đang xử lý'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _orders[index]['status'] = 'Đã hoàn thành');
              Navigator.pop(context);
            },
            child: Text('Hoàn thành',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _orders[index]['status'] = 'Đã hủy');
              Navigator.pop(context);
            },
            child: const Text('Hủy đơn',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final displayName = user?.fullName ?? user?.phone ?? 'Nông dân';

    return Scaffold(
      backgroundColor: AppColors.surfaceElevated,
      body: CustomScrollView(
        slivers: [
          // ── Gradient Header ──
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 16, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Xin chào, 👋',
                          style: AppTextStyles.subtitle
                              .copyWith(color: AppColors.canvas.withValues(alpha: 0.8))),
                      const SizedBox(height: 4),
                      Text(displayName,
                          style: AppTextStyles.sectionTitle.copyWith(
                              color: AppColors.canvas, fontSize: 22)),
                    ],
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.canvas.withValues(alpha: 0.2),
                    child: const Icon(Icons.person_rounded,
                        color: AppColors.canvas),
                  ),
                ],
              ),
            ),
          ),

          // ── Stats ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Sản phẩm',
                      value: '${_myProducts.length}',
                      icon: Icons.eco_rounded,
                      gradientColors: AppColors.freshGradient,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Đơn mới',
                      value: '${_orders.length}',
                      icon: Icons.receipt_long_rounded,
                      gradientColors: AppColors.warmGradient,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      label: 'Doanh thu',
                      value: '3.4M',
                      icon: Icons.trending_up_rounded,
                      gradientColors: AppColors.sunsetGradient,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Products header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sản phẩm của tôi',
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 18)),
                  TextButton(
                    onPressed: () {},
                    child: Text('Xem tất cả',
                        style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),

          // ── Product list ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.surfaceDivider.withValues(alpha: 0.3)),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  children: _myProducts.asMap().entries.map((e) {
                    final p = e.value;
                    final isLast = e.key == _myProducts.length - 1;
                    return AnimatedListItem(
                      index: e.key,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: AppColors.freshGradient),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text('🌿',
                                        style: TextStyle(fontSize: 20)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(p['title']!,
                                          style: AppTextStyles.subtitle
                                              .copyWith(
                                                  fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 2),
                                      Text(p['qty']!,
                                          style: AppTextStyles.caption),
                                    ],
                                  ),
                                ),
                                Text(p['price']!,
                                    style: AppTextStyles.price
                                        .copyWith(fontSize: 14)),
                              ],
                            ),
                          ),
                          if (!isLast)
                            Divider(
                                height: 1,
                                indent: 70,
                                color: AppColors.surfaceDivider
                                    .withValues(alpha: 0.3)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // ── Add product button ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: AgriButton.gradient(
                text: 'Đăng bán nông sản mới',
                icon: Icons.add_rounded,
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AddProductScreen())),
              ),
            ),
          ),

          // ── Orders header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Text('Đơn hàng chờ xử lý',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 18)),
            ),
          ),

          // ── Order cards ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final order = _orders[index];
                  return AnimatedListItem(
                    index: index,
                    child: _buildOrderCard(order, index),
                  );
                },
                childCount: _orders.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, String> order, int index) {
    final statusColor = order['status'] == 'Đang chờ xử lý'
        ? AppColors.accent
        : order['status'] == 'Đang xử lý'
            ? AppColors.info
            : order['status'] == 'Đã hoàn thành'
                ? AppColors.success
                : AppColors.error;

    return GestureDetector(
      onTap: () => _updateOrderStatus(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.surfaceDivider.withValues(alpha: 0.3)),
          boxShadow: AppShadows.card,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(order['id']!,
                          style: AppTextStyles.subtitle
                              .copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(order['status']!,
                            style: AppTextStyles.badge.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(order['product']!,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Text(
                      'SL: ${order['quantity']} | Người mua: ${order['buyer']}',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            Text(order['total']!,
                style: AppTextStyles.price.copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
