import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:connecthub/features/portfolio_import/data/repos/portfolio_import_repo.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_import_state.dart';

/// Manages the full AI CV import pipeline:
/// file selection → upload → parse → preview.
class PortfolioImportCubit extends Cubit<PortfolioImportState> {
  final PortfolioImportRepo _repo;

  PortfolioImportCubit({PortfolioImportRepo? repo})
      : _repo = repo ?? PortfolioImportRepoImp(),
        super(const PortfolioImportInitial());

  static const int _maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB

  /// Opens the OS file picker, validates selection, emits [PortfolioImportFileSelected].
  Future<void> pickFile() async {
    try {
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (picked == null) return;
      if (picked.path == null) {
        emit(const PortfolioImportError('Could not access the selected file.'));
        return;
      }

      final file = File(picked.path!);
      final size = await file.length();

      if (size == 0) {
        emit(const PortfolioImportError('The selected file is empty.'));
        return;
      }

      if (size > _maxFileSizeBytes) {
        final mb = (size / 1024 / 1024).toStringAsFixed(1);
        emit(PortfolioImportError(
            'File is too large ($mb MB). Maximum allowed size is 10 MB.'));
        return;
      }

      emit(PortfolioImportFileSelected(file));
    } catch (e) {
      emit(PortfolioImportError('Failed to pick file: ${e.toString()}'));
    }
  }

  /// Uploads the [file] to the AI engine and parses it.
  Future<void> uploadCv(File file) async {
    emit(const PortfolioImportUploading());
    try {
      final portfolio = await _repo.uploadCv(file);
      emit(PortfolioImportSuccess(portfolio));
    } on AiServiceUnavailableFailure catch (e) {
      emit(PortfolioImportError(
        e.message,
        canRetry: true,
        retryFile: file,
      ));
    } on TimeoutFailure catch (e) {
      emit(PortfolioImportError(
        e.message,
        canRetry: true,
        retryFile: file,
      ));
    } on ValidationFailure catch (e) {
      emit(PortfolioImportError(e.message));
    } on ServerFailure catch (e) {
      emit(_mapServerError(e, file));
    } on NetworkFailure catch (e) {
      emit(PortfolioImportError(
        'AI engine network error: ${e.message}\n\nPlease check your network or enter portfolio details manually.',
        canRetry: true,
        retryFile: file,
      ));
    } catch (e) {
      emit(PortfolioImportError(
        'Unexpected error parsing CV: ${e.toString()}',
        canRetry: true,
        retryFile: file,
      ));
    }
  }

  PortfolioImportError _mapServerError(ServerFailure e, File file) {
    switch (e.statusCode) {
      case 400:
        return PortfolioImportError('Invalid CV file: ${e.message}');
      case 413:
        return const PortfolioImportError(
            'The CV file exceeds the maximum 10 MB limit. Please select a smaller PDF.');
      case 422:
        return PortfolioImportError('CV document format unreadable: ${e.message}');
      case 502:
      case 503:
        return PortfolioImportError(
          'AI service temporarily unavailable. Please try again shortly or fill in your details manually.',
          canRetry: true,
          retryFile: file,
        );
      case 504:
        return PortfolioImportError(
          'AI engine timed out analyzing this CV. Try again or try with a smaller PDF.',
          canRetry: true,
          retryFile: file,
        );
      default:
        return PortfolioImportError(
          'Server error (${e.statusCode}): ${e.message}',
          canRetry: true,
          retryFile: file,
        );
    }
  }

  void reset() => emit(const PortfolioImportInitial());
}
