import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connecthub/features/portfolio_import/data/models/cv_portfolio_model.dart';

/// Failure types for the portfolio import pipeline.
sealed class PortfolioImportFailure {
  const PortfolioImportFailure();
}

class NetworkFailure extends PortfolioImportFailure {
  final String message;
  const NetworkFailure(this.message);
}

class ValidationFailure extends PortfolioImportFailure {
  final String message;
  const ValidationFailure(this.message);
}

class ServerFailure extends PortfolioImportFailure {
  final int statusCode;
  final String message;
  const ServerFailure(this.statusCode, this.message);
}

class TimeoutFailure extends PortfolioImportFailure {
  const TimeoutFailure();
}

/// Abstract contract for the portfolio import repository.
abstract class PortfolioImportRepo {
  /// Upload a PDF [file] to the AI engine, returning structured portfolio data.
  Future<CvPortfolioModel> uploadCv(File file);
}

/// Implementation: sends a multipart request to POST /portfolio/upload-cv.
class PortfolioImportRepoImp implements PortfolioImportRepo {
  final Dio _dio;

  // Backend URL — actual host machine IP on local network.
  // Overridable via --dart-define=AI_BACKEND_URL=http://...:8000
  static const String defaultBaseUrl = String.fromEnvironment(
    'AI_BACKEND_URL',
    defaultValue: 'http://192.168.1.11:8000',
  );

  PortfolioImportRepoImp({Dio? dio, String baseUrl = defaultBaseUrl})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 60),
              receiveTimeout: const Duration(seconds: 180),
              sendTimeout: const Duration(seconds: 120),
              headers: {'Accept': 'application/json'},
            ));

  @override
  Future<CvPortfolioModel> uploadCv(File file) async {
    final startTime = DateTime.now();
    final fileName = file.path.split('/').last.split('\\').last;
    final fileSize = await file.length();
    const endpoint = '/portfolio/upload-cv';
    final fullUrl = '${_dio.options.baseUrl}$endpoint';

    // ignore: avoid_print
    print('================================================================');
    // ignore: avoid_print
    print('[PortfolioImport] --- Upload Request Debug Info ---');
    // ignore: avoid_print
    print('[PortfolioImport] Base URL: ${_dio.options.baseUrl}');
    // ignore: avoid_print
    print('[PortfolioImport] Full URL: $fullUrl');
    // ignore: avoid_print
    print('[PortfolioImport] Request Method: POST');
    // ignore: avoid_print
    print('[PortfolioImport] Headers: ${_dio.options.headers}');
    // ignore: avoid_print
    print('[PortfolioImport] Timeout Values: '
        'connectTimeout=${_dio.options.connectTimeout?.inSeconds}s, '
        'sendTimeout=${_dio.options.sendTimeout?.inSeconds}s, '
        'receiveTimeout=${_dio.options.receiveTimeout?.inSeconds}s');
    // ignore: avoid_print
    print('[PortfolioImport] Content-Type: multipart/form-data (file: application/pdf)');
    // ignore: avoid_print
    print('[PortfolioImport] [Timeline - Start]: $startTime');
    // ignore: avoid_print
    print('[PortfolioImport] [Timeline - File]: $fileName ($fileSize bytes / ${(fileSize / 1024).toStringAsFixed(1)} KB)');
    // ignore: avoid_print
    print('================================================================');

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: DioMediaType('application', 'pdf'),
        ),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        endpoint,
        data: formData,
        onSendProgress: (sent, total) {
          if (total > 0) {
            final progress = (sent / total * 100).toStringAsFixed(1);
            // ignore: avoid_print
            print('[PortfolioImport] [Timeline - Progress]: $sent / $total bytes ($progress%) at ${DateTime.now()}');
          }
        },
      );

      final arrivalTime = DateTime.now();
      final elapsed = arrivalTime.difference(startTime);
      // ignore: avoid_print
      print('[PortfolioImport] [Timeline - Response Arrival]: $arrivalTime (status: ${response.statusCode})');
      // ignore: avoid_print
      print('[PortfolioImport] [Timeline - Total Elapsed]: ${elapsed.inMilliseconds} ms (${(elapsed.inMilliseconds / 1000).toStringAsFixed(2)} s)');

      final data = response.data;
      if (data == null) {
        throw const ServerFailure(500, 'Empty response from server.');
      }

      // Backend wraps result in ApiResponse { data: {...} }
      final payload = data['data'] as Map<String, dynamic>? ?? data;
      return CvPortfolioModel.fromJson(payload);
    } on DioException catch (e) {
      final failTime = DateTime.now();
      final elapsed = failTime.difference(startTime);
      // ignore: avoid_print
      print('[PortfolioImport] [Timeline - Request Failed]: $failTime after ${elapsed.inMilliseconds} ms with ${e.type}: ${e.message}');
      _handleDioError(e);
    }
  }

  Never _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const TimeoutFailure();
      case DioExceptionType.connectionError:
        throw NetworkFailure(
          e.message ?? 'Cannot connect to the AI engine. Is it running?',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final detail = _extractDetail(e.response?.data);
        throw ServerFailure(statusCode, detail);
      default:
        throw NetworkFailure(e.message ?? 'An unexpected error occurred.');
    }
  }

  String _extractDetail(dynamic data) {
    if (data is Map) {
      return (data['detail'] as String?) ??
          (data['message'] as String?) ??
          'Server returned an error.';
    }
    return 'Server returned an error.';
  }
}
