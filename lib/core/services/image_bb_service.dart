import 'package:dio/dio.dart';

class ImageBBService {
  static const String _apiKey = '7ac2d4c14cffe9030a779e50c13c84b3';
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  static final Dio _dio = Dio();

  /// Uploads a base64 image file to ImageBB using Dio and returns the direct URL.
  static Future<String?> uploadImage(String base64Image) async {
    try {
      final formData = FormData.fromMap({
        'key': _apiKey,
        'image': base64Image,
      });

      final response = await _dio.post(
        _uploadUrl,
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] != null) {
          return data['data']['url'] as String;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
