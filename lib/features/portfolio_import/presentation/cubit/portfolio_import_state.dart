import 'dart:io';
import 'package:connecthub/features/portfolio_import/data/models/cv_portfolio_model.dart';

/// States for the AI CV upload & parse pipeline.
sealed class PortfolioImportState {
  const PortfolioImportState();
}

class PortfolioImportInitial extends PortfolioImportState {
  const PortfolioImportInitial();
}

class PortfolioImportFileSelected extends PortfolioImportState {
  final File file;
  const PortfolioImportFileSelected(this.file);
}

class PortfolioImportUploading extends PortfolioImportState {
  const PortfolioImportUploading();
}

class PortfolioImportSuccess extends PortfolioImportState {
  final CvPortfolioModel portfolio;
  const PortfolioImportSuccess(this.portfolio);
}

class PortfolioImportError extends PortfolioImportState {
  final String message;
  const PortfolioImportError(this.message);
}

// ── Portfolio Editor States (CRUD) ───────────────────────────────────────────

sealed class PortfolioEditorState {
  const PortfolioEditorState();
}

class PortfolioEditorIdle extends PortfolioEditorState {
  const PortfolioEditorIdle();
}

class PortfolioEditorSaving extends PortfolioEditorState {
  const PortfolioEditorSaving();
}

class PortfolioEditorSaved extends PortfolioEditorState {
  final String message;
  const PortfolioEditorSaved(this.message);
}

class PortfolioEditorError extends PortfolioEditorState {
  final String message;
  const PortfolioEditorError(this.message);
}
