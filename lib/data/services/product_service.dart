import '../models/product_model.dart';
import '../repositories/product_repository.dart';

class ProductService {
  final ProductRepository _productRepository;

  ProductService(this._productRepository);

  Future<List<ProductModel>> fetchMarketplaceProducts({
    String? category,
    String? search,
    String? farmingType,
  }) {
    return _productRepository.getProducts(
      category: category,
      search: search,
      farmingType: farmingType,
    );
  }

  Future<ProductModel> getProductDetails(String id) {
    return _productRepository.getProductById(id);
  }

  Future<ProductModel> publishProduct(ProductModel product) {
    _validateProduct(product);
    return _productRepository.createProduct(product);
  }

  Future<ProductModel> updateProduct(String id, ProductModel product) {
    _validateProduct(product);
    return _productRepository.updateProduct(id, product);
  }

  Future<void> deleteProduct(String id) {
    return _productRepository.deleteProduct(id);
  }

  Future<List<ProductModel>> fetchMyProducts() {
    return _productRepository.getMyProducts();
  }

  void _validateProduct(ProductModel product) {
    if (product.name.trim().isEmpty) {
      throw Exception('Tên sản phẩm không được để trống');
    }
    if (product.pricePerUnit <= 0) {
      throw Exception('Đơn giá phải lớn hơn 0');
    }
    if (product.availableQuantity <= 0) {
      throw Exception('Số lượng bán phải lớn hơn 0');
    }
  }

  Future<List<String>> fetchCategories() {
    return _productRepository.getCategories();
  }

  Future<String> uploadImage(dynamic file) {
    return _productRepository.uploadImage(file);
  }
}
