import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/market_price_model.dart';
import 'api_service.dart';

class MarketPriceResult {
  const MarketPriceResult({
    required this.items,
    required this.categories,
    required this.regions,
  });

  final List<MarketPriceModel> items;
  final List<String> categories;
  final List<String> regions;
}

class MarketPriceService {
  const MarketPriceService(this._apiService);

  final ApiService _apiService;

  Future<MarketPriceResult> fetchPrices({String? category, String? region}) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConstants.marketPrices,
        queryParameters: {
          if (category != null) 'category': category,
          if (region != null) 'region': region,
        },
      );
      final data = response.data?['data'] as Map<String, dynamic>? ?? const {};
      final rawItems = data['items'] as List? ?? const [];
      return MarketPriceResult(
        items: rawItems
            .whereType<Map>()
            .map((item) => MarketPriceModel.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
        categories: (data['categories'] as List? ?? const []).map((item) => '$item').toList(),
        regions: (data['regions'] as List? ?? const []).map((item) => '$item').toList(),
      );
    } on DioException catch (error) {
      throw Exception(error.error ?? 'Không tải được giá thị trường');
    }
  }
}
