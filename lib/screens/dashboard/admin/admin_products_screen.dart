import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../../widgets/common/loading_overlay.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<AdminRepository>();
      final result = await repo.getProducts(
        search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        limit: 100,
      );
      if (!mounted) return;
      setState(() => _products = List<Map<String, dynamic>>.from(result['items'] as List? ?? []));
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception:', '').trim()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleVisibility(Map<String, dynamic> product) async {
    final id = product['_id'] as String? ?? product['id'] as String;
    final willHide = product['status'] != 'hidden';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(willHide ? 'Ẩn sản phẩm' : 'Khôi phục sản phẩm'),
        content: Text(
          willHide
              ? 'Sản phẩm "${product['name']}" sẽ không hiển thị trên marketplace.'
              : 'Sản phẩm "${product['name']}" sẽ hiển thị trở lại.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(willHide ? 'Ẩn' : 'Khôi phục')),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final repo = context.read<AdminRepository>();
      await repo.setProductVisibility(id, willHide);
      if (!mounted) return;
      setState(() => product['status'] = willHide ? 'hidden' : 'active');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(willHide ? 'Đã ẩn sản phẩm' : 'Đã khôi phục sản phẩm')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString().replaceFirst('Exception:', '').trim()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(title: const Text('Kiểm duyệt sản phẩm')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm theo tên sản phẩm...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
              onSubmitted: (_) => _fetch(),
            ),
          ),
          Expanded(
            child: LoadingOverlay(
              isLoading: _isLoading,
              child: _products.isEmpty && !_isLoading
                  ? const Center(child: Text('Không tìm thấy sản phẩm'))
                  : RefreshIndicator(
                      onRefresh: _fetch,
                      color: AppColors.primary,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _products.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => _buildProductTile(_products[i]),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductTile(Map<String, dynamic> product) {
    final isHidden = product['status'] == 'hidden';
    final images = product['images'] as List?;
    final imageUrl = images != null && images.isNotEmpty ? (images.first as Map)['url'] as String? : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 48,
              height: 48,
              color: AppColors.primaryUltraLight,
              child: imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : const Icon(Icons.eco_outlined, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] as String? ?? '',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  CurrencyFormatter.format((product['pricePerUnit'] as num?)?.toDouble() ?? 0),
                  style: AppTextStyles.caption.copyWith(color: AppColors.muted),
                ),
                if (isHidden)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Đã ẩn', style: TextStyle(color: AppColors.error, fontSize: 11)),
                  ),
              ],
            ),
          ),
          Switch(
            value: !isHidden,
            activeTrackColor: AppColors.primary,
            onChanged: (_) => _toggleVisibility(product),
          ),
        ],
      ),
    );
  }
}
