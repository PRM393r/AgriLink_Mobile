import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/auth_provider.dart';
import '../../../widgets/product/product_card.dart';
import '../../../widgets/common/animated_list_item.dart';
import '../../../router/app_router.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  late final ProductRepository _productRepo;
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _recentProducts = [];
  bool _isLoading = true;
  String? _error;

  final List<Map<String, dynamic>> _banners = const [
    {
      'color1': 0xFF1B4332,
      'color2': 0xFF2D6A4F,
      'color3': 0xFF52B788,
      'title': "Nông sản sạch 🌿",
      'desc': "Trực tiếp từ vườn đến tay bạn",
      'icon': Icons.eco_rounded,
    },
    {
      'color1': 0xFFE76F51,
      'color2': 0xFFF4A261,
      'color3': 0xFFFFB703,
      'title': "Giảm 20% 🔥",
      'desc': "Rau củ quả hữu cơ cuối tuần",
      'icon': Icons.local_offer_rounded,
    },
    {
      'color1': 0xFF3B82F6,
      'color2': 0xFF60A5FA,
      'color3': 0xFF93C5FD,
      'title': "Giao hàng nhanh 🚚",
      'desc': "Đặt trước 10h, nhận trong ngày",
      'icon': Icons.local_shipping_rounded,
    }
  ];

  final List<Map<String, String>> _categories = const [
    {'icon': "🥬", 'label': "Rau củ"},
    {'icon': "🍊", 'label': "Trái cây"},
    {'icon': "🌾", 'label': "Lúa gạo"},
    {'icon': "🌱", 'label': "Vật tư"},
    {'icon': "🐟", 'label': "Thủy sản"},
    {'icon': "🍄", 'label': "Nấm"},
  ];

  @override
  void initState() {
    super.initState();
    _productRepo = ProductRepository(ApiService());
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _productRepo.getProducts(limit: 4, sortBy: 'viewCount', order: 'DESC'),
        _productRepo.getProducts(limit: 6, sortBy: 'createdAt', order: 'DESC'),
      ]);
      if (mounted) {
        setState(() {
          _featuredProducts = results[0];
          _recentProducts = results[1];
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

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final displayName =
        user?.fullName.trim().isNotEmpty == true ? user!.fullName : 'bạn';

    return Scaffold(
      backgroundColor: AppColors.surfaceElevated,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 48, color: AppColors.muted),
                      const SizedBox(height: 12),
                      Text('Không tải được sản phẩm', style: AppTextStyles.body),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadProducts,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadProducts,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // ── Custom header with greeting + search ──
                      SliverToBoxAdapter(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                              20, MediaQuery.of(context).padding.top + 16, 20, 24),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF1B4332),
                                Color(0xFF2D6A4F),
                                Color(0xFF40916C),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius:
                                BorderRadius.vertical(bottom: Radius.circular(28)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Greeting row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Xin chào, $displayName! 👋',
                                          style: AppTextStyles.sectionTitle.copyWith(
                                            color: AppColors.canvas,
                                            fontSize: 22,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Hôm nay bạn muốn mua gì?',
                                          style: AppTextStyles.subtitle.copyWith(
                                            color: AppColors.canvas.withValues(alpha: 0.75),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Action buttons
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () =>
                                            Navigator.pushNamed(context, AppRouter.wishlist),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.canvas.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.favorite_border,
                                            color: AppColors.error,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                    onTap: () =>
                                        Navigator.pushNamed(context, AppRouter.cart),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.canvas.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.shopping_cart_outlined,
                                            color: AppColors.canvas,
                                            size: 22,
                                          ),
                                        ),
                                        if (cartProvider.totalItems > 0)
                                          Positioned(
                                            right: -4,
                                            top: -4,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                color: AppColors.accentActive,
                                                shape: BoxShape.circle,
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 18,
                                                minHeight: 18,
                                              ),
                                              child: Text(
                                                '${cartProvider.totalItems}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                            // Search bar
                              GestureDetector(
                                onTap: () =>
                                    Navigator.pushNamed(context, AppRouter.marketplace),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.canvas.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: AppColors.canvas.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.search_rounded,
                                          color: AppColors.canvas.withValues(alpha: 0.7),
                                          size: 20),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Tìm kiếm nông sản sạch...',
                                        style: AppTextStyles.subtitle.copyWith(
                                          color: AppColors.canvas.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Banners ──
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: _buildBanners(),
                        ),
                      ),

                      // ── Categories ──
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: _buildCategories(),
                        ),
                      ),

                      // ── Featured products header ──
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Sản phẩm nổi bật',
                                    style: AppTextStyles.sectionTitle.copyWith(
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('🔥', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, AppRouter.marketplace);
                                },
                                child: Text(
                                  'Xem tất cả',
                                  style: AppTextStyles.subtitle.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Featured grid ──
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = _featuredProducts[index];
                              return AnimatedListItem(
                                index: index,
                                child: ProductCard(
                                  product: product,
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRouter.productDetail,
                                      arguments: product,
                                    );
                                  },
                                ),
                              );
                            },
                            childCount: _featuredProducts.length,
                          ),
                        ),
                      ),

                      // ── Recent products header ──
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                          child: Text(
                            'Mới đăng gần đây ✨',
                            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
                          ),
                        ),
                      ),

                      // ── Recent horizontal list ──
                      SliverToBoxAdapter(child: _buildRecentList()),

                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBanners() {
    return Column(
      children: [
        SizedBox(
          height: 155,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() => _currentBannerIndex = index);
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Color(banner['color1'] as int),
                      Color(banner['color2'] as int),
                      Color(banner['color3'] as int),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: AppShadows.colored(
                    Color(banner['color1'] as int),
                    opacity: 0.25,
                  ),
                ),
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            banner['title'] as String,
                            style: AppTextStyles.sectionTitle.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            banner['desc'] as String,
                            style: AppTextStyles.subtitle.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        banner['icon'] as IconData,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentBannerIndex == index ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentBannerIndex == index
                    ? AppColors.primary
                    : AppColors.muted.withValues(alpha: 0.25),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Danh mục ngành hàng',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              AppColors.surfaceDivider.withValues(alpha: 0.3),
                        ),
                        boxShadow: AppShadows.card,
                      ),
                      child: Center(
                        child: Text(
                          cat['icon']!,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['label']!,
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentList() {
    return SizedBox(
      height: 245,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _recentProducts.length,
        itemBuilder: (context, index) {
          final product = _recentProducts[index];
          return Container(
            width: 165,
            margin: const EdgeInsets.only(right: 12),
            child: ProductCard(
              product: product,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRouter.productDetail,
                  arguments: product,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
