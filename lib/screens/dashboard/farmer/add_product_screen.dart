import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';
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
  String _category = 'Rau củ';

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Mock submit
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sản phẩm đã được đăng bán thành công!')),
      );
      Navigator.pop(context);
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
                      validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập giá' : null,
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
                validator: (val) => val == null || val.trim().isEmpty ? 'Vui lòng nhập số lượng' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                ),
                items: ['Rau củ', 'Trái cây', 'Gia vị', 'Hạt', 'Khác'].map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _category = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _farmingType,
                decoration: const InputDecoration(
                  labelText: 'Quy trình canh tác',
                ),
                items: [
                  {'id': 'organic', 'name': 'Hữu cơ (Organic)'},
                  {'id': 'vietgap', 'name': 'VietGAP'},
                  {'id': 'conventional', 'name': 'Truyền thống'},
                ].map((type) {
                  return DropdownMenuItem(
                    value: type['id'],
                    child: Text(type['name']!),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _farmingType = val;
                    });
                  }
                },
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
