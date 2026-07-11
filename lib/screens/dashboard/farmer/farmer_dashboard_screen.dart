import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/auth_provider.dart';
import '../../../router/app_router.dart';
import '../../../widgets/common/agri_button.dart';
import '../../../widgets/common/stat_card.dart';
import '../../../widgets/common/animated_list_item.dart';
import '../../../data/models/order_model.dart';
import '../../../data/services/product_service.dart';
import '../../../data/services/order_service.dart';
import '../../../core/utils/currency_formatter.dart';
import 'product_form_screen.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  List<ProductModel> _myProducts = [];
  List<OrderModel> _orders = [];
  Map<String, dynamic> _stats = {
    'totalRevenue': 0,
    'totalOrders': 0,
    'pendingOrders': 0,
    'totalProducts': 0
  };
  List<Map<String, dynamic>> _chartData = [];
  double _maxRevenue = 0;
  bool _isLoading = true;
  bool _isChartLoading = false;
  String _chartType = 'monthly';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
      _fetchChartData();
    });
  }

  Future<void> _fetchData() async {
    try {
      final productService = context.read<ProductService>();
      final orderService = context.read<OrderService>();

      final stats = await orderService.getSellerStats();
      final products = await productService.fetchMyProducts();
      final orders = await orderService.getSellerOrders(status: 'pending');

      if (mounted) {
        setState(() {
          _stats = stats;
          _myProducts = products.take(10).toList(); // Show up to 10 but scrollable
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
      }
    }
  }

  Future<void> _fetchChartData() async {
    if (!mounted) return;
    setState(() => _isChartLoading = true);
    try {
      final orderService = context.read<OrderService>();
      final revenueData = await orderService.getMonthlyRevenue(type: _chartType);
      
      double maxRev = 0;
      for (var item in revenueData) {
        final revenue = (item['revenue'] as num).toDouble();
        if (revenue > maxRev) maxRev = revenue;
      }

      if (mounted) {
        setState(() {
          _chartData = revenueData;
          _maxRevenue = maxRev;
          _isChartLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChartLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải biểu đồ: $e')));
      }
    }
  }

  void _updateOrderStatus(int index) async {
    final order = _orders[index];
    final String? newStatus = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật trạng thái'),
        content: const Text('Chọn trạng thái mới:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'preparing'),
            child: const Text('Đang xử lý'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'delivered'),
            child: Text('Hoàn thành', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancelled'),
            child: const Text('Hủy đơn', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (newStatus != null && mounted) {
      try {
        final orderService = context.read<OrderService>();
        await orderService.updateOrderStatus(order.id, newStatus);
        _fetchData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
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
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Xin chào, 👋',
                            style: AppTextStyles.subtitle.copyWith(
                                color: AppColors.canvas.withValues(alpha: 0.8))),
                        const SizedBox(height: 4),
                        Text(displayName,
                            style: AppTextStyles.sectionTitle.copyWith(
                                color: AppColors.canvas, fontSize: 22),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.canvas.withValues(alpha: 0.2),
                    child: const Icon(Icons.person_rounded, color: AppColors.canvas),
                  ),
                ],
              ),
            ),
          ),

          // ── Stats ──
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
            )
          else
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'Sản phẩm',
                            value: '${_stats['totalProducts']}',
                            icon: Icons.eco_rounded,
                            gradientColors: AppColors.freshGradient,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            label: 'Đơn mới',
                            value: '${_stats['pendingOrders']}',
                            icon: Icons.receipt_long_rounded,
                            gradientColors: AppColors.warmGradient,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            label: 'Doanh thu',
                            value: CurrencyFormatter.formatShortForm(_stats['totalRevenue']),
                            icon: Icons.trending_up_rounded,
                            gradientColors: AppColors.sunsetGradient,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_chartData.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        decoration: BoxDecoration(
                          color: AppColors.canvas,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.surfaceDivider.withValues(alpha: 0.3)),
                          boxShadow: AppShadows.card,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Doanh thu',
                                  style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
                                ),
                                SegmentedButton<String>(
                                  segments: const [
                                    ButtonSegment<String>(
                                      value: 'monthly',
                                      label: Text('Năm'),
                                    ),
                                    ButtonSegment<String>(
                                      value: 'daily',
                                      label: Text('Tháng'),
                                    ),
                                  ],
                                  selected: {_chartType},
                                  onSelectionChanged: (Set<String> newSelection) {
                                    if (_chartType == newSelection.first) return;
                                    setState(() {
                                      _chartType = newSelection.first;
                                    });
                                    _fetchChartData();
                                  },
                                  style: SegmentedButton.styleFrom(
                                    visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                                    textStyle: const TextStyle(fontSize: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            AspectRatio(
                              aspectRatio: 1.5,
                              child: _isChartLoading 
                                ? const Center(child: CircularProgressIndicator())
                                : BarChart(
                                    BarChartData(
                                      alignment: BarChartAlignment.spaceAround,
                                      maxY: _maxRevenue > 0 ? _maxRevenue * 1.2 : 100000,
                                      barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipColor: (_) => AppColors.ink.withValues(alpha: 0.8),
                                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                        final labelText = _chartType == 'monthly'
                                            ? 'Tháng ${group.x.toInt()}'
                                            : 'Ngày ${group.x.toInt()}';
                                        return BarTooltipItem(
                                          '$labelText\n',
                                          const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: CurrencyFormatter.format(rod.toY),
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (double value, TitleMeta meta) {
                                          if (_chartType == 'daily') {
                                            if (value % 5 != 0 && value != 1) {
                                              return const SizedBox.shrink();
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                '${value.toInt()}',
                                                style: const TextStyle(color: AppColors.muted, fontSize: 10),
                                              ),
                                            );
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'T${value.toInt()}',
                                              style: const TextStyle(color: AppColors.muted, fontSize: 12),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: _maxRevenue > 0 ? _maxRevenue / 4 : 25000,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: AppColors.surfaceDivider.withValues(alpha: 0.5),
                                        strokeWidth: 1,
                                        dashArray: [5, 5],
                                      );
                                    },
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barGroups: _chartData.map((data) {
                                    final label = data['label'] as int;
                                    final revenue = (data['revenue'] as num).toDouble();
                                    return BarChartGroupData(
                                      x: label,
                                      barRods: [
                                        BarChartRodData(
                                          toY: revenue,
                                          color: AppColors.primary,
                                          width: _chartType == 'daily' ? 4 : 12,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                          backDrawRodData: BackgroundBarChartRodData(
                                            show: true,
                                            toY: _maxRevenue > 0 ? _maxRevenue * 1.2 : 100000,
                                            color: AppColors.surfaceSoft,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

          // ── Products header ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sản phẩm của tôi',
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 18)),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRouter.myProducts).then((_) => _fetchData());
                    },
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
          if (!_isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceDivider.withValues(alpha: 0.3)),
                    boxShadow: AppShadows.card,
                  ),
                  child: _myProducts.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Center(child: Text('Chưa có sản phẩm nào')),
                        )
                      : ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 260),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: _myProducts.asMap().entries.map((e) {
                            final p = e.value;
                            final isLast = e.key == _myProducts.length - 1;
                            return AnimatedListItem(
                              index: e.key,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, AppRouter.myProducts).then((_) => _fetchData());
                                },
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
                                            borderRadius: BorderRadius.circular(12),
                                            color: AppColors.surfaceSoft,
                                            image: p.primaryImageUrl != null
                                                ? DecorationImage(
                                                    image: NetworkImage(p.primaryImageUrl!),
                                                    fit: BoxFit.cover)
                                                : null,
                                          ),
                                          child: p.primaryImageUrl == null
                                              ? const Center(child: Text('🌿', style: TextStyle(fontSize: 20)))
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(p.name,
                                                  style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w600),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis),
                                              const SizedBox(height: 2),
                                              Text('Có sẵn: ${p.availableQuantity} ${p.unit}', style: AppTextStyles.caption),
                                            ],
                                          ),
                                        ),
                                        Text(CurrencyFormatter.format(p.pricePerUnit),
                                            style: AppTextStyles.price.copyWith(fontSize: 14)),
                                      ],
                                    ),
                                  ),
                                  if (!isLast)
                                    Divider(height: 1, indent: 70, color: AppColors.surfaceDivider.withValues(alpha: 0.3)),
                                ],
                              ),
                            ),
                            );
                          }).toList(),
                        ),
                      ),
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
                onPressed: () async {
                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductFormScreen()));
                  if (result == true) {
                    _fetchData();
                  }
                }
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

  Widget _buildOrderCard(OrderModel order, int index) {
    final statusColor = order.isPending
        ? AppColors.accent
        : order.isActive
            ? AppColors.info
            : order.isDelivered
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
          border: Border.all(color: AppColors.surfaceDivider.withValues(alpha: 0.3)),
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
                      Text(order.orderCode.isEmpty ? 'Đơn hàng mới' : order.orderCode,
                          style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(order.statusLabel,
                            style: AppTextStyles.badge.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                      order.items.isNotEmpty ? order.items.first.productName : 'Sản phẩm',
                      style: AppTextStyles.body.copyWith(color: AppColors.ink)),
                  const SizedBox(height: 4),
                  Text(
                      'SL: ${order.items.fold<double>(0, (sum, i) => sum + i.quantity)} | Người mua: ${order.shippingAddressSnapshot?['recipientName'] ?? 'Khách'}',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            Text(CurrencyFormatter.format(order.totalAmount),
                style: AppTextStyles.price.copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
  }

}
