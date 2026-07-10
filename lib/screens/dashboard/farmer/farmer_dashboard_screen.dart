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
import 'add_product_screen.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
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
    final displayName = user?.fullName ?? user?.phone ?? 'Nông dân';

    return Scaffold(
      backgroundColor: AppColors.surfaceElevated,
      body: RefreshIndicator(
        onRefresh: _fetchMyProducts,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Sản phẩm',
                        value: _loading ? '...' : '${_products.length}',
                        icon: Icons.eco_rounded,
                        gradientColors: AppColors.freshGradient,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Tổng tồn kho',
                        value: _loading
                            ? '...'
                            : _products.isEmpty
                                ? '0'
                                : '${_products.fold(0.0, (sum, p) => sum + p.availableQuantity).toInt()}',
                        icon: Icons.inventory_2_outlined,
                        gradientColors: AppColors.warmGradient,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                        label: 'Hoạt động',
                        value: _loading
                            ? '...'
                            : '${_products.where((p) => p.status == 'active').length}',
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
                    if (!_loading && _products.isNotEmpty)
                      Text('${_products.length} sản phẩm',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.muted)),
                  ],
                ),
              ),
            ),

            // ── Product list ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _loading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _error != null
                        ? _buildError()
                        : _products.isEmpty
                            ? _buildEmpty()
                            : _buildProductList(),
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
                    await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const AddProductScreen()));
                    _fetchMyProducts(); // refresh sau khi thêm
                  },
                ),
              ),
            ),

            // ── Manage orders CTA ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRouter.sellerOrders),
                  icon: const Icon(Icons.receipt_long_outlined,
                      color: AppColors.primary),
                  label: Text('Quản lý đơn hàng',
                      style: AppTextStyles.button
                          .copyWith(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceDivider.withValues(alpha: 0.3)),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: _products.asMap().entries.map((e) {
          final p = e.value;
          final isLast = e.key == _products.length - 1;
          return AnimatedListItem(
            index: e.key,
            child: Column(
              children: [
                InkWell(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRouter.productDetail,
                    arguments: p,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: e.key == 0 ? const Radius.circular(16) : Radius.zero,
                    bottom: isLast ? const Radius.circular(16) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Product image / emoji
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: p.images.isNotEmpty
                              ? Image.network(
                                  p.images.first,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _productEmoji(),
                                )
                              : _productEmoji(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.name,
                                  style: AppTextStyles.subtitle
                                      .copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _stockColor(p.availableQuantity),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    p.availableQuantity <= 0
                                        ? 'Hết hàng'
                                        : 'Còn ${p.availableQuantity.toInt()} ${p.unit}',
                                    style: AppTextStyles.caption.copyWith(
                                      color: _stockColor(p.availableQuantity),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (p.certifications.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.successLight,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(p.certifications.first,
                                          style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.success,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(p.category,
                                  style: AppTextStyles.caption
                                      .copyWith(color: AppColors.muted)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${_fmt(p.pricePerUnit)}đ',
                                style: AppTextStyles.price
                                    .copyWith(fontSize: 14)),
                            Text('/${p.unit}',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.muted)),
                            const SizedBox(height: 4),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 12, color: AppColors.muted),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                      height: 1,
                      indent: 78,
                      color: AppColors.surfaceDivider.withValues(alpha: 0.3)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _productEmoji() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppColors.freshGradient),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: Text('🌿', style: TextStyle(fontSize: 22))),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.eco_outlined, size: 48, color: AppColors.muted),
          const SizedBox(height: 12),
          Text('Chưa có sản phẩm nào',
              style: AppTextStyles.subtitle.copyWith(color: AppColors.muted)),
          const SizedBox(height: 6),
          Text('Nhấn nút bên dưới để đăng bán nông sản đầu tiên!',
              style: AppTextStyles.caption,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(Icons.wifi_off, color: AppColors.error, size: 36),
          const SizedBox(height: 8),
          Text('Không tải được danh sách',
              style: AppTextStyles.caption.copyWith(color: AppColors.error)),
          const SizedBox(height: 12),
          TextButton(onPressed: _fetchMyProducts, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}
