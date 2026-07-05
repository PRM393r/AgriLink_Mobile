import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/product_model.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/services/api_service.dart';
import '../../../widgets/common/agri_button.dart';
import '../../../widgets/common/agri_text_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _quantityController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _farmingType = 'organic';
  String _category = 'Rau củ quả';
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final repo = ProductRepository(ApiService());
      await repo.createProduct(ProductModel(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        pricePerUnit: double.parse(_priceController.text.trim()),
        unit: _unitController.text.trim(),
        availableQuantity: double.parse(_quantityController.text.trim()),
        minOrderQuantity: 1,
        farmingType: _farmingType,
        status: 'active',
        viewCount: 0,
        sellerId: '',
        sellerType: '',
        images: const [],
        certifications: const [],
        category: _category,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sản phẩm đã được đăng bán thành công!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng bán sản phẩm'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin nông sản',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 16),
              AgriTextField(
                controller: _nameController,
                labelText: 'Tên sản phẩm',
                hintText: 'Ví dụ: Cà chua Lâm Đồng',
                validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập tên sản phẩm' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AgriTextField(
                      controller: _priceController,
                      labelText: 'Giá bán (VND)',
                      hintText: 'Ví dụ: 25000',
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Vui lòng nhập giá';
                        if (double.tryParse(val.trim()) == null) return 'Giá không hợp lệ';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AgriTextField(
                      controller: _unitController,
                      labelText: 'Đơn vị tính',
                      hintText: 'Ví dụ: kg, bó, quả',
                      validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập đơn vị' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AgriTextField(
                controller: _quantityController,
                labelText: 'Số lượng khả dụng',
                hintText: 'Ví dụ: 100',
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Vui lòng nhập số lượng';
                  if (double.tryParse(val.trim()) == null) return 'Số lượng không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Danh mục'),
                items: [
                  'Rau củ quả', 'Trái cây', 'Lúa gạo & Ngũ cốc',
                  'Thủy sản', 'Gia súc & Gia cầm', 'Cà phê & Chè',
                  'Gia vị & Thảo mộc', 'Hạt & Đậu',
                  'Nông cụ & Máy móc', 'Phân bón & Thuốc BVTV', 'Hạt giống & Cây giống',
                ].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) { if (val != null) setState(() => _category = val); },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _farmingType,
                decoration: const InputDecoration(labelText: 'Quy trình canh tác'),
                items: [
                  {'id': 'organic', 'name': 'Hữu cơ (Organic)'},
                  {'id': 'vietgap', 'name': 'VietGAP'},
                  {'id': 'hydroponic', 'name': 'Thủy canh'},
                  {'id': 'conventional', 'name': 'Truyền thống'},
                ].map((type) => DropdownMenuItem(
                  value: type['id'],
                  child: Text(type['name']!),
                )).toList(),
                onChanged: (val) { if (val != null) setState(() => _farmingType = val); },
              ),
              const SizedBox(height: 16),
              AgriTextField(
                controller: _descriptionController,
                labelText: 'Mô tả chi tiết',
                hintText: 'Nhập thông tin xuất xứ, chất lượng, cách bảo quản...',
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 32),
              AgriButton(
                text: 'Đăng bán sản phẩm',
                onPressed: _submit,
                isLoading: _submitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
