import 'dart:io';
import 'package:flutter/foundation.dart' show compute, kIsWeb;
import 'package:dio/dio.dart';
import 'package:connecthub/features/portfolio_import/data/models/cv_portfolio_model.dart';

/// Failure types for the portfolio import pipeline.
sealed class PortfolioImportFailure {
  const PortfolioImportFailure();
}

class AiServiceUnavailableFailure extends PortfolioImportFailure {
  final String message;
  const AiServiceUnavailableFailure([
    this.message =
        'The AI service is temporarily unavailable. Make sure the AI backend server is running on port 8000, or enter your portfolio details manually.',
  ]);
}

class TimeoutFailure extends PortfolioImportFailure {
  final String message;
  const TimeoutFailure([
    this.message =
        'The AI request timed out while processing your CV. Please try again with a smaller file or try again later.',
  ]);
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

class NetworkFailure extends PortfolioImportFailure {
  final String message;
  const NetworkFailure(this.message);
}

/// Abstract contract for the portfolio import repository.
abstract class PortfolioImportRepo {
  /// Upload a PDF [file] to the AI engine, returning structured portfolio data.
  Future<CvPortfolioModel> uploadCv(File file);
}

/// Implementation: sends a multipart request to POST /portfolio/upload-cv.
class PortfolioImportRepoImp implements PortfolioImportRepo {
  final Dio _dio;
  final List<String> _candidateBaseUrls;

  static const String configuredUrl = String.fromEnvironment('AI_BACKEND_URL');

  static List<String> resolveCandidateUrls() {
    if (configuredUrl.isNotEmpty) {
      return [configuredUrl];
    }

    final candidates = <String>[];
    if (kIsWeb) {
      candidates.add('http://127.0.0.1:8000');
      candidates.add('http://localhost:8000');
    } else {
      if (Platform.isAndroid) {
        // 1. Local loopback (fastest with 'adb reverse tcp:8000 tcp:8000' over USB)
        candidates.add('http://127.0.0.1:8000');
        candidates.add('http://localhost:8000');
        // 2. Physical device Wi-Fi IPs (local machine IP on the LAN)
        candidates.add('http://192.168.1.13:8000');
        candidates.add('http://192.168.1.5:8000');
        candidates.add('http://192.168.1.9:8000');
        // 3. Android emulator loopback
        candidates.add('http://10.0.2.2:8000');
      } else {
        candidates.add('http://127.0.0.1:8000');
        candidates.add('http://localhost:8000');
        candidates.add('http://192.168.1.13:8000');
        candidates.add('http://192.168.1.5:8000');
        candidates.add('http://192.168.1.9:8000');
      }
    }
    return candidates;
  }

  PortfolioImportRepoImp({Dio? dio, String? baseUrl})
      : _candidateBaseUrls = baseUrl != null && baseUrl.isNotEmpty
            ? [baseUrl]
            : resolveCandidateUrls(),
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 4),
              receiveTimeout: const Duration(seconds: 300),
              sendTimeout: const Duration(seconds: 180),
              headers: {'Accept': 'application/json'},
            ));

  static String? _cachedWorkingUrl;

  @override
  Future<CvPortfolioModel> uploadCv(File file) async {
    final fileName = file.path.split('/').last.split('\\').last;
    const endpoint = '/portfolio/upload-cv';

    // Prioritize the cached working URL if previously successful
    final candidates = List<String>.from(_candidateBaseUrls);
    if (_cachedWorkingUrl != null && candidates.contains(_cachedWorkingUrl)) {
      candidates.remove(_cachedWorkingUrl);
      candidates.insert(0, _cachedWorkingUrl!);
    }

    DioException? lastException;

    // Try candidate URLs with retries for transient errors
    for (int i = 0; i < candidates.length; i++) {
      final currentBaseUrl = candidates[i];
      final fullUrl = '$currentBaseUrl$endpoint';

      // Allow up to 2 attempts per candidate URL (initial + retry on transient failure)
      for (int attempt = 1; attempt <= 2; attempt++) {
        final startTime = DateTime.now();

        // ignore: avoid_print
        print('[PortfolioImport] Candidate #$i attempt #$attempt: $fullUrl');

        try {
          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(
              file.path,
              filename: fileName,
              contentType: DioMediaType('application', 'pdf'),
            ),
          });

          final response = await _dio.post<Map<String, dynamic>>(
            fullUrl,
            data: formData,
            onSendProgress: (sent, total) {
              if (total > 0) {
                final progress = (sent / total * 100).toStringAsFixed(1);
                // ignore: avoid_print
                print('[PortfolioImport] Progress: $sent/$total ($progress%)');
              }
            },
          );

          final arrivalTime = DateTime.now();
          final elapsed = arrivalTime.difference(startTime);
          // ignore: avoid_print
          print('[PortfolioImport] Success via $currentBaseUrl in ${elapsed.inMilliseconds} ms (status: ${response.statusCode})');

          // Cache this working base URL for instant subsequent requests
          _cachedWorkingUrl = currentBaseUrl;

          final data = response.data;
          if (data == null) {
            throw const ServerFailure(500, 'Empty response from server.');
          }

          final payload = data['data'] as Map<String, dynamic>? ?? data;

          // Parse model in background isolate to keep Flutter UI thread completely responsive
          return await compute(_parsePortfolioModel, payload);
        } on DioException catch (e) {
          lastException = e;
          final isTransient = e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              (e.response?.statusCode != null && e.response!.statusCode! >= 502);

          // ignore: avoid_print
          print('[PortfolioImport] Error on $currentBaseUrl (attempt $attempt): ${e.type} ${e.message}');

          if (isTransient) {
            // For unreachable hosts or connection timeouts, don't waste time retrying the same host
            final isConnectionDown = e.type == DioExceptionType.connectionError ||
                e.type == DioExceptionType.connectionTimeout;
            if (!isConnectionDown && attempt < 2) {
              await Future<void>.delayed(const Duration(milliseconds: 1000));
              continue;
            } else {
              break;
            }
          } else {
            _handleDioError(e);
          }
        }
      }
    }

    if (lastException != null) {
      _handleDioError(lastException);
    }

    throw const AiServiceUnavailableFailure();
  }

  Never _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const TimeoutFailure(
          'The AI request timed out while processing your CV. Large or complex PDFs may take extra time under heavy load. Please try again or enter your details manually.',
        );
      case DioExceptionType.connectionError:
        throw const AiServiceUnavailableFailure(
          'The AI CV parsing service is temporarily unavailable. Make sure the backend server is running on port 8000, or enter your portfolio details manually.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final detail = _extractDetail(e.response?.data);
        throw ServerFailure(statusCode, detail);
      default:
        throw NetworkFailure(
          e.message ?? 'A network communication error occurred with the AI service.',
        );
    }
  }

  String _extractDetail(dynamic data) {
    if (data is Map) {
      return (data['detail'] as String?) ??
          (data['message'] as String?) ??
          'AI server returned an error.';
    }
    return 'AI server returned an error.';
  }
}

/// Parses the AI portfolio JSON in a background isolate to keep the UI smooth.
CvPortfolioModel _parsePortfolioModel(Map<String, dynamic> payload) {
  return CvPortfolioModel.fromJson(payload);
}
