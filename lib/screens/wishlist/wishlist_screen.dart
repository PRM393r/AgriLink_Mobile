import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/product_model.dart';
import '../../data/services/wishlist_service.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/common/animated_list_item.dart';
import '../../router/app_router.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _isLoading = true;
  List<ProductModel> _wishlist = [];

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    setState(() => _isLoading = true);
    try {
      final wishlistService = context.read<WishlistService>();
      final products = await wishlistService.getWishlist();
      if (mounted) {
        setState(() {
          _wishlist = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải danh sách yêu thích: $e')),
        );
      }
    }
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
          : _wishlist.isEmpty
              ? _buildEmptyState()
              : _buildWishlistGrid(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: AppColors.muted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            'Chưa có sản phẩm yêu thích',
            style: AppTextStyles.subtitle.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Khám phá ngay'),
          )
        ],
      ),
    );
  }

  Widget _buildWishlistGrid() {
    return RefreshIndicator(
      onRefresh: _fetchWishlist,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        itemCount: _wishlist.length,
        itemBuilder: (context, index) {
          return AnimatedListItem(
            index: index,
            child: ProductCard(
              product: _wishlist[index],
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  AppRouter.productDetail,
                  arguments: _wishlist[index],
                );
                // Refresh wishlist when coming back in case they un-wishlisted
                _fetchWishlist();
              },
            ),
          );
        },
      ),
    );
  }
}
