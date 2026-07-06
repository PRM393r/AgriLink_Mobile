import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/models/product_model.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/common/animated_list_item.dart';
import '../../router/app_router.dart';

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

  // Generate mock products for demonstration
  final List<ProductModel> mockProducts = [
    ProductModel(
      id: '1',
      name: 'Dâu tây thủy canh Đà Lạt',
      description:
          'Dâu tây trồng nhà màng công nghệ cao ngọt thanh thơm mọng.',
      pricePerUnit: 180000,
      unit: 'kg',
      availableQuantity: 50,
      minOrderQuantity: 1,
      farmingType: 'Hydroponic',
      status: 'active',
      viewCount: 150,
      sellerId: 'seller_123',
      sellerType: 'farmer',
      images: const [],
      certifications: const ['VietGAP'],
      category: 'Trái cây',
    ),
    ProductModel(
      id: '2',
      name: 'Măng tây xanh loại 1',
      description: 'Măng tây xanh giòn ngọt thu hoạch trong ngày.',
      pricePerUnit: 85000,
      unit: 'kg',
      availableQuantity: 120,
      minOrderQuantity: 2,
      farmingType: 'Organic',
      status: 'active',
      viewCount: 89,
      sellerId: 'seller_456',
      sellerType: 'farmer',
      images: const [],
      certifications: const ['Organic'],
      category: 'Rau củ',
    ),
    ProductModel(
      id: '3',
      name: 'Bưởi da xanh Bến Tre',
      description: 'Bưởi da xanh tép vàng mọng nước, ngọt thanh.',
      pricePerUnit: 55000,
      unit: 'quả',
      availableQuantity: 200,
      minOrderQuantity: 1,
      farmingType: 'VietGAP',
      status: 'active',
      viewCount: 65,
      sellerId: 'seller_789',
      sellerType: 'farmer',
      images: const [],
      certifications: const ['VietGAP'],
      category: 'Trái cây',
    ),
    ProductModel(
      id: '4',
      name: 'Cải bó xôi baby',
      description: 'Cải bó xôi baby non mướt giàu dinh dưỡng.',
      pricePerUnit: 45000,
      unit: 'kg',
      availableQuantity: 80,
      minOrderQuantity: 1,
      farmingType: 'Organic',
      status: 'active',
      viewCount: 34,
      sellerId: 'seller_101',
      sellerType: 'farmer',
      images: const [],
      certifications: const ['Organic'],
      category: 'Rau củ',
    ),
  ];

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
                      onTap: () {
                        setState(() => _selectedCategoryIndex = index);
                      },
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
                '${mockProducts.length} sản phẩm',
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
                      product: mockProducts[index],
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRouter.productDetail,
                          arguments: mockProducts[index],
                        );
                      },
                    ),
                  );
                },
                childCount: mockProducts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
