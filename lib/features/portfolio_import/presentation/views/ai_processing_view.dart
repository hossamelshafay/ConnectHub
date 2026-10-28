import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_import_cubit.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_import_state.dart';
import 'package:connecthub/features/portfolio_import/presentation/views/cv_preview_view.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/ai_processing_widget.dart';

/// Dedicated full-screen AI Processing Screen for CV upload & analysis.
///
/// Follows ConnectHub Feature-First Clean Architecture.
/// - Centered looping Lottie animation (`assets/lottie/loading-ai.json`).
/// - Dynamic status text below the animation, smoothly fading every 2 seconds.
/// - Minimal, elegant luxury design with no AppBar, no buttons, no user interaction required.
/// - Automatically adapts to Light and Dark modes using ConnectHub Luxury Warm Titanium palette.
/// - Automatically navigates to [CvPreviewView] when AI processing completes.
class AiProcessingView extends StatefulWidget {
  final File file;
  final String userId;
  final VoidCallback? onImportComplete;
  final PortfolioImportCubit? cubit;

  const AiProcessingView({
    super.key,
    required this.file,
    required this.userId,
    this.onImportComplete,
    this.cubit,
  });

  @override
  State<AiProcessingView> createState() => _AiProcessingViewState();
}

class _AiProcessingViewState extends State<AiProcessingView> {
  late final PortfolioImportCubit _cubit;
  late final bool _isExternalCubit;
  bool _isRunning = true;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _isExternalCubit = widget.cubit != null;
    _cubit = widget.cubit ?? PortfolioImportCubit();

    // Trigger AI parsing immediately upon entering the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _cubit.uploadCv(widget.file);
      }
    });
  }

  @override
  void dispose() {
    _isRunning = false;
    if (!_isExternalCubit) {
      _cubit.close();
    }
    super.dispose();
  }

  void _onSuccess(PortfolioImportSuccess state) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    // Immediately stop message rotation
    setState(() {
      _isRunning = false;
    });

    // Automatically navigate to the AI Review page with smooth fade transition
    Navigator.pushReplacement(
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
  }

  void _onError(PortfolioImportError state) {
    if (!mounted) return;

    // Pause message rotation while displaying error dialog
    setState(() {
      _isRunning = false;
    });

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(
              'AI Service Status',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          state.message,
          style: TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          if (state.canRetry && state.retryFile != null)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                if (mounted) {
                  setState(() {
                    _isRunning = true;
                  });
                  _cubit.uploadCv(state.retryFile!);
                }
              },
              child: Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark || AppColors.isDark;

    // ConnectHub Luxury Warm Titanium palette:
    // Dark Background: #1A1714
    // Light Background: AppColors.lightBackground (#F4F2EE)
    final backgroundColor =
        isDark ? const Color(0xFF1A1714) : AppColors.lightBackground;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: PopScope(
        // Prevent accidental hardware back button press while processing
        canPop: false,
        child: Scaffold(
          backgroundColor: backgroundColor,
          body: BlocProvider.value(
            value: _cubit,
            child: BlocConsumer<PortfolioImportCubit, PortfolioImportState>(
              listener: (context, state) {
                if (state is PortfolioImportSuccess) {
                  _onSuccess(state);
                } else if (state is PortfolioImportError) {
                  _onError(state);
                }
              },
              builder: (context, state) {
                return SafeArea(
                  child: Center(
                    child: AiProcessingWidget(
                      isRunning: _isRunning,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
