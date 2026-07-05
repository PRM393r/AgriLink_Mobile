import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/product_model.dart';
import '../../data/providers/cart_provider.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/services/api_service.dart';
import '../../router/app_router.dart';
import '../../widgets/common/agri_button.dart';
import '../../widgets/product/product_badge.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  bool _loading = false;
  String? _error;
  int _qty = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_product != null) return;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is ProductModel) {
      setState(() => _product = arg);
    } else if (arg is String) {
      _fetchById(arg);
    }
  }

  Future<void> _fetchById(String id) async {
    setState(() { _loading = true; _error = null; });
    try {
      final repo = ProductRepository(ApiService());
      final p = await repo.getProductById(id);
      setState(() { _product = p; _loading = false; });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _addToCart() {
    final p = _product!;
    final cart = Provider.of<CartProvider>(context, listen: false);
    cart.addItem(p, _qty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${p.name} vào giỏ hàng'),
        backgroundColor: AppColors.primary,
        action: SnackBarAction(
          label: 'Xem giỏ',
          textColor: Colors.white,
          onPressed: () => Navigator.pushNamed(context, AppRouter.cart),
        ),
      ),
    );
  }

  String _formatPrice(double price) => price
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  String _farmingLabel(String type) {
    switch (type.toLowerCase()) {
      case 'organic': return 'Hữu cơ';
      case 'vietgap': return 'VietGAP';
      case 'hydroponic': return 'Thủy canh';
      default: return 'Truyền thống';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    if (_product == null) {
      return const Scaffold(body: Center(child: Text('Không tìm thấy sản phẩm')));
    }

    final p = _product!;
    final primaryImage = p.images.isNotEmpty ? p.images.first : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        actions: [
          Consumer<CartProvider>(
            builder: (_, cart, __) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.ink),
                  onPressed: () => Navigator.pushNamed(context, AppRouter.cart),
                ),
                if (cart.totalItems > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cart.totalItems}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              height: 260,
              width: double.infinity,
              color: AppColors.primaryUltraLight,
              child: primaryImage != null
                  ? Image.network(
                      primaryImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.eco, size: 80, color: AppColors.primary)),
                    )
                  : const Center(child: Icon(Icons.eco, size: 80, color: AppColors.primary)),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (p.category.isNotEmpty) ProductBadge(label: p.category),
                      if (p.farmingType.isNotEmpty)
                        ProductBadge(
                          label: _farmingLabel(p.farmingType),
                          backgroundColor: AppColors.surfaceGreen,
                          textColor: AppColors.primary,
                        ),
                      ...p.certifications.map((c) => ProductBadge(
                            label: c,
                            backgroundColor: const Color(0xFFDBEAFE),
                            textColor: const Color(0xFF1E40AF),
                          )),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(p.name, style: AppTextStyles.bigTitle.copyWith(fontSize: 22)),
                  const SizedBox(height: 8),

                  Text(
                    '${_formatPrice(p.pricePerUnit)}đ/${p.unit}',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.accentActive,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Còn ${p.availableQuantity.toStringAsFixed(0)} ${p.unit} · Tối thiểu ${p.minOrderQuantity.toStringAsFixed(0)} ${p.unit}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 16),

                  // Qty picker
                  Row(
                    children: [
                      Text('Số lượng:',
                          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      _QtyButton(
                        icon: Icons.remove,
                        onTap: () { if (_qty > 1) setState(() => _qty--); },
                      ),
                      const SizedBox(width: 12),
                      Text('$_qty', style: AppTextStyles.sectionTitle),
                      const SizedBox(width: 12),
                      _QtyButton(
                        icon: Icons.add,
                        onTap: () {
                          if (_qty < p.availableQuantity) setState(() => _qty++);
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(p.unit,
                          style: AppTextStyles.caption.copyWith(color: AppColors.muted)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  if (p.description.isNotEmpty) ...[
                    Text('Mô tả sản phẩm', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: 8),
                    Text(p.description, style: AppTextStyles.body),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                  ],

                  // Seller info
                  Text('Thông tin người bán', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryUltraLight,
                        radius: 22,
                        child: Icon(
                          p.sellerType == 'farmer' ? Icons.agriculture : Icons.store,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.sellerType == 'farmer' ? 'Nông dân' : 'Nhà cung cấp',
                            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'ID: ${p.sellerId}',
                            style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom CTA
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              offset: const Offset(0, -4),
              blurRadius: 12,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tổng:',
                      style: AppTextStyles.body.copyWith(color: AppColors.muted)),
                  Text(
                    '${_formatPrice(p.pricePerUnit * _qty)}đ',
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: AppColors.accentActive,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AgriButton(
                text: 'Thêm vào giỏ hàng',
                onPressed: p.status == 'active' ? _addToCart : null,
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          color: AppColors.surfaceSoft,
        ),
        child: Icon(icon, size: 18, color: AppColors.ink),
      ),
    );
  }
}
