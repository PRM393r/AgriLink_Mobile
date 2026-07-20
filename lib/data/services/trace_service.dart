import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/trace_model.dart';
import 'api_service.dart';

class TraceService {
  const TraceService(this._apiService);
  final ApiService _apiService;

  Future<TraceModel> getByCode(String rawCode) async {
    final code = _extractCode(rawCode);
    if (code.isEmpty) throw Exception('Vui lòng nhập mã truy xuất');
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        '${ApiConstants.trace}/${Uri.encodeComponent(code)}',
      );
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) throw Exception('Dữ liệu truy xuất không hợp lệ');
      return TraceModel.fromJson(data);
    } on DioException catch (error) {
      throw Exception(error.error ?? 'Không tìm thấy thông tin truy xuất');
    }
  }

  String _extractCode(String value) {
    final trimmed = value.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last.trim().toUpperCase();
    }
    return trimmed.toUpperCase();
  }
}
