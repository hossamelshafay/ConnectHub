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

  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5 MB

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
            'File is too large ($mb MB). Maximum allowed size is 5 MB.'));
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
    } on TimeoutFailure {
      emit(const PortfolioImportError(
          'Request timed out. The AI engine may be processing a large CV. Please try again.'));
    } on NetworkFailure catch (e) {
      emit(PortfolioImportError(
          'Network error: ${e.message}\n\nMake sure the AI engine is running.'));
    } on ServerFailure catch (e) {
      emit(_mapServerError(e));
    } catch (e) {
      emit(PortfolioImportError('Unexpected error: ${e.toString()}'));
    }
  }

  PortfolioImportError _mapServerError(ServerFailure e) {
    switch (e.statusCode) {
      case 400:
        return PortfolioImportError('Invalid file: ${e.message}');
      case 413:
        return const PortfolioImportError(
            'File is too large for the server. Maximum allowed size is 5 MB.');
      case 422:
        return PortfolioImportError('Validation error: ${e.message}');
      case 502:
      case 503:
        return const PortfolioImportError(
            'AI service temporarily unavailable. Please try again shortly.');
      case 504:
        return const PortfolioImportError(
            'AI engine timed out. Try again — it may work with a smaller CV.');
      default:
        return PortfolioImportError(
            'Server error (${e.statusCode}): ${e.message}');
    }
  }

  void reset() => emit(const PortfolioImportInitial());
}
