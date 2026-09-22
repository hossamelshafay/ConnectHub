import 'package:dio/dio.dart';

class ImageUploadResult {
  final String url;
  final String? deleteHash;
  final String? deleteUrl;

  const ImageUploadResult({
    required this.url,
    this.deleteHash,
    this.deleteUrl,
  });
}

class ImageBBService {
  static const String _apiKey = '7ac2d4c14cffe9030a779e50c13c84b3';
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  static final Dio _dio = Dio();

  /// Uploads a base64 image file to ImageBB and returns detailed result including delete hash / delete url.
  static Future<ImageUploadResult?> uploadImageDetailed(String base64Image) async {
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
          final item = data['data'] as Map<String, dynamic>;
          final url = item['url'] as String? ?? '';
          final deleteUrl = item['delete_url'] as String?;
          return ImageUploadResult(
            url: url,
            deleteHash: deleteUrl,
            deleteUrl: deleteUrl,
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Uploads a base64 image file to ImageBB using Dio and returns the direct URL.
  static Future<String?> uploadImage(String base64Image) async {
    final result = await uploadImageDetailed(base64Image);
    return result?.url;
  }

  /// Deletes a remote image from ImgBB using delete hash or delete URL.
  /// If neither is available, leaves hook for future media cleanup.
  static Future<bool> deleteImage({String? deleteHash, String? deleteUrl}) async {
    final target = deleteUrl ?? deleteHash;
    if (target != null && target.isNotEmpty) {
      try {
        if (target.startsWith('http://') || target.startsWith('https://')) {
          await _dio.get(target);
          return true;
        }
        // TODO: Hook for future media cleanup if external hash-based API endpoint is used.
        return true;
      } catch (_) {
        return false;
      }
    }
    // TODO: Hook for future media cleanup if image was uploaded without delete hash/url.
    return false;
  }
}

