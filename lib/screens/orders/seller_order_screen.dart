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
    {'label': 'Đã xác nhận',  'status': 'confirmed'},
    {'label': 'Chuẩn bị',     'status': 'preparing'},
    {'label': 'Đang giao',    'status': 'shipping'},
    {'label': 'Hoàn thành',   'status': 'delivered'},
  ];

  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;
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
    setState(() { _isLoading = true; _error = null; });
    try {
      final status = _tabs[_tabController.index]['status']!;
      final orders = await _repo.getSellerOrders(status: status);
      if (mounted) setState(() { _orders = orders; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _updateStatus(String orderId, String newStatus, {String? cancelReason}) async {
    setState(() => _actionLoading[orderId] = true);
    try {
      await _repo.updateOrderStatus(orderId, newStatus, cancelReason: cancelReason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Đã cập nhật: ${_statusLabel(newStatus)}'),
          backgroundColor: AppColors.primary,
        ));
      }
      _loadOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Lỗi: ${e.toString().replaceAll("Exception: ", "")}'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _actionLoading.remove(orderId));
    }
  }

  String _statusLabel(String s) => const {
    'confirmed': 'Đã xác nhận',
    'preparing': 'Đang chuẩn bị',
    'shipping':  'Đang giao hàng',
    'delivered': 'Đã giao hàng',
    'cancelled': 'Đã hủy',
  }[s] ?? s;

  // Next logical status for each current status
  String? _nextStatus(String current) => const {
    'pending':   'confirmed',
    'confirmed': 'preparing',
    'preparing': 'shipping',
    'shipping':  'delivered',
  }[current];

  String _nextLabel(String current) => const {
    'pending':   'Xác nhận đơn',
    'confirmed': 'Bắt đầu chuẩn bị',
    'preparing': 'Giao cho shipper',
    'shipping':  'Đã giao hàng',
  }[current] ?? 'Cập nhật';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 18)),
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
              child: _error != null
                  ? _buildError()
                  : _orders.isEmpty
                      ? _buildEmpty()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _orders.length,
                          itemBuilder: (_, i) {
                            final order = _orders[i];
                            final next = _nextStatus(order.status);
                            return _SellerOrderCard(
                              order: order,
                              isActionLoading: _actionLoading[order.id] == true,
                              nextActionLabel: next != null ? _nextLabel(order.status) : null,
                              onAdvance: next != null
                                  ? () => _updateStatus(order.id, next)
                                  : null,
                              onCancel: (order.status != 'delivered' && order.status != 'cancelled')
                                  ? () => _showCancelDialog(order.id)
                                  : null,
                            );
                          },
                        ),
            ),
    );
  }

  Widget _buildEmpty() => ListView(children: [
    const SizedBox(height: 120),
    const Icon(Icons.inbox_outlined, size: 64, color: AppColors.muted),
    const SizedBox(height: 16),
    Text('Không có đơn hàng',
        style: AppTextStyles.body.copyWith(color: AppColors.muted),
        textAlign: TextAlign.center),
  ]);

  Widget _buildError() => ListView(children: [
    const SizedBox(height: 120),
    const Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.muted),
    const SizedBox(height: 16),
    Text('Không thể tải đơn hàng',
        style: AppTextStyles.body.copyWith(color: AppColors.muted),
        textAlign: TextAlign.center),
    const SizedBox(height: 12),
    Center(child: TextButton(onPressed: _loadOrders, child: const Text('Thử lại'))),
  ]);

  void _showCancelDialog(String orderId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy đơn hàng', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Lý do hủy...', border: OutlineInputBorder()),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Thoát')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(orderId, 'cancelled', cancelReason: controller.text.trim());
            },
            child: const Text('Xác nhận hủy', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Seller order card ──────────────────────────────────────────────────────────

class _SellerOrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isActionLoading;
  final String? nextActionLabel;
  final VoidCallback? onAdvance;
  final VoidCallback? onCancel;

  const _SellerOrderCard({
    required this.order,
    required this.isActionLoading,
    this.nextActionLabel,
    this.onAdvance,
    this.onCancel,
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
            _StatusBadge(status: order.status, label: order.statusLabel),
          ]),
          const SizedBox(height: 8),
          // Items preview
          ...order.items.take(2).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              '• ${item.productSnapshot['name'] ?? ''} x${item.quantity}',
              style: AppTextStyles.caption.copyWith(color: AppColors.body),
            ),
          )),
          if (order.items.length > 2)
            Text('  +${order.items.length - 2} sản phẩm khác',
                style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
          const SizedBox(height: 6),
          Text('Tổng: ${_fmt(order.totalAmount)} đ  •  ${_fmtDate(order.createdAt)}',
              style: AppTextStyles.caption.copyWith(color: AppColors.muted)),

          if (onAdvance != null || onCancel != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            isActionLoading
                ? const Center(child: SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)))
                : Row(children: [
                    if (onCancel != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Hủy đơn'),
                        ),
                      ),
                    if (onCancel != null && onAdvance != null) const SizedBox(width: 8),
                    if (onAdvance != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAdvance,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(nextActionLabel ?? 'Cập nhật',
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                  ]),
          ],
        ]),
      ),
    );
  }

  String _fmt(double v) => v.toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String label;
  const _StatusBadge({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case 'pending':   bg = const Color(0xFFFFF3CD); fg = const Color(0xFF856404); break;
      case 'confirmed': bg = const Color(0xFFCCE5FF); fg = const Color(0xFF004085); break;
      case 'preparing': bg = const Color(0xFFE2D9F3); fg = const Color(0xFF432874); break;
      case 'shipping':  bg = AppColors.primaryUltraLight; fg = AppColors.primaryActive; break;
      case 'delivered': bg = const Color(0xFFD4EDDA); fg = const Color(0xFF155724); break;
      default:          bg = const Color(0xFFF8D7DA); fg = AppColors.error;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}
