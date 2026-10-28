import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_import_cubit.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_import_state.dart';
import 'package:connecthub/features/portfolio_import/presentation/views/cv_preview_view.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/ai_loading_dialog.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';

/// A standalone "Import CV with AI" button card.
///
/// Drop it anywhere in the Portfolio screen — it self-contains the
/// PortfolioImportCubit, handles file picking, shows upload progress,
/// and navigates to the preview screen on success.
class UploadCvButton extends StatelessWidget {
  final String userId;
  final VoidCallback? onImportComplete;
  final bool isCompactGlass;

  const UploadCvButton({
    super.key,
    required this.userId,
    this.onImportComplete,
    this.isCompactGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PortfolioImportCubit(),
      child: _UploadCvButtonBody(
        userId: userId,
        onImportComplete: onImportComplete,
        isCompactGlass: isCompactGlass,
      ),
    );
  }
}

class _UploadCvButtonBody extends StatefulWidget {
  final String userId;
  final VoidCallback? onImportComplete;
  final bool isCompactGlass;

  const _UploadCvButtonBody({
    required this.userId,
    this.onImportComplete,
    this.isCompactGlass = false,
  });

  @override
  State<_UploadCvButtonBody> createState() => _UploadCvButtonBodyState();
}

class _UploadCvButtonBodyState extends State<_UploadCvButtonBody> {
  void _showLoading() {
    AiLoadingDialog.show(context);
  }

  void _hideLoading() {
    AiLoadingDialog.hide(context);
  }

  @override
  void dispose() {
    AiLoadingDialog.hide(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PortfolioImportCubit, PortfolioImportState>(
      listener: (context, state) {
        if (state is PortfolioImportSuccess) {
          _hideLoading();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeTransition(
                opacity: animation,
                child: CvPreviewView(
                  portfolio: state.portfolio,
                  userId: widget.userId,
                  onImportComplete: widget.onImportComplete,
                ),
              ),
              transitionDuration: const Duration(milliseconds: 350),
            ),
          );
        } else if (state is PortfolioImportError) {
          _hideLoading();
          _showError(
            context,
            state.message,
            onRetry: state.canRetry && state.retryFile != null
                ? () {
                    final cubit = context.read<PortfolioImportCubit>();
                    cubit.uploadCv(state.retryFile!);
                  }
                : null,
          );
        } else if (state is PortfolioImportFileSelected) {
          _showLoading();
          // Auto-upload after file is selected
          context.read<PortfolioImportCubit>().uploadCv(state.file);
        } else if (state is PortfolioImportUploading) {
          _showLoading();
        }
      },
      builder: (context, state) {
        final isLoading = state is PortfolioImportUploading ||
            state is PortfolioImportFileSelected;

        if (widget.isCompactGlass) {
          return GestureDetector(
            onTap: isLoading
                ? null
                : () => context.read<PortfolioImportCubit>().pickFile(),
            child: isLoading
                ? _buildCompactGlassLoading(state)
                : _buildCompactGlassIdle(),
          );
        }

        return GestureDetector(
          onTap: isLoading
              ? null
              : () => context.read<PortfolioImportCubit>().pickFile(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.primaryLight.withValues(alpha: 0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLoading
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: isLoading
                ? _buildLoading(state)
                : _buildIdle(),
          ),
        );
      },
    );
  }

  Widget _buildCompactGlassIdle() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: kPortfolioGlassButtonBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPortfolioCardBorder, width: 1),
        boxShadow: kPortfolioSoftShadow,
      ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.description_outlined, color: kPortfolioAccent, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Upload CV',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: kPortfolioTextPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.file_upload_outlined, color: kPortfolioTextMuted, size: 15),
            ],
          ),
        );
      }

  Widget _buildCompactGlassLoading(PortfolioImportState state) {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: kPortfolioGlassButtonBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPortfolioAccent.withValues(alpha: 0.5), width: 1),
        boxShadow: kPortfolioSoftShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: kPortfolioAccent),
          ),
          const SizedBox(width: 8),
          Text(
            'Analyzing...',
            style: TextStyle(
              fontFamily: 'Inter',
              color: kPortfolioAccent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.primary,
            size: 26,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Import CV with AI',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Upload your PDF and let Gemini populate your portfolio automatically.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Upload',
            style: TextStyle(
              color: AppColors.isDark ? const Color(0xFF141210) : Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading(PortfolioImportState state) {
    final label = state is PortfolioImportFileSelected
        ? 'Preparing upload…'
        : 'Analyzing CV with Gemini…';

    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showError(BuildContext context, String message, {VoidCallback? onRetry}) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(
              'AI Service Status',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: Text(
                'Retry',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<PortfolioImportCubit>().reset();
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).then((_) {
      if (context.mounted && context.read<PortfolioImportCubit>().state is PortfolioImportError) {
        context.read<PortfolioImportCubit>().reset();
      }
    });
  }
}
