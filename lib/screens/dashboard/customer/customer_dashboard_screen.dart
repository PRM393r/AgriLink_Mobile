import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/cart_provider.dart';
import '../../../widgets/product/product_card.dart';
import '../../../router/app_router.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;

  final List<Map<String, dynamic>> _banners = const [
    {
      'color1': 0xFF2D6A4F,
      'color2': 0xFF1B4332,
      'title': "Nông sản sạch",
      'desc': "Trực tiếp từ vườn đến tay bạn"
    },
    {
      'color1': 0xFF52B788,
      'color2': 0xFF2D6A4F,
      'title': "Giảm 20%",
      'desc': "Rau củ quả hữu cơ cuối tuần"
    },
    {
      'color1': 0xFFF4A261,
      'color2': 0xFFE76F51,
      'title': "Giao hàng nhanh",
      'desc': "Đặt trước 10h, nhận trong ngày"
    }
  ];

  final List<Map<String, String>> _categories = const [
    {'icon': "🥬", 'label': "Rau củ"},
    {'icon': "🍊", 'label': "Trái cây"},
    {'icon': "🌾", 'label': "Lúa gạo"},
    {'icon': "🌱", 'label': "Vật tư"},
    {'icon': "🐟", 'label': "Thủy sản"}
  ];

  final List<ProductModel> _featuredProducts = [
    ProductModel(
      id: "f1",
      name: "Cà chua bi organic",
      description: "Cà chua ngọt lịm trồng theo tiêu chuẩn hữu cơ tại Đà Lạt",
      pricePerUnit: 35000,
      unit: "kg",
      availableQuantity: 150,
      minOrderQuantity: 1,
      farmingType: "Organic",
      status: "active",
      viewCount: 42,
      sellerId: "seller_dalat_farm",
      sellerType: "farmer",
      images: const [],
      certifications: const ["Organic"],
      category: "Rau củ",
    ),
    ProductModel(
      id: "f2",
      name: "Gạo ST25",
      description: "Gạo đặc sản ST25 thơm ngon, dẻo ngọt đạt danh hiệu gạo ngon nhất thế giới",
      pricePerUnit: 28000,
      unit: "kg",
      availableQuantity: 500,
      minOrderQuantity: 5,
      farmingType: "VietGAP",
      status: "active",
      viewCount: 120,
      sellerId: "seller_an_giang_coop",
      sellerType: "cooperative",
      images: const [],
      certifications: const ["VietGAP"],
      category: "Lúa gạo",
    ),
    ProductModel(
      id: "f3",
      name: "Xoài cát Hòa Lộc",
      description: "Xoài chín cây thơm lừng ngọt đậm đà vùng Tiền Giang",
      pricePerUnit: 65000,
      unit: "kg",
      availableQuantity: 80,
      minOrderQuantity: 1,
      farmingType: "Organic",
      status: "active",
      viewCount: 76,
      sellerId: "seller_tg_fruit",
      sellerType: "farmer",
      images: const [],
      certifications: const ["Organic"],
      category: "Trái cây",
    ),
    ProductModel(
      id: "f4",
      name: "Rau muống sạch",
      description: "Rau muống non mướt, giòn ngọt canh tác VietGAP tại Củ Chi",
      pricePerUnit: 12000,
      unit: "bó",
      availableQuantity: 300,
      minOrderQuantity: 1,
      farmingType: "VietGAP",
      status: "active",
      viewCount: 50,
      sellerId: "seller_cuchi_coop",
      sellerType: "cooperative",
      images: const [],
      certifications: const ["VietGAP"],
      category: "Rau củ",
    ),
  ];

  final List<ProductModel> _recentProducts = [
    ProductModel(
      id: "r1",
      name: "Cà rốt Đà Lạt",
      description: "Cà rốt củ to ngọt, tươi ngon mới nhổ buổi sáng",
      pricePerUnit: 22000,
      unit: "kg",
      availableQuantity: 200,
      minOrderQuantity: 1,
      farmingType: "VietGAP",
      status: "active",
      viewCount: 15,
      sellerId: "seller_dalat_farm",
      sellerType: "farmer",
      images: const [],
      certifications: const ["VietGAP"],
      category: "Rau củ",
    ),
    ProductModel(
      id: "r2",
      name: "Dưa hấu Long An",
      description: "Dưa hấu ruột đỏ ngọt lịm mọng nước đặc sản Long An",
      pricePerUnit: 15000,
      unit: "kg",
      availableQuantity: 400,
      minOrderQuantity: 2,
      farmingType: "VietGAP",
      status: "active",
      viewCount: 29,
      sellerId: "seller_la_fruit",
      sellerType: "farmer",
      images: const [],
      certifications: const ["VietGAP"],
      category: "Trái cây",
    ),
    ProductModel(
      id: "r3",
      name: "Nấm rơm sạch",
      description: "Nấm rơm tự nhiên, béo ngọt dinh dưỡng cao",
      pricePerUnit: 90000,
      unit: "kg",
      availableQuantity: 50,
      minOrderQuantity: 0.5,
      farmingType: "Organic",
      status: "active",
      viewCount: 61,
      sellerId: "seller_cuchi_coop",
      sellerType: "cooperative",
      images: const [],
      certifications: const ["Organic"],
      category: "Rau củ",
    ),
  ];

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trang chủ',
          style: AppTextStyles.sectionTitle.copyWith(color: AppColors.ink),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.ink),
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.cart);
                },
              ),
              if (cartProvider.totalItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.accentActive,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartProvider.totalItems}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        color: AppColors.surfaceSoft,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner slider
              _buildBanners(),
              const SizedBox(height: 24),

              // Categories
              _buildCategories(),
              const SizedBox(height: 24),

              // Featured products
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sản phẩm nổi bật',
                      style: AppTextStyles.sectionTitle.copyWith(color: AppColors.ink),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.marketplace);
                      },
                      child: Text(
                        'Xem tất cả',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildFeaturedGrid(),
              const SizedBox(height: 24),

              // Recently added
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Mới đăng gần đây',
                  style: AppTextStyles.sectionTitle.copyWith(color: AppColors.ink),
                ),
              ),
              const SizedBox(height: 12),
              _buildRecentList(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBanners() {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Color(banner['color1'] as int),
                      Color(banner['color2'] as int),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(banner['color1'] as int).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      banner['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      banner['desc'] as String,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentBannerIndex == index ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentBannerIndex == index
                    ? AppColors.primary
                    : AppColors.muted.withValues(alpha: 0.5),
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Danh mục ngành hàng',
            style: AppTextStyles.sectionTitle.copyWith(color: AppColors.ink),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        cat['icon']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat['label']!,
                      style: AppTextStyles.caption.copyWith(
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

  Widget _buildFeaturedGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: _featuredProducts.length,
      itemBuilder: (context, index) {
        final product = _featuredProducts[index];
        return ProductCard(
          product: product,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.productDetail,
              arguments: product,
            );
          },
        );
      },
    );
  }

  Widget _buildRecentList() {
    return SizedBox(
      height: 235,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _recentProducts.length,
        itemBuilder: (context, index) {
          final product = _recentProducts[index];
          return Container(
            width: 160,
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
