import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/services/api_service.dart';
import '../../router/app_router.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrderRepository _repo;

  final _tabs = const [
    {'label': 'Tất cả', 'status': 'all'},
    {'label': 'Chờ xác nhận', 'status': 'pending'},
    {'label': 'Đang giao', 'status': 'shipping'},
    {'label': 'Hoàn thành', 'status': 'delivered'},
    {'label': 'Đã hủy', 'status': 'cancelled'},
  ];

  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _repo = OrderRepository(ApiService());
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _loadOrders();
    });
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final status = _tabs[_tabController.index]['status']!;
      final orders = await _repo.getMyOrders(status: status);
      if (mounted) setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: const Text(
          'Đơn hàng của tôi',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(49),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.muted,
              indicatorColor: AppColors.primary,
              labelStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
              tabs: _tabs.map((t) => Tab(text: t['label'])).toList(),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadOrders,
              child: _orders.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _orders.length,
                      itemBuilder: (_, i) => _OrderCard(
                        order: _orders[i],
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.orderDetail,
                          arguments: _orders[i],
                        ),
                        onTrack: () => Navigator.pushNamed(
                          context,
                          AppRouter.orderTracking,
                          arguments: {
                            'orderId': _orders[i].id,
                            'orderCode': _orders[i].orderCode,
                          },
                        ),
                      ),
                    ),
            ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.muted),
        const SizedBox(height: 16),
        Text(
          'Chưa có đơn hàng nào',
          style: AppTextStyles.body.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Order card ───────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final VoidCallback? onTrack;

  const _OrderCard({required this.order, required this.onTap, this.onTrack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
              // Header: mã đơn + badge trạng thái
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${order.orderCode}',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  _StatusBadge(status: order.status, label: order.statusLabel),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Danh sách items (max 2, sau đó "...và X sản phẩm khác")
              ...order.items.take(2).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            width: 40,
                            height: 40,
                            color: AppColors.primaryUltraLight,
                            child: item.productImageUrl != null
                                ? Image.network(item.productImageUrl!, fit: BoxFit.cover)
                                : const Icon(Icons.eco_outlined, color: AppColors.primary, size: 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.productName,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          'x${item.quantity.toInt()}',
                          style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                        ),
                      ],
                    ),
                  )),
              if (order.items.length > 2)
                Text(
                  '...và ${order.items.length - 2} sản phẩm khác',
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                ),

              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),

              // Footer: ngày đặt + tổng tiền
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(order.createdAt),
                    style: AppTextStyles.caption,
                  ),
                  Text(
                    '${_formatPrice(order.totalAmount)} đ',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentActive,
                    ),
                  ),
                ],
              ),
              if (order.status == 'shipping' && onTrack != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onTrack,
                    icon: const Icon(Icons.location_on, size: 16),
                    label: const Text('Theo dõi đơn hàng'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String label;

  const _StatusBadge({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    switch (status) {
      case 'pending':
        bg = const Color(0xFFFFF3CD);
        text = const Color(0xFF856404);
        break;
      case 'confirmed':
      case 'preparing':
        bg = const Color(0xFFCCE5FF);
        text = const Color(0xFF004085);
        break;
      case 'handed_to_logistics':
      case 'shipping':
        bg = AppColors.primaryUltraLight;
        text = AppColors.primaryActive;
        break;
      case 'delivered':
        bg = const Color(0xFFD4EDDA);
        text = const Color(0xFF155724);
        break;
      case 'cancelled':
        bg = const Color(0xFFF8D7DA);
        text = AppColors.error;
        break;
      default:
        bg = AppColors.surfaceSoft;
        text = AppColors.muted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: text)),
    );
  }
}

