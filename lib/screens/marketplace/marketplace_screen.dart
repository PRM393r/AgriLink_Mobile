import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/product_model.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/common/animated_list_item.dart';
import '../../router/app_router.dart';
import 'package:provider/provider.dart';
import '../../data/services/product_service.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int _selectedCategoryIndex = 0;

  final List<String> _filterChips = [
    'Tất cả',
    '🥬 Rau củ',
    '🍊 Trái cây',
    '🌾 Lúa gạo',
    '🌱 Vật tư',
    '🐟 Thủy sản',
  ];

  bool _isLoading = true;
  List<ProductModel> _products = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final productService = context.read<ProductService>();
      String? category;
      if (_selectedCategoryIndex > 0) {
        // Remove emoji from category name for API querying
        final rawCat = _filterChips[_selectedCategoryIndex];
        category = rawCat.substring(rawCat.indexOf(' ') + 1).trim();
      }
      
      final products = await productService.fetchMarketplaceProducts(
        category: category,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải sản phẩm: $e')),
        );
      }
    }
  }

  void _onCategorySelected(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() => _selectedCategoryIndex = index);
    _fetchProducts();
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    // We could add debouncer here
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceElevated,
      body: CustomScrollView(
        slivers: [
          // ── App bar ──
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.canvas,
            elevation: 0,
            title: Text(
              'Chợ nông sản',
              style: AppTextStyles.sectionTitle,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border, color: AppColors.error),
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.wishlist);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // ── Search bar ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.surfaceDivider.withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm nông sản sạch...',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.muted, size: 22),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    hintStyle: AppTextStyles.subtitle.copyWith(
                      color: AppColors.muted.withValues(alpha: 0.6),
                    ),
                  ),
                  onSubmitted: _onSearchChanged,
                ),
              ),
            ),
          ),

          // ── Filter chips ──
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                itemCount: _filterChips.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _onCategorySelected(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.canvas,
                          borderRadius: BorderRadius.circular(20),
                          border: isSelected
                              ? null
                              : Border.all(
                                  color: AppColors.surfaceDivider
                                      .withValues(alpha: 0.4),
                                ),
                        ),
                        child: Text(
                          _filterChips[index],
                          style: AppTextStyles.subtitle.copyWith(
                            color: isSelected
                                ? AppColors.canvas
                                : AppColors.body,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Product count ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                _isLoading ? 'Đang tải...' : '${_products.length} sản phẩm',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.muted,
                ),
              ),
            ),
          ),

          // ── Product grid ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return AnimatedListItem(
                    index: index,
                    child: ProductCard(
                      product: _products[index],
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.productDetail,
                          arguments: _products[index],
                        );
                      },
                    ),
                  );
                },
                childCount: _products.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
