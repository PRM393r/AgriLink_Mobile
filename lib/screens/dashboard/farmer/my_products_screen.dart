import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../widgets/common/loading_overlay.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/product/product_card.dart';
import 'product_form_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  bool _isLoading = true;
  List<ProductModel> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchMyProducts();
  }

  Future<void> _fetchMyProducts() async {
    setState(() => _isLoading = true);
    try {
      final productService = context.read<ProductService>();
      final products = await productService.fetchMyProducts();
      setState(() {
        _products = products;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text('Bạn có chắc muốn xóa "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy', style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final productService = context.read<ProductService>();
      await productService.deleteProduct(product.id);
      _fetchMyProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _navigateToForm([ProductModel? product]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormScreen(product: product),
      ),
    );
    if (result == true) {
      _fetchMyProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm của tôi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _navigateToForm(),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _products.isEmpty && !_isLoading
            ? EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Chưa có sản phẩm',
                message: 'Bạn chưa đăng bán sản phẩm nào.',
                actionLabel: 'Thêm sản phẩm ngay',
                onActionPressed: () => _navigateToForm(),
              )
            : RefreshIndicator(
                onRefresh: _fetchMyProducts,
                color: AppColors.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _products.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Stack(
                      children: [
                        ProductCard(
                          product: product,
                          onTap: () => _navigateToForm(product),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.primary),
                                style: IconButton.styleFrom(backgroundColor: AppColors.canvas),
                                onPressed: () => _navigateToForm(product),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                style: IconButton.styleFrom(backgroundColor: AppColors.canvas),
                                onPressed: () => _deleteProduct(product),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}
