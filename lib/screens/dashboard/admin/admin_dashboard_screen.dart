import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../router/app_router.dart';
import '../../../widgets/common/loading_overlay.dart';
import '../../../widgets/common/stat_card.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _dashboard;
  List<Map<String, dynamic>> _monthlyRevenue = [];
  List<Map<String, dynamic>> _userGrowth = [];
  List<Map<String, dynamic>> _topSellers = [];
  List<Map<String, dynamic>> _topProducts = [];
  double _maxRevenue = 0;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<AdminRepository>();
      final results = await Future.wait([
        repo.getDashboard(),
        repo.getMonthlyRevenue(),
        repo.getUserGrowth(),
        repo.getTopSellers(),
        repo.getTopProducts(),
      ]);
      final dashboard = results[0] as Map<String, dynamic>;
      final revenue = results[1] as List<Map<String, dynamic>>;

      double maxRev = 0;
      for (final item in revenue) {
        final r = (item['revenue'] as num).toDouble();
        if (r > maxRev) maxRev = r;
      }

      if (!mounted) return;
      setState(() {
        _dashboard = dashboard;
        _monthlyRevenue = revenue;
        _userGrowth = results[2] as List<Map<String, dynamic>>;
        _topSellers = results[3] as List<Map<String, dynamic>>;
        _topProducts = results[4] as List<Map<String, dynamic>>;
        _maxRevenue = maxRev;
      });
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isExporting = false;

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);
    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.get<List<int>>(
        '/admin/reports/orders.csv',
        options: Options(responseType: ResponseType.bytes),
      );

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/orders-report-${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsBytes(response.data as List<int>);

      if (!mounted) return;
      await Share.shareXFiles([XFile(file.path)], text: 'Báo cáo đơn hàng AgriLink');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không xuất được báo cáo: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = _dashboard;
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: const Text('Quản trị hệ thống'),
        actions: [
          IconButton(
            icon: _isExporting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.file_download_outlined),
            tooltip: 'Xuất báo cáo đơn hàng (CSV)',
            onPressed: _isExporting ? null : _exportCsv,
          ),
          IconButton(
            icon: const Icon(Icons.campaign_outlined),
            tooltip: 'Gửi thông báo',
            onPressed: () => Navigator.pushNamed(context, AppRouter.adminBroadcast),
          ),
          IconButton(
            icon: const Icon(Icons.manage_accounts_outlined),
            tooltip: 'Quản lý người dùng',
            onPressed: () => Navigator.pushNamed(context, AppRouter.adminUsers),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: dashboard == null
            ? const SizedBox.shrink()
            : RefreshIndicator(
                onRefresh: _fetchAll,
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatGrid(dashboard),
                      const SizedBox(height: 24),
                      Text('Doanh thu theo tháng', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 8),
                      Text(
                        'Doanh thu toàn hệ thống từ các đơn hàng đã giao thành công.',
                        style: AppTextStyles.body.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: 20),
                      if (_monthlyRevenue.isNotEmpty) _buildRevenueChart(),
                      const SizedBox(height: 24),
                      Text('Người dùng mới theo tháng', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 20),
                      if (_userGrowth.isNotEmpty) _buildGrowthChart(),
                      const SizedBox(height: 24),
                      Text('Tỷ lệ trạng thái đơn hàng', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 20),
                      _buildOrderStatusChart(dashboard),
                      const SizedBox(height: 24),
                      Text('Top người bán', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 12),
                      if (_topSellers.isNotEmpty) _buildTopSellersChart(),
                      const SizedBox(height: 24),
                      Text('Top sản phẩm bán chạy', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 12),
                      if (_topProducts.isNotEmpty) _buildTopProductsList(),
                      const SizedBox(height: 24),
                      Text('Quản lý nâng cao', style: AppTextStyles.sectionTitle),
                      const SizedBox(height: 12),
                      _buildManagementGrid(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildManagementGrid() {
    final items = [
      (Icons.storefront_outlined, 'Duyệt seller mới', AppRouter.adminPendingSellers),
      (Icons.inventory_2_outlined, 'Kiểm duyệt sản phẩm', AppRouter.adminProducts),
      (Icons.gavel_outlined, 'Khiếu nại đơn hàng', AppRouter.adminDisputes),
      (Icons.history_outlined, 'Nhật ký hoạt động', AppRouter.adminAuditLog),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: items.map((item) {
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => Navigator.pushNamed(context, item.$3),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Icon(item.$1, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.$2, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGrowthChart() {
    final spots = _userGrowth
        .map((d) => FlSpot((d['label'] as int).toDouble(), (d['count'] as num).toDouble()))
        .toList();
    final maxCount = _userGrowth.fold<double>(0, (m, d) => (d['count'] as num).toDouble() > m ? (d['count'] as num).toDouble() : m);

    return AspectRatio(
      aspectRatio: 1.6,
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: 12,
          minY: 0,
          maxY: maxCount > 0 ? maxCount * 1.3 : 5,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) => Text('T${value.toInt()}', style: const TextStyle(color: AppColors.muted, fontSize: 11)),
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(color: AppColors.surfaceDivider.withValues(alpha: 0.5), strokeWidth: 1, dashArray: [5, 5]),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.ink.withValues(alpha: 0.8),
              getTooltipItems: (spots) => spots.map((s) {
                return LineTooltipItem('${s.y.toInt()} người dùng', const TextStyle(color: Colors.white, fontSize: 12));
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.1)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSellersChart() {
    final maxRevenue = _topSellers.fold<double>(0, (m, s) => (s['revenue'] as num).toDouble() > m ? (s['revenue'] as num).toDouble() : m);
    return Column(
      children: _topSellers.map((seller) {
        final revenue = (seller['revenue'] as num).toDouble();
        final ratio = maxRevenue > 0 ? revenue / maxRevenue : 0.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      seller['sellerName'] as String? ?? '',
                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(CurrencyFormatter.formatShortForm(revenue), style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceDivider.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopProductsList() {
    return Column(
      children: _topProducts.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final product = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primaryUltraLight,
                child: Text('$rank', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name'] as String? ?? '', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text('Đã bán ${product['totalQuantity']}', style: AppTextStyles.overline.copyWith(color: AppColors.muted)),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.formatShortForm((product['totalRevenue'] as num?) ?? 0),
                style: AppTextStyles.caption.copyWith(color: AppColors.accentActive, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatGrid(Map<String, dynamic> dashboard) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          label: 'Tổng người dùng',
          value: '${dashboard['totalUsers']}',
          icon: Icons.people_alt_outlined,
          onTap: () => Navigator.pushNamed(context, AppRouter.adminUsers),
        ),
        StatCard(
          label: 'Tổng đơn hàng',
          value: '${dashboard['totalOrders']}',
          icon: Icons.receipt_long_outlined,
          gradientColors: const [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
        ),
        StatCard(
          label: 'Doanh thu (đã giao)',
          value: CurrencyFormatter.formatShortForm((dashboard['totalRevenue'] as num?) ?? 0),
          icon: Icons.payments_outlined,
          gradientColors: const [Color(0xFFB45309), Color(0xFFF59E0B)],
        ),
        StatCard(
          label: 'Sản phẩm đang bán',
          value: '${dashboard['activeProducts']}/${dashboard['totalProducts']}',
          icon: Icons.inventory_2_outlined,
          gradientColors: const [Color(0xFF7C3AED), Color(0xFFA78BFA)],
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    return AspectRatio(
      aspectRatio: 1.4,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _maxRevenue > 0 ? _maxRevenue * 1.2 : 100000,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.ink.withValues(alpha: 0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  'Tháng ${group.x.toInt()}\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: CurrencyFormatter.format(rod.toY),
                      style: const TextStyle(color: AppColors.primary, fontSize: 13),
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
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('T${value.toInt()}', style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                ),
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _maxRevenue > 0 ? _maxRevenue / 4 : 25000,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.surfaceDivider.withValues(alpha: 0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _monthlyRevenue.map((data) {
            final month = data['label'] as int;
            final revenue = (data['revenue'] as num).toDouble();
            return BarChartGroupData(
              x: month,
              barRods: [
                BarChartRodData(
                  toY: revenue,
                  color: AppColors.primary,
                  width: 14,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  static const _statusColors = {
    'pending': Color(0xFFF59E0B),
    'confirmed': Color(0xFF3B82F6),
    'preparing': Color(0xFF8B5CF6),
    'shipping': Color(0xFF06B6D4),
    'delivered': Color(0xFF22C55E),
    'cancelled': Color(0xFFEF4444),
  };

  static const _statusLabels = {
    'pending': 'Chờ xác nhận',
    'confirmed': 'Đã xác nhận',
    'preparing': 'Đang chuẩn bị',
    'shipping': 'Đang giao',
    'delivered': 'Đã giao',
    'cancelled': 'Đã hủy',
  };

  Widget _buildOrderStatusChart(Map<String, dynamic> dashboard) {
    final byStatus = Map<String, dynamic>.from(dashboard['ordersByStatus'] as Map);
    final total = _statusColors.keys.fold<int>(0, (sum, k) => sum + ((byStatus[k] as num?)?.toInt() ?? 0));

    if (total == 0) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Chưa có đơn hàng nào')),
      );
    }

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.5,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _statusColors.entries.map((entry) {
                final count = (byStatus[entry.key] as num?)?.toInt() ?? 0;
                if (count == 0) return null;
                final pct = count / total * 100;
                return PieChartSectionData(
                  value: count.toDouble(),
                  color: entry.value,
                  title: '${pct.toStringAsFixed(0)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).whereType<PieChartSectionData>().toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: _statusColors.entries.map((entry) {
            final count = (byStatus[entry.key] as num?)?.toInt() ?? 0;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: entry.value, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('${_statusLabels[entry.key]} ($count)', style: AppTextStyles.caption),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
