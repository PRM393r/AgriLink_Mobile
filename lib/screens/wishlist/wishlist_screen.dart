import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/product_model.dart';
import '../../data/providers/wishlist_provider.dart';
import '../../data/services/wishlist_service.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/common/animated_list_item.dart';
import '../../widgets/common/empty_state.dart';
import '../../router/app_router.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _isLoading = true;
  String? _error;
  List<ProductModel> _wishlist = [];

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final wishlistService = context.read<WishlistService>();
      final products = await wishlistService.getWishlist();
      await context.read<WishlistProvider>().fetchWishlistIds();
      if (mounted) {
        setState(() {
          _wishlist = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _removeFromWishlist(ProductModel product) async {
    await context.read<WishlistProvider>().toggleWishlist(product.id);
    if (!mounted) return;
    setState(() {
      _wishlist.removeWhere((p) => p.id == product.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceElevated,
      appBar: AppBar(
        title: Text('Đã thích', style: AppTextStyles.sectionTitle),
        centerTitle: true,
        backgroundColor: AppColors.canvas,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _wishlist.isEmpty
              ? EmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: 'Không tải được yêu thích',
                  message: _error!,
                  actionLabel: 'Thử lại',
                  onActionPressed: _fetchWishlist,
                )
              : _wishlist.isEmpty
                  ? EmptyState(
                      icon: Icons.favorite_border,
                      title: 'Chưa có sản phẩm yêu thích',
                      message: 'Thả tim trên sản phẩm để lưu vào đây.',
                      actionLabel: 'Khám phá marketplace',
                      onActionPressed: () =>
                          Navigator.pushNamed(context, AppRouter.marketplace),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchWishlist,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: _wishlist.length,
                        itemBuilder: (context, index) {
                          final product = _wishlist[index];
                          return AnimatedListItem(
                            index: index,
                            child: Stack(
                              children: [
                                ProductCard(
                                  product: product,
                                  onTap: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      AppRouter.productDetail,
                                      arguments: product,
                                    );
                                    _fetchWishlist();
                                  },
                                ),
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Material(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    shape: const CircleBorder(),
                                    child: IconButton(
                                      tooltip: 'Bỏ yêu thích',
                                      icon: const Icon(
                                        Icons.favorite,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _removeFromWishlist(product),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
