import '../models/review_model.dart';
import 'api_service.dart';

class ReviewService {
  final ApiService _apiService;

  ReviewService(this._apiService);

  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {
      final response = await _apiService.get('/reviews/product/$productId');
      final data = response.data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        final list = data['data'] as List;
        return list
            .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      // Bỏ qua lỗi phức tạp cho MVP
      return [];
    }
  }

  Future<bool> submitReview({
    required String productId,
    required String orderId,
    required double rating,
    required String comment,
  }) async {
    try {
      final response = await _apiService.post('/reviews', data: {
        'productId': productId,
        'orderId': orderId,
        'rating': rating,
        'comment': comment,
      });
      // Nếu thành công (201) sẽ trả về statusCode == 200/201
      return true;
    } catch (e) {
      throw Exception('Không thể gửi đánh giá: $e');
    }
  }
}
