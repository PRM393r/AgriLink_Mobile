import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/services/api_service.dart';
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
  late final ProductRepository _repo;

  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  List<ProductModel> _products = [];
  bool _isLoading = true;
  String? _error;

  final List<String> _filterChips = [
    'Tất cả',
    '🥬 Rau củ',
    '🍊 Trái cây',
    '🌾 Lúa gạo',
    '🌱 Vật tư',
    '🐟 Thủy sản',
  ];

  final Map<int, String> _chipToCategory = {
    1: 'Rau củ',
    2: 'Trái cây',
    3: 'Lúa gạo',
    4: 'Vật tư',
    5: 'Thủy hải sản',
  };

  @override
  void initState() {
    super.initState();
    _repo = ProductRepository(ApiService());
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final category = _chipToCategory[_selectedCategoryIndex];
      final products = await _repo.getProducts(
        category: category,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        limit: 100,
      );
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
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
            title: Text('Chợ nông sản', style: AppTextStyles.sectionTitle),
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
                  onChanged: (v) {
                    _searchQuery = v;
                    _fetchProducts();
                  },
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

          // ── Product count / state ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: _isLoading
                  ? const SizedBox.shrink()
                  : Text(
                      _error != null
                          ? 'Lỗi tải dữ liệu'
                          : '${_products.length} sản phẩm',
                      style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                    ),
            ),
          ),

          // ── Body ──
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
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
                    Text('Không thể tải sản phẩm',
                        style: AppTextStyles.subtitle),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _fetchProducts,
                      child: const Text('Thử lại'),
                    ),
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
                    const Icon(Icons.inventory_2_outlined,
                        size: 48, color: AppColors.muted),
                    const SizedBox(height: 12),
                    Text('Không có sản phẩm nào',
                        style: AppTextStyles.subtitle),
                  ],
                ),
              ),
            )
          else
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
