import 'package:dio/dio.dart';

class AIChatService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://hossamelshafay1.app.n8n.cloud',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    headers: {'Content-Type': 'application/json'},
  ));

  /// Sends a message to the AI chatbot and returns the response.
  static Future<String> sendMessage(String message) async {
    try {
      final response = await _dio.post(
        '/webhook/chat',
        data: {'message': message},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          return data['output']?.toString() ?? 'No response from AI.';
        }
        return data.toString();
      }
      return 'Error: Unable to get response.';
    } on DioException catch (e) {
      return 'Error: ${e.message ?? 'Connection failed. Please try again.'}';
    } catch (e) {
      return 'Error: Something went wrong. Please try again.';
    }
  }
}
