import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_shadows.dart';
import '../../data/providers/cart_provider.dart';
import '../../data/models/product_model.dart';
import '../../widgets/common/agri_button.dart';
import '../../widgets/product/product_badge.dart';
import '../../widgets/product/reviews_section.dart';
import '../../data/services/review_service.dart';
import '../../data/models/review_model.dart';
import '../../router/app_router.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isLoadingReviews = true;
  List<ReviewModel> _reviews = [];
  ProductModel? _product;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_product == null) {
      _product = ModalRoute.of(context)?.settings.arguments as ProductModel?;
      if (_product != null) {
        _fetchReviews();
      }
    }
  }

  Future<void> _fetchReviews() async {
    if (_product == null) return;
    setState(() => _isLoadingReviews = true);
    try {
      final service = context.read<ReviewService>();
      final reviews = await service.getProductReviews(_product!.id);
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _isLoadingReviews = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingReviews = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final name = product?.name ?? 'Sản phẩm';
    final desc = product?.description ?? '';
    final price = product?.pricePerUnit ?? 0;
    final unit = product?.unit ?? 'kg';
    final category = product?.category ?? '';
    final certs = product?.certifications ?? const [];
    final farmType = product?.farmingType ?? '';

    return Scaffold(
      backgroundColor: AppColors.surfaceElevated,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppColors.canvas,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: AppColors.canvas.withValues(alpha: 0.9),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.ink),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: product?.primaryImageUrl != null && product!.primaryImageUrl!.isNotEmpty
                      ? Image.network(
                          product.primaryImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        children: [
                          ProductBadge(label: category),
                          ...certs.map((c) => ProductBadge(
                                label: c,
                                backgroundColor: AppColors.successLight,
                                textColor: AppColors.success,
                              )),
                          ProductBadge(
                            label: farmType,
                            backgroundColor: AppColors.infoLight,
                            textColor: AppColors.info,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(name,
                          style: AppTextStyles.bigTitle.copyWith(fontSize: 24)),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${_fmt(price)}đ',
                              style: AppTextStyles.headline.copyWith(
                                  color: AppColors.accentActive, fontSize: 26)),
                          const SizedBox(width: 4),
                          Text('/$unit',
                              style: AppTextStyles.subtitle
                                  .copyWith(color: AppColors.muted)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _divider(),
                      const SizedBox(height: 20),
                      Text('Số lượng',
                          style: AppTextStyles.subtitle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink)),
                      const SizedBox(height: 12),
                      _buildQtySelector(),
                      const SizedBox(height: 24),
                      _divider(),
                      const SizedBox(height: 20),
                      Text('Mô tả sản phẩm',
                          style: AppTextStyles.sectionTitle
                              .copyWith(fontSize: 16)),
                      const SizedBox(height: 10),
                      Text(desc,
                          style: AppTextStyles.body
                              .copyWith(height: 1.6, color: AppColors.body)),
                      const SizedBox(height: 24),
                      _divider(),
                      const SizedBox(height: 20),
                      Text('Thông tin nhà vườn',
                          style: AppTextStyles.sectionTitle
                              .copyWith(fontSize: 16)),
                      const SizedBox(height: 14),
                      _buildSellerCard(),
                      const SizedBox(height: 24),
                      ReviewsSection(
                        reviews: _reviews,
                        isLoading: _isLoadingReviews,
                        onAddReview: () async {
                          if (product == null) return;
                          final result = await Navigator.pushNamed(
                            context,
                            AppRouter.reviewForm,
                            arguments: {
                              'productId': product.id,
                              'orderId': '668541c8d0751836a992fa12',
                              'productName': product.name,
                            },
                          );
                          if (result == true) {
                            _fetchReviews();
                          }
                        },
                      ),
                      
                      const SizedBox(height: 100), // padding for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              boxShadow: AppShadows.bottomBar,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Tổng cộng', style: AppTextStyles.caption),
                        Text('${_fmt(price * _quantity)}đ',
                            style: AppTextStyles.sectionTitle.copyWith(
                                color: AppColors.accentActive, fontSize: 20)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AgriButton.gradient(
                      text: 'Thêm vào giỏ',
                      icon: Icons.add_shopping_cart_rounded,
                      height: 48,
                      onPressed: () {
                        if (product != null) {
                          Provider.of<CartProvider>(context, listen: false)
                              .addItem(product, _quantity);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Đã thêm $_quantity $unit vào giỏ!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildQtySelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.surfaceDivider.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _qtyBtn(Icons.remove_rounded, () {
            if (_quantity > 1) setState(() => _quantity--);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text('$_quantity',
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 18)),
          ),
          _qtyBtn(Icons.add_rounded, () => setState(() => _quantity++)),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildSellerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.surfaceDivider.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(colors: AppColors.freshGradient),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.storefront_rounded,
                color: AppColors.canvas, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HTX Nông nghiệp sạch Đà Lạt',
                    style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w600, color: AppColors.ink)),
                const SizedBox(height: 4),
                Text('Đức Trọng, Lâm Đồng',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    size: 14, color: AppColors.success),
                const SizedBox(width: 2),
                Text('4.8',
                    style: AppTextStyles.badge.copyWith(
                        color: AppColors.success, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(color: AppColors.surfaceDivider.withValues(alpha: 0.4), height: 1);

  String _fmt(double p) {
    final s = p.toStringAsFixed(0);
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryUltraLight,
            AppColors.primaryLight.withValues(alpha: 0.2),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Text('🌿', style: TextStyle(fontSize: 64)),
      ),
    );
  }
}


