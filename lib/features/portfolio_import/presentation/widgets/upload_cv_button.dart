import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_import_cubit.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_import_state.dart';
import 'package:connecthub/features/portfolio_import/presentation/views/cv_preview_view.dart';

/// A standalone "Import CV with AI" button card.
///
/// Drop it anywhere in the Portfolio screen — it self-contains the
/// PortfolioImportCubit, handles file picking, shows upload progress,
/// and navigates to the preview screen on success.
class UploadCvButton extends StatelessWidget {
  final String userId;
  final VoidCallback? onImportComplete;

  const UploadCvButton({
    super.key,
    required this.userId,
    this.onImportComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PortfolioImportCubit(),
      child: _UploadCvButtonBody(
        userId: userId,
        onImportComplete: onImportComplete,
      ),
    );
  }
}

class _UploadCvButtonBody extends StatelessWidget {
  final String userId;
  final VoidCallback? onImportComplete;

  const _UploadCvButtonBody({
    required this.userId,
    this.onImportComplete,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PortfolioImportCubit, PortfolioImportState>(
      listener: (context, state) {
        if (state is PortfolioImportSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CvPreviewView(
                portfolio: state.portfolio,
                userId: userId,
                onImportComplete: onImportComplete,
              ),
            ),
          );
        } else if (state is PortfolioImportError) {
          _showError(context, state.message);
        } else if (state is PortfolioImportFileSelected) {
          // Auto-upload after file is selected
          context.read<PortfolioImportCubit>().uploadCv(state.file);
        }
      },
      builder: (context, state) {
        final isLoading = state is PortfolioImportUploading ||
            state is PortfolioImportFileSelected;

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
                  const Color(0xFF38BDF8).withValues(alpha: 0.12),
                  const Color(0xFF818CF8).withValues(alpha: 0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isLoading
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF38BDF8).withValues(alpha: 0.4),
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

  Widget _buildIdle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFF38BDF8),
            size: 26,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Import CV with AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Upload your PDF and let Gemini populate your portfolio automatically.',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
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
            color: const Color(0xFF38BDF8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'Upload',
            style: TextStyle(
              color: Color(0xFF0F172A),
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
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFF38BDF8),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF38BDF8),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showError(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 10),
            Text(
              'Import Failed',
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Color(0xFF94A3B8), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF38BDF8)),
            ),
          ),
        ],
      ),
    );
    // Reset cubit so user can try again
    if (context.mounted) {
      context.read<PortfolioImportCubit>().reset();
    }
  }
}
