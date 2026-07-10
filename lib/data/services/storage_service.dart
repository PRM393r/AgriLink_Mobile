import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/api_constants.dart';
import 'api_service.dart';

class StorageService {
  final ApiService _apiService;

  StorageService(this._apiService);

  Future<String> uploadImage(XFile file) async {
    final bytes = await file.readAsBytes();
    final fileName = file.name.isNotEmpty ? file.name : 'agrilink-image.jpg';

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: fileName),
    });

    final response = await _apiService.post(
      '${ApiConstants.storage}/images/upload',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final envelope = response.data as Map<String, dynamic>?;
    final data = envelope?['data'] as Map<String, dynamic>?;
    final url = data?['url'] as String? ?? '';
    if (url.isEmpty) {
      throw Exception('Upload ảnh thất bại: phản hồi không có URL');
    }
    return url;
  }
}
