import 'api_service.dart';

class GeographyProvince {
  final String id;
  final String name;

  GeographyProvince({required this.id, required this.name});

  factory GeographyProvince.fromJson(Map<String, dynamic> json) {
    return GeographyProvince(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class GeographyDistrict {
  final String id;
  final String name;
  final String provinceId;

  GeographyDistrict({
    required this.id,
    required this.name,
    required this.provinceId,
  });

  factory GeographyDistrict.fromJson(Map<String, dynamic> json) {
    return GeographyDistrict(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      provinceId: json['provinceId'] as String? ?? '',
    );
  }
}

class GeographyService {
  final ApiService _apiService;

  GeographyService(this._apiService);

  Future<List<GeographyProvince>> getProvinces() async {
    try {
      final response = await _apiService.get('/geography/provinces');
      final envelope = response.data as Map<String, dynamic>?;
      final list = envelope?['data'] as List<dynamic>? ?? [];
      return list
          .map((item) => GeographyProvince.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Lấy danh sách tỉnh thành thất bại: $e');
    }
  }

  Future<List<GeographyDistrict>> getDistricts(String provinceId) async {
    try {
      final response = await _apiService.get(
        '/geography/districts',
        queryParameters: {'provinceId': provinceId},
      );
      final envelope = response.data as Map<String, dynamic>?;
      final list = envelope?['data'] as List<dynamic>? ?? [];
      return list
          .map((item) => GeographyDistrict.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Lấy danh sách quận huyện thất bại: $e');
    }
  }
}
