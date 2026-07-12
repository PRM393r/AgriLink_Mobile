import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_provider.dart';
import '../../../router/app_router.dart';
import '../../../widgets/common/agri_button.dart';
import '../../../widgets/common/stat_card.dart';
import '../../../widgets/common/animated_list_item.dart';
import '../../../widgets/notification/notification_badge.dart';

class SupplierDashboardScreen extends StatefulWidget {
  const SupplierDashboardScreen({super.key});

  @override
  State<SupplierDashboardScreen> createState() => _SupplierDashboardScreenState();
}

class _SupplierDashboardScreenState extends State<SupplierDashboardScreen> {
  List<ProductModel> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMyProducts();
  }

  Future<void> _fetchMyProducts() async {
    setState(() { _loading = true; _error = null; });
    try {
      final repo = ProductRepository(ApiService());
      final list = await repo.getProducts(sellerId: 'me');
      if (mounted) setState(() { _products = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _fmt(double p) {
    final s = p.toStringAsFixed(0);
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  Color _stockColor(double qty) {
    if (qty <= 0) return AppColors.error;
    if (qty <= 20) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final displayName = user?.fullName ?? user?.phone ?? 'Nhà cung cấp';

    final totalStock = _products.fold<double>(0, (s, p) => s + p.availableQuantity);
    final activeCount = _products.where((p) => p.status == 'active').length;

    return Scaffold(
      backgroundColor: AppColors.surfaceElevated,
      body: RefreshIndicator(
        onRefresh: _fetchMyProducts,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.fromLTRB(
                    20, MediaQuery.of(context).padding.top + 16, 20, 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F4C75), Color(0xFF1B6CA8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
                  boxShadow: AppShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.store_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Nhà cung cấp vật tư',
                                  style: AppTextStyles.caption.copyWith(
                                      color: Colors.white.withValues(alpha: 0.75))),
                              Text(displayName,
                                  style: AppTextStyles.sectionTitle.copyWith(
                                      color: Colors.white, fontSize: 20),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const NotificationBadge(
                            iconColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _headerStat('Vật tư', '${_products.length}'),
                        _headerDivider(),
                        _headerStat('Đang bán', '$activeCount'),
                        _headerDivider(),
                        _headerStat('Tổng kho', '${totalStock.toInt()}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Action buttons ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: AgriButton.gradient(
                        text: 'Thêm vật tư mới',
                        icon: Icons.add_rounded,
                        height: 44,
                        onPressed: () async {
                          final added = await Navigator.pushNamed(
                              context, AppRouter.productForm);
                          if (added == true) _fetchMyProducts();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.receipt_long_rounded,
                            size: 18, color: AppColors.primary),
                        label: Text('Đơn hàng',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRouter.sellerOrders),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Product list header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Kho vật tư của bạn',
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 16)),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ── Content ──
            if (_loading)
              const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off_rounded,
                          size: 48, color: AppColors.muted),
                      const SizedBox(height: 12),
                      Text('Không tải được dữ liệu',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.muted)),
                      const SizedBox(height: 12),
                      TextButton(
                          onPressed: _fetchMyProducts,
                          child: const Text('Thử lại')),
                    ],
                  ),
                ),
              )
            else if (_products.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏪', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 12),
                      Text('Chưa có vật tư nào',
                          style: AppTextStyles.body
                              .copyWith(color: AppColors.muted)),
                      const SizedBox(height: 8),
                      Text('Thêm vật tư để bắt đầu bán hàng',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.muted)),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final p = _products[i];
                      final stockColor = _stockColor(p.availableQuantity);
                      final hasImg = p.images.isNotEmpty;
                      return AnimatedListItem(
                        index: i,
                        child: InkWell(
                          onTap: () => Navigator.pushNamed(
                              context, AppRouter.productDetail,
                              arguments: p),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppShadows.card,
                            ),
                            child: Row(
                              children: [
                                // Product image / emoji
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.primaryUltraLight,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: hasImg
                                      ? Image.network(p.images.first,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Center(
                                                  child: Text('🏪',
                                                      style: TextStyle(
                                                          fontSize: 28))))
                                      : const Center(
                                          child: Text('🏪',
                                              style:
                                                  TextStyle(fontSize: 28))),
                                ),
                                const SizedBox(width: 12),
                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(p.name,
                                          style: AppTextStyles.subtitle
                                              .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.ink),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${_fmt(p.pricePerUnit)}đ / ${p.unit}',
                                          style: AppTextStyles.caption
                                              .copyWith(
                                                  color:
                                                      AppColors.accentActive,
                                                  fontWeight:
                                                      FontWeight.w700)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                                color: stockColor,
                                                shape: BoxShape.circle),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                              'Kho: ${p.availableQuantity.toInt()} ${p.unit}',
                                              style: AppTextStyles.caption
                                                  .copyWith(
                                                      color: AppColors.muted)),
                                          if (p.certifications.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 1),
                                              decoration: BoxDecoration(
                                                color: AppColors.successLight,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                  p.certifications.first,
                                                  style: AppTextStyles.caption
                                                      .copyWith(
                                                          color: AppColors
                                                              .success,
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w700)),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    color: AppColors.muted, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _products.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerStat(String label, String value) => Expanded(
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75), fontSize: 11)),
          ],
        ),
      );

  Widget _headerDivider() => Container(
        height: 32,
        width: 1,
        color: Colors.white.withValues(alpha: 0.25),
        margin: const EdgeInsets.symmetric(horizontal: 8),
      );
}
