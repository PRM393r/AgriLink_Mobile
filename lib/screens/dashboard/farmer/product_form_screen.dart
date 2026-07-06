import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../data/services/product_service.dart';
import '../../../widgets/common/agri_button.dart';
import '../../../widgets/common/agri_text_field.dart';

// ponytail: Unified Create and Edit screen. 
// Uses the same form, fills initial values if editing.
class ProductFormScreen extends StatefulWidget {
  final ProductModel? product;
  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _unitCtrl;

  List<String> _existingImages = [];
  List<XFile> _newImages = [];

  bool _isLoading = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product?.name ?? '');
    _descCtrl = TextEditingController(text: widget.product?.description ?? '');
    _priceCtrl = TextEditingController(text: widget.product?.pricePerUnit.toString() ?? '');
    _qtyCtrl = TextEditingController(text: widget.product?.availableQuantity.toString() ?? '');
    _unitCtrl = TextEditingController(text: widget.product?.unit ?? 'kg');
    _existingImages = List.from(widget.product?.images ?? []);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _qtyCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final productService = context.read<ProductService>();
      
      // Upload new images first
      List<String> uploadedUrls = [];
      for (var file in _newImages) {
        final url = await productService.uploadImage(file);
        uploadedUrls.add(url);
      }
      
      final finalImages = [..._existingImages, ...uploadedUrls];
      
      final productData = ProductModel(
        id: widget.product?.id ?? '', // id is ignored by backend on create
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        pricePerUnit: double.tryParse(_priceCtrl.text) ?? 0,
        unit: _unitCtrl.text.trim(),
        availableQuantity: double.tryParse(_qtyCtrl.text) ?? 0,
        minOrderQuantity: widget.product?.minOrderQuantity ?? 1,
        farmingType: widget.product?.farmingType ?? 'conventional',
        status: widget.product?.status ?? 'active',
        viewCount: widget.product?.viewCount ?? 0,
        sellerId: widget.product?.sellerId ?? '',
        sellerType: widget.product?.sellerType ?? '',
        images: finalImages,
        certifications: widget.product?.certifications ?? [],
        category: widget.product?.category ?? 'Rau củ', // Should ideally use a category picker
      );

      if (isEditing) {
        await productService.updateProduct(widget.product!.id, productData);
      } else {
        await productService.publishProduct(productData);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEditing ? 'Cập nhật thành công' : 'Đăng bán thành công')),
        );
        Navigator.pop(context, true); // true indicates success
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa sản phẩm' : 'Thêm sản phẩm mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image picker section
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery);
                        if (picked != null) {
                          setState(() {
                            _newImages.add(picked);
                          });
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.muted.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.muted),
                      ),
                    ),
                    ..._existingImages.map((url) => _buildImageThumbnail(url, isNetwork: true)),
                    ..._newImages.map((file) => _buildImageThumbnail(file, isNetwork: false)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              AgriTextField(
                controller: _nameCtrl,
                labelText: 'Tên sản phẩm',
                hintText: 'VD: Cà chua Cherry',
                validator: (v) => v!.trim().isEmpty ? 'Bắt buộc nhập' : null,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: AgriTextField(
                      controller: _priceCtrl,
                      labelText: 'Đơn giá',
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Chưa hợp lệ' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AgriTextField(
                      controller: _unitCtrl,
                      labelText: 'Đơn vị',
                      hintText: 'kg',
                      validator: (v) => v!.trim().isEmpty ? 'Nhập đ/v' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              AgriTextField(
                controller: _qtyCtrl,
                labelText: 'Số lượng khả dụng',
                hintText: '0',
                keyboardType: TextInputType.number,
                validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Chưa hợp lệ' : null,
              ),
              const SizedBox(height: 16),
              
              AgriTextField(
                controller: _descCtrl,
                labelText: 'Mô tả sản phẩm',
                hintText: 'Nhập thông tin chi tiết...',
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              
              AgriButton(
                text: isEditing ? 'Lưu thay đổi' : 'Đăng bán',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildImageThumbnail(dynamic imageSource, {required bool isNetwork}) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: isNetwork 
                  ? NetworkImage(imageSource as String) 
                  : (kIsWeb 
                      ? NetworkImage((imageSource as XFile).path) 
                      : FileImage(File((imageSource as XFile).path))) as ImageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 16,
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (isNetwork) {
                  _existingImages.remove(imageSource);
                } else {
                  _newImages.remove(imageSource);
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
