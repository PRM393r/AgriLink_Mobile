import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../widgets/product/product_card.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate mock products for demonstration
    final List<ProductModel> mockProducts = [
      ProductModel(
        id: '1',
        name: 'Dâu tây thủy canh Đà Lạt',
        description: 'Dâu tây trồng nhà màng công nghệ cao ngọt thanh thơm mọng.',
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
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chợ nông sản AgriLink'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm nông sản sạch...',
                prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                filled: true,
                fillColor: AppColors.surfaceSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: mockProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: mockProducts[index],
                  onTap: () {
                    // Navigate to details
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
