import '../models/product_model.dart';
import 'api_service.dart';

class WishlistService {
  final ApiService _apiService;

  WishlistService(this._apiService);

  Future<List<ProductModel>> getWishlist() async {
    try {
      final response = await _apiService.get('/wishlists');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        final list = data['data'] as List;
        return list.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      // Return empty if fail (ponytail: ignore complex error handling for MVP wishlist)
      return [];
    }
  }

  Future<List<String>> getWishlistIds() async {
    try {
      final response = await _apiService.get('/wishlists/ids');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        final list = data['data'] as List;
        return list.map((id) => id.toString()).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> toggleWishlist(String productId) async {
    try {
      final response = await _apiService.post('/wishlists/toggle/$productId');
      if (response.data is Map<String, dynamic>) {
        return response.data['isWishlisted'] ?? false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
