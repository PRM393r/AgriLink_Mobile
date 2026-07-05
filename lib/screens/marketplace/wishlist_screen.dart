import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/wishlist_service.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/common/loading_overlay.dart';
import '../../../widgets/product/product_card.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  bool _isLoading = true;
  List<ProductModel> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    setState(() => _isLoading = true);
    final service = context.read<WishlistService>();
    final items = await service.getWishlist();
    if (mounted) {
      setState(() {
        _items = items;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu thích'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _items.isEmpty && !_isLoading
            ? const EmptyState(
                icon: Icons.favorite_border,
                title: 'Chưa có sản phẩm yêu thích',
                message: 'Hãy thả tim cho sản phẩm bạn quan tâm nhé!',
              )
            : RefreshIndicator(
                onRefresh: _fetchWishlist,
                color: AppColors.primary,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: _items[index],
                    );
                  },
                ),
              ),
      ),
    );
  }
}
