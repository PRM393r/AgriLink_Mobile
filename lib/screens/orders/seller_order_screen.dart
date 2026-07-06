import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/services/api_service.dart';

class SellerOrderScreen extends StatefulWidget {
  const SellerOrderScreen({super.key});

  @override
  State<SellerOrderScreen> createState() => _SellerOrderScreenState();
}

class _SellerOrderScreenState extends State<SellerOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrderRepository _repo;

  final _tabs = const [
    {'label': 'Chờ xác nhận', 'status': 'pending'},
    {'label': 'Đang xử lý', 'status': 'confirmed'},
    {'label': 'Đang giao', 'status': 'shipping'},
    {'label': 'Hoàn thành', 'status': 'delivered'},
  ];

  List<OrderModel> _orders = [];
  bool _isLoading = true;
  final Map<String, bool> _actionLoading = {};

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
    setState(() => _isLoading = true);
    try {
      final status = _tabs[_tabController.index]['status']!;
      final orders = await _repo.getSellerOrders(status: status);
      if (mounted) setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _orders = _mockSellerOrders;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus) async {
    setState(() => _actionLoading[orderId] = true);
    try {
      await _repo.updateOrderStatus(orderId, newStatus);
      _loadOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _actionLoading.remove(orderId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: const Text(
          'Quản lý đơn hàng',
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
                      itemBuilder: (_, i) => _SellerOrderCard(
                        order: _orders[i],
                        isActionLoading: _actionLoading[_orders[i].id] == true,
                        onConfirm: _orders[i].isPending
                            ? () => _updateStatus(_orders[i].id, 'confirmed')
                            : null,
                        onReject: (_orders[i].isPending || _orders[i].status == 'confirmed')
                            ? () => _showRejectDialog(_orders[i].id)
                            : null,
                      ),
                    ),
            ),
    );
  }

  Widget _buildEmpty() {
    return ListView(children: [
      const SizedBox(height: 120),
      const Icon(Icons.inbox_outlined, size: 64, color: AppColors.muted),
      const SizedBox(height: 16),
      Text('Không có đơn hàng', style: AppTextStyles.body.copyWith(color: AppColors.muted), textAlign: TextAlign.center),
    ]);
  }

  void _showRejectDialog(String orderId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy đơn hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Lý do hủy...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Thoát')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(orderId, 'cancelled');
            },
            child: const Text('Xác nhận hủy', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Seller order card ─────────────────────────────────────────────────────────

class _SellerOrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isActionLoading;
  final VoidCallback? onConfirm;
  final VoidCallback? onReject;

  const _SellerOrderCard({
    required this.order,
    required this.isActionLoading,
    this.onConfirm,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('#${order.orderCode}',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            _badge(order.status, order.statusLabel),
          ]),
          const SizedBox(height: 8),
          Text(
            '${order.items.length} sản phẩm • ${_fmt(order.totalAmount)} đ',
            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 4),
          Text(_fmtDate(order.createdAt), style: AppTextStyles.caption),

          if (onConfirm != null || onReject != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            isActionLoading
                ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)))
                : Row(children: [
                    if (onReject != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onReject,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Hủy đơn'),
                        ),
                      ),
                    if (onConfirm != null && onReject != null) const SizedBox(width: 8),
                    if (onConfirm != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                  ]),
          ],
        ]),
      ),
    );
  }

  Widget _badge(String status, String label) {
    Color bg, fg;
    switch (status) {
      case 'pending': bg = const Color(0xFFFFF3CD); fg = const Color(0xFF856404); break;
      case 'confirmed': case 'preparing': bg = const Color(0xFFCCE5FF); fg = const Color(0xFF004085); break;
      case 'shipping': bg = AppColors.primaryUltraLight; fg = AppColors.primaryActive; break;
      case 'delivered': bg = const Color(0xFFD4EDDA); fg = const Color(0xFF155724); break;
      default: bg = const Color(0xFFF8D7DA); fg = AppColors.error;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

// ── Mock fallback ─────────────────────────────────────────────────────────────

final _mockSellerOrders = [
  OrderModel(
    id: 's1', orderCode: 'AGL-20260705-002',
    buyerId: 'buyer2', sellerId: 'me',
    status: 'pending', subtotal: 70000, shippingFee: 0, totalAmount: 70000,
    paymentMethod: 'cod', paymentStatus: 'unpaid',
    items: [OrderItemModel(id: 'si1', productSnapshot: {'name': 'Cà rốt Đà Lạt', 'unit': 'kg'}, quantity: 2, unitPrice: 35000, totalPrice: 70000)],
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    updatedAt: DateTime.now(),
  ),
];
