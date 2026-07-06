import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

class ProductRepository {
  final ApiService _apiService;

  ProductRepository(this._apiService);

  /// Fetches products listing with filters.
  Future<List<ProductModel>> getProducts({
    String? category,
    String? search,
    String? farmingType,
    int? limit,
    String? sortBy,
    String? order,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null && category.isNotEmpty) queryParams['categoryId'] = category;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (farmingType != null && farmingType.isNotEmpty) queryParams['farmingType'] = farmingType;
      if (limit != null) queryParams['limit'] = limit;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (order != null) queryParams['order'] = order;

      final response = await _apiService.get(
        ApiConstants.products,
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final inner = data['data'];
        List? list;
        if (inner is List) {
          list = inner;
        } else if (inner is Map<String, dynamic> && inner['items'] is List) {
          list = inner['items'] as List;
        }
        if (list != null) {
          return list
              .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Lấy danh sách sản phẩm thất bại');
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Fetches single product details by id.
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _apiService.get('${ApiConstants.products}/$id');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return ProductModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Chi tiết sản phẩm không hợp lệ');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Lấy chi tiết sản phẩm thất bại');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  /// Creates a new product.
  Future<ProductModel> createProduct(ProductModel product) async {
    try {
      final response = await _apiService.post(
        ApiConstants.products,
        data: product.toJson()..remove('id'),
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return ProductModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Tạo sản phẩm thất bại');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Đăng bán sản phẩm thất bại');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  /// Updates an existing product.
  Future<ProductModel> updateProduct(String id, ProductModel product) async {
    try {
      final response = await _apiService.patch(
        '${ApiConstants.products}/$id',
        data: product.toJson()..remove('id'),
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] != null) {
        return ProductModel.fromJson(data['data'] as Map<String, dynamic>);
      }
      throw Exception('Cập nhật sản phẩm thất bại');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Cập nhật sản phẩm thất bại');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  /// Deletes a product.
  Future<void> deleteProduct(String id) async {
    try {
      await _apiService.delete('${ApiConstants.products}/$id');
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Xóa sản phẩm thất bại');
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  /// Fetches current user's products.
  Future<List<ProductModel>> getMyProducts() async {
    try {
      final response = await _apiService.get(
        ApiConstants.products,
        queryParameters: {'mine': true},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        final list = data['data'] as List;
        return list.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.error ?? 'Lấy danh sách sản phẩm thất bại');
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  /// Fetches list of categories.
  Future<List<String>> getCategories() async {
    try {
      final response = await _apiService.get(ApiConstants.productCategories);
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return (data['data'] as List).map((e) => e.toString()).toList();
      }
      // Return fallback categories if backend empty
      return ['Rau củ', 'Trái cây', 'Gia vị', 'Thảo dược', 'Hạt dinh dưỡng'];
    } catch (_) {
      return ['Rau củ', 'Trái cây', 'Gia vị', 'Thảo dược', 'Hạt dinh dưỡng'];
    }
  }
}
