import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../data/services/product_service.dart';

class CategoryPickerBottomSheet extends StatefulWidget {
  final String? initialCategory;
  const CategoryPickerBottomSheet({super.key, this.initialCategory});

  static Future<String?> show(BuildContext context, {String? initialCategory}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => CategoryPickerBottomSheet(initialCategory: initialCategory),
    );
  }

  @override
  State<CategoryPickerBottomSheet> createState() => _CategoryPickerBottomSheetState();
}

class _CategoryPickerBottomSheetState extends State<CategoryPickerBottomSheet> {
  List<Map<String, dynamic>> _tree = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTree();
  }

  Future<void> _fetchTree() async {
    try {
      final service = context.read<ProductService>();
      final tree = await service.fetchCategoryTree();
      if (mounted) {
        setState(() {
          _tree = tree;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Chọn danh mục', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 16),
            const Divider(height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _tree.isEmpty
                      ? const Center(child: Text('Không có dữ liệu'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: _tree.length,
                          itemBuilder: (context, index) {
                            final group = _tree[index];
                            final groupName = group['name'] as String? ?? 'Khác';
                            final children = (group['children'] as List<dynamic>?)
                                    ?.map((e) => e.toString())
                                    .toList() ??
                                [];

                            return ExpansionTile(
                              title: Text(groupName,
                                  style: AppTextStyles.subtitle.copyWith(
                                      fontWeight: FontWeight.w600)),
                              children: children.map((child) {
                                final isSelected = child == widget.initialCategory;
                                return ListTile(
                                  title: Text(child, style: AppTextStyles.body),
                                  trailing: isSelected
                                      ? const Icon(Icons.check, color: AppColors.primary)
                                      : null,
                                  onTap: () {
                                    Navigator.pop(context, child);
                                  },
                                );
                              }).toList(),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}
