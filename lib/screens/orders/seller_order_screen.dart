import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/services/auth_provider.dart';
import '../../router/app_router.dart';

class SellerOrderScreen extends StatefulWidget {
  const SellerOrderScreen({super.key});

  @override
  State<SellerOrderScreen> createState() => _SellerOrderScreenState();
}

class _SellerOrderScreenState extends State<SellerOrderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late OrderRepository _repo;

  static const _tabs = [
    {'label': 'Chờ xác nhận', 'status': 'pending'},
    {'label': 'Đã xác nhận', 'status': 'confirmed'},
    {'label': 'Chuẩn bị', 'status': 'preparing'},
    {'label': 'Đang giao', 'status': 'shipping'},
    {'label': 'Hoàn thành', 'status': 'delivered'},
    {'label': 'Đã hủy', 'status': 'cancelled'},
  ];

  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;
  final Map<String, bool> _actionLoading = {};

  // stats
  int _pendingCount = 0;
  int _todayCount = 0;
  double _monthRevenue = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _loadOrders();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _repo = context.read<OrderRepository>();
      final auth = context.read<AuthProvider>();
      final role = auth.currentUser?.role;
      if (role != 'farmer' && role != 'supplier') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chỉ farmer/supplier mới quản lý đơn bán.'),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.home,
          (r) => false,
        );
        return;
      }
      _loadOrders();
      _loadStats();
    });
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

  Future<void> _loadStats() async {
    try {
      final all = await _repo.getSellerOrders();
      final now = DateTime.now();
      if (mounted) {
        setState(() {
          _pendingCount = all.where((o) => o.status == 'pending').length;
          _todayCount = all.where((o) =>
            o.createdAt.year == now.year &&
            o.createdAt.month == now.month &&
            o.createdAt.day == now.day).length;
          _monthRevenue = all
            .where((o) => o.status == 'delivered' &&
              o.createdAt.year == now.year &&
              o.createdAt.month == now.month)
            .fold(0, (s, o) => s + o.totalAmount);
        });
      }
    } catch (_) {}
  }

  Future<void> _updateStatus(String orderId, String newStatus,
      {String? cancelReason}) async {
    setState(() => _actionLoading[orderId] = true);
    try {
      await _repo.updateOrderStatus(orderId, newStatus,
          cancelReason: cancelReason);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Đã cập nhật: ${_statusLabel(newStatus)}'),
          backgroundColor: AppColors.primary,
        ));
      }
      _loadOrders();
      _loadStats();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Lỗi: ${e.toString().replaceAll("Exception: ", "")}'),
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
      }[s] ??
      s;

  /// Happy-path seller pipeline for demo (skip optional logistics intermediate).
  String? _nextStatus(String current) => const {
        'pending': 'confirmed',
        'confirmed': 'preparing',
        'preparing': 'shipping',
        'handed_to_logistics': 'shipping',
        'shipping': 'delivered',
      }[current];

  String _nextLabel(String current) => const {
        'pending': 'Xác nhận đơn',
        'confirmed': 'Bắt đầu chuẩn bị',
        'preparing': 'Bàn giao / đang giao',
        'handed_to_logistics': 'Đang giao hàng',
        'shipping': 'Đã giao hàng',
      }[current] ??
      'Cập nhật';

  bool _isUrgent(OrderModel o) {
    if (o.status != 'pending') return false;
    final age = DateTime.now().difference(o.createdAt);
    return age.inHours >= 2;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng',
            style: TextStyle(
                color: AppColors.ink,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
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
              labelStyle:
                  AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
              tabs: _tabs.map((t) => Tab(text: t['label'])).toList(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Stats bar ──
          _buildStatsBar(),
          // ── Urgent alert ──
          if (_pendingCount > 0 && _tabController.index == 0)
            _buildUrgentBanner(),
          // ── Orders ──
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _loadOrders,
                    child: _error != null
                        ? _buildError()
                        : _orders.isEmpty
                            ? _buildEmpty()
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                                itemCount: _orders.length,
                                itemBuilder: (_, i) {
                                  final order = _orders[i];
                                  final next = _nextStatus(order.status);
                                  return _SellerOrderCard(
                                    order: order,
                                    isUrgent: _isUrgent(order),
                                    isActionLoading:
                                        _actionLoading[order.id] == true,
                                    nextActionLabel: next != null
                                        ? _nextLabel(order.status)
                                        : null,
                                    onAdvance: next != null
                                        ? () => _showAdvanceConfirm(
                                            order.id, order.status, next)
                                        : null,
                                    onCancel: !['shipping', 'delivered', 'cancelled']
                                            .contains(order.status)
                                        ? () =>
                                            _showCancelDialog(order.id)
                                        : null,
                                  );
                                },
                              ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          _statChip(
            icon: Icons.pending_actions_rounded,
            label: 'Chờ xử lý',
            value: '$_pendingCount',
            color: _pendingCount > 0 ? AppColors.warning : AppColors.muted,
          ),
          const SizedBox(width: 8),
          _statChip(
            icon: Icons.today_rounded,
            label: 'Hôm nay',
            value: '$_todayCount đơn',
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          _statChip(
            icon: Icons.payments_outlined,
            label: 'Doanh thu T${DateTime.now().month}',
            value: _fmtMoney(_monthRevenue),
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 9,
                        color: color,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ),
            ]),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    color: color,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgentBanner() {
    final urgentOrders =
        _orders.where((o) => _isUrgent(o)).length;
    if (urgentOrders == 0) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.warning_amber_rounded,
            color: AppColors.error, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$urgentOrders đơn chờ xác nhận hơn 2 tiếng — cần xử lý gấp!',
            style: AppTextStyles.caption.copyWith(
                color: AppColors.error, fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );
  }

  Widget _buildEmpty() => ListView(children: [
        const SizedBox(height: 100),
        const Icon(Icons.inbox_outlined, size: 64, color: AppColors.muted),
        const SizedBox(height: 16),
        Text('Không có đơn hàng',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center),
      ]);

  Widget _buildError() => ListView(children: [
        const SizedBox(height: 100),
        const Icon(Icons.wifi_off_rounded, size: 64, color: AppColors.muted),
        const SizedBox(height: 16),
        Text('Không thể tải đơn hàng',
            style: AppTextStyles.body.copyWith(color: AppColors.muted),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Center(
            child: TextButton(
                onPressed: _loadOrders, child: const Text('Thử lại'))),
      ]);

  void _showAdvanceConfirm(String orderId, String currentStatus, String nextStatus) {
    final descriptions = const {
      'confirmed': 'Xác nhận đơn hàng này và thông báo cho khách hàng?',
      'preparing': 'Bắt đầu chuẩn bị hàng cho đơn này?',
      'shipping':  'Giao đơn hàng này cho shipper? Không thể hoàn tác.',
      'delivered': 'Xác nhận đã giao thành công đến tay khách hàng?',
    };
    final icons = const {
      'confirmed': Icons.check_circle_outline,
      'preparing': Icons.inventory_2_outlined,
      'shipping':  Icons.local_shipping_outlined,
      'delivered': Icons.done_all_rounded,
    };
    final colors = const {
      'confirmed': Color(0xFF004085),
      'preparing': Color(0xFF432874),
      'shipping':  AppColors.primaryActive,
      'delivered': Color(0xFF155724),
    };

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (colors[nextStatus] ?? AppColors.primary)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icons[nextStatus] ?? Icons.update,
                size: 32,
                color: colors[nextStatus] ?? AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _statusLabel(nextStatus),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              descriptions[nextStatus] ?? 'Chuyển trạng thái đơn hàng?',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 20),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy bỏ',
                style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors[nextStatus] ?? AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(orderId, nextStatus);
            },
            child: const Text('Xác nhận',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(String orderId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hủy đơn hàng',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
              hintText: 'Lý do hủy...', border: OutlineInputBorder()),
          maxLines: 3,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Thoát')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              _updateStatus(orderId, 'cancelled',
                  cancelReason: controller.text.trim());
            },
            child: const Text('Xác nhận hủy',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _fmtMoney(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M đ';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K đ';
    return '${v.toStringAsFixed(0)} đ';
  }
}

// ── Order Card ────────────────────────────────────────────────────────────────

class _SellerOrderCard extends StatefulWidget {
  final OrderModel order;
  final bool isUrgent;
  final bool isActionLoading;
  final String? nextActionLabel;
  final VoidCallback? onAdvance;
  final VoidCallback? onCancel;

  const _SellerOrderCard({
    required this.order,
    required this.isUrgent,
    required this.isActionLoading,
    this.nextActionLabel,
    this.onAdvance,
    this.onCancel,
  });

  @override
  State<_SellerOrderCard> createState() => _SellerOrderCardState();
}

class _SellerOrderCardState extends State<_SellerOrderCard> {
  bool _showTimeline = false;

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: widget.isUrgent
            ? Border.all(color: AppColors.error.withValues(alpha: 0.5), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  if (widget.isUrgent) ...[
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.error, size: 16),
                    const SizedBox(width: 6),
                  ],
                  Text('#${order.orderCode}',
                      style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.bold,
                          color: widget.isUrgent
                              ? AppColors.error
                              : AppColors.ink)),
                ]),
                _StatusBadge(
                    status: order.status, label: order.statusLabel),
              ],
            ),
            if (widget.isUrgent)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Chưa xác nhận ${_ageLabel(order.createdAt)} — cần xử lý!',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.error, fontWeight: FontWeight.w600),
                ),
              ),
            const SizedBox(height: 10),

            // ── Items ──
            ...order.items.take(2).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(children: [
                    const Text('• ',
                        style: TextStyle(color: AppColors.muted)),
                    Expanded(
                      child: Text(
                        '${item.productName}  ×${item.quantity.toInt()} ${item.productUnit}',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.body),
                      ),
                    ),
                    Text(_fmtMoney(item.totalPrice),
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.accentActive,
                            fontWeight: FontWeight.w600)),
                  ]),
                )),
            if (order.items.length > 2)
              Text('  +${order.items.length - 2} sản phẩm khác',
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.muted)),
            const SizedBox(height: 8),

            // ── Totals + date ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmtDate(order.createdAt),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.muted)),
                Text('Tổng: ${_fmtMoney(order.totalAmount)}',
                    style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.accentActive,
                        fontWeight: FontWeight.bold)),
              ],
            ),

            // ── Shipping address ──
            if (order.shippingAddressSnapshot != null) ...[
              const SizedBox(height: 6),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: AppColors.muted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${order.shippingAddressSnapshot!['recipientName'] ?? ''} — ${order.shippingAddressSnapshot!['address'] ?? ''}',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
            ],

            // ── Cancel reason ──
            if ((order.cancelReason?.isNotEmpty == true ||
                    order.cancelledReason?.isNotEmpty == true) &&
                order.status == 'cancelled') ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(children: [
                  const Icon(Icons.cancel_outlined,
                      size: 13, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.cancelReason ??
                          order.cancelledReason ??
                          '',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.error),
                    ),
                  ),
                ]),
              ),
            ],

            // ── Timeline toggle ──
            if (order.statusHistory.isNotEmpty) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () =>
                    setState(() => _showTimeline = !_showTimeline),
                child: Row(children: [
                  Icon(
                    _showTimeline
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showTimeline ? 'Ẩn hành trình' : 'Xem hành trình đơn',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600),
                  ),
                ]),
              ),
              if (_showTimeline) ...[
                const SizedBox(height: 10),
                _buildTimeline(order),
              ],
            ],

            // ── Actions ──
            if (widget.onAdvance != null || widget.onCancel != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              widget.isActionLoading
                  ? const Center(
                      child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary)))
                  : Row(children: [
                      if (widget.onCancel != null)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onCancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(
                                  color: AppColors.error),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10)),
                            ),
                            child: const Text('Hủy đơn'),
                          ),
                        ),
                      if (widget.onCancel != null &&
                          widget.onAdvance != null)
                        const SizedBox(width: 8),
                      if (widget.onAdvance != null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onAdvance,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10)),
                            ),
                            child: Text(
                                widget.nextActionLabel ?? 'Cập nhật',
                                style: const TextStyle(
                                    color: Colors.white)),
                          ),
                        ),
                    ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(OrderModel order) {
    const steps = [
      {'status': 'pending',   'label': 'Đặt hàng',      'icon': Icons.shopping_bag_outlined},
      {'status': 'confirmed', 'label': 'Xác nhận',       'icon': Icons.check_circle_outline},
      {'status': 'preparing', 'label': 'Chuẩn bị',       'icon': Icons.inventory_2_outlined},
      {'status': 'shipping',  'label': 'Đang giao',      'icon': Icons.local_shipping_outlined},
      {'status': 'delivered', 'label': 'Đã giao',        'icon': Icons.done_all_rounded},
    ];

    final historyMap = <String, DateTime>{};
    for (final h in order.statusHistory) {
      historyMap[h.status] = h.changedAt;
    }

    final isCancelled = order.status == 'cancelled';
    final stepsToShow = isCancelled
        ? [...steps, {'status': 'cancelled', 'label': 'Đã hủy', 'icon': Icons.cancel_outlined}]
        : steps;

    return Column(
      children: stepsToShow.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final stepStatus = step['status'] as String;
        final stepLabel = step['label'] as String;
        final stepIcon = step['icon'] as IconData;

        final ts = historyMap[stepStatus];
        final isDone = ts != null;
        final isCurrent = stepStatus == order.status;
        final isLast = i == stepsToShow.length - 1;

        Color dotColor;
        if (stepStatus == 'cancelled' && isCancelled) {
          dotColor = AppColors.error;
        } else if (isDone) {
          dotColor = isCurrent ? AppColors.primary : AppColors.success;
        } else {
          dotColor = AppColors.surfaceDivider;
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dot + line
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isDone
                            ? dotColor.withValues(alpha: 0.12)
                            : AppColors.surfaceSoft,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: dotColor,
                            width: isCurrent ? 2 : 1.5),
                      ),
                      child: Icon(stepIcon,
                          size: 12,
                          color: isDone ? dotColor : AppColors.muted),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          color: isDone && historyMap.containsKey(
                                  stepsToShow[i + 1]['status'])
                              ? AppColors.success.withValues(alpha: 0.4)
                              : AppColors.surfaceDivider,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Label + time
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stepLabel,
                          style: AppTextStyles.caption.copyWith(
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isDone ? AppColors.ink : AppColors.muted)),
                      if (ts != null)
                        Text(_fmtDateTime(ts),
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.muted, fontSize: 10)),
                      if (!isDone && !isCurrent)
                        Text('Chưa thực hiện',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.muted, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _ageLabel(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours >= 1) return '${diff.inHours} tiếng';
    return '${diff.inMinutes} phút';
  }

  String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  String _fmtDateTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}  ${dt.day}/${dt.month}/${dt.year}';

  String _fmtMoney(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M đ';
    if (v >= 1000) {
      final s = v.toStringAsFixed(0);
      final b = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
        b.write(s[i]);
      }
      return '${b}đ';
    }
    return '${v.toStringAsFixed(0)}đ';
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String label;
  const _StatusBadge({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (status) {
      case 'pending':
        bg = const Color(0xFFFFF3CD);
        fg = const Color(0xFF856404);
        break;
      case 'confirmed':
        bg = const Color(0xFFCCE5FF);
        fg = const Color(0xFF004085);
        break;
      case 'preparing':
        bg = const Color(0xFFE2D9F3);
        fg = const Color(0xFF432874);
        break;
      case 'shipping':
        bg = AppColors.primaryUltraLight;
        fg = AppColors.primaryActive;
        break;
      case 'delivered':
        bg = const Color(0xFFD4EDDA);
        fg = const Color(0xFF155724);
        break;
      default:
        bg = const Color(0xFFF8D7DA);
        fg = AppColors.error;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }
}
