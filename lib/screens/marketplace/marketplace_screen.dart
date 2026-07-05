import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/services/api_service.dart';
import '../../router/app_router.dart';
import '../../widgets/product/product_card.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late final ProductRepository _repo;
  final _searchCtrl = TextEditingController();

  List<ProductModel> _products = [];
  List<String> _categories = [];
  String _selectedCategory = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _repo = ProductRepository(ApiService());
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({String? search, String? category}) async {
    setState(() { _loading = true; _error = null; });
    try {
      final catFuture = _categories.isEmpty ? _repo.getCategories() : Future.value(_categories);
      final results = await Future.wait([
        _repo.getProducts(
          search: search?.isEmpty == true ? null : search,
          category: category?.isEmpty == true ? null : category,
          limit: 40,
          sortBy: 'createdAt',
          order: 'desc',
        ),
        catFuture,
      ]);
      setState(() {
        _products = results[0] as List<ProductModel>;
        _categories = results[1] as List<String>;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _onSearch(String value) => _load(search: value.trim(), category: _selectedCategory);

  void _onCategory(String cat) {
    final next = cat == _selectedCategory ? '' : cat;
    setState(() => _selectedCategory = next);
    _load(search: _searchCtrl.text.trim(), category: next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceSoft,
      appBar: AppBar(
        title: const Text('Chợ nông sản AgriLink'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: _onSearch,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm nông sản sạch...',
                prefixIcon: const Icon(Icons.search, color: AppColors.muted),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.muted),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceSoft,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Category chips
          if (_categories.isNotEmpty)
            Container(
              color: Colors.white,
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final selected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => _onCategory(cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.muted,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Product grid
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.muted),
                            const SizedBox(height: 12),
                            Text(_error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.muted)),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () => _load(),
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _products.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.eco_outlined, size: 48, color: AppColors.muted),
                                SizedBox(height: 12),
                                Text('Không tìm thấy sản phẩm',
                                    style: TextStyle(color: AppColors.muted)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _load(
                              search: _searchCtrl.text.trim(),
                              category: _selectedCategory,
                            ),
                            color: AppColors.primary,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.72,
                              ),
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                final p = _products[index];
                                return ProductCard(
                                  product: p,
                                  onTap: () => Navigator.pushNamed(
                                    context,
                                    AppRouter.productDetail,
                                    arguments: p,
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
