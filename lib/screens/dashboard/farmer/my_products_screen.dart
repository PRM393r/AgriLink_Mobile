import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../widgets/common/loading_overlay.dart';
import '../../../widgets/common/empty_state.dart';
import '../../../widgets/product/product_card.dart';
import '../../../router/app_router.dart';
import 'product_form_screen.dart';

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  bool _isLoading = true;
  List<ProductModel> _products = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMyProducts();
  }

  Future<void> _fetchMyProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final productService = context.read<ProductService>();
      final products = await productService.fetchMyProducts();
      if (!mounted) return;
      setState(() {
        _products = products;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_error ?? 'Lỗi tải sản phẩm'),
          backgroundColor: AppColors.error,
        ),
      );
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
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Thêm SP'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: _error != null && _products.isEmpty && !_isLoading
            ? EmptyState(
                icon: Icons.wifi_off_rounded,
                title: 'Không tải được sản phẩm',
                message: _error!,
                actionLabel: 'Thử lại',
                onActionPressed: _fetchMyProducts,
              )
            : _products.isEmpty && !_isLoading
            ? EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Chưa có sản phẩm',
                message: 'Bạn chưa đăng bán sản phẩm nào. Thêm SP để khách hàng đặt hàng.',
                actionLabel: 'Thêm sản phẩm ngay',
                onActionPressed: () => _navigateToForm(),
              )
            : RefreshIndicator(
                onRefresh: _fetchMyProducts,
                color: AppColors.primary,
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return Stack(
                      children: [
                        ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.productDetail,
                              arguments: product,
                            ).then((_) => _fetchMyProducts());
                          },
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                               IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                                  padding: const EdgeInsets.all(6),
                                  minimumSize: Size.zero,
                                ),
                                onPressed: () => _navigateToForm(product),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                                  padding: const EdgeInsets.all(6),
                                  minimumSize: Size.zero,
                                ),
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
