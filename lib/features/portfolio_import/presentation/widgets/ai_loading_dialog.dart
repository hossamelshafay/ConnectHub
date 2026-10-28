import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Rotating status messages for the AI CV upload & analysis overlay.
const List<String> kAiUploadLoadingMessages = [
  'Uploading your CV...',
  'Reading your resume...',
  'Extracting information...',
  'Analyzing your experience...',
  'Matching your skills...',
  'Preparing AI review...',
  'Almost done...',
];

/// Ultra-lightweight AI loading overlay.
///
/// Requirement 5 specifications:
/// - Removed heavy containers, card backgrounds, borders, and shadows.
/// - Keeps ONLY:
///   1. 10% background blur
///   2. Centered Lottie animation
///   3. Rotating loading text
/// - Nothing else. Minimal GPU overhead for smooth 60 FPS on low-end Android devices.
class AiLoadingOverlay extends StatefulWidget {
  final List<String> messages;
  final Duration interval;
  final String lottieAsset;
  final double lottieSize;

  const AiLoadingOverlay({
    super.key,
    this.messages = kAiUploadLoadingMessages,
    this.interval = const Duration(seconds: 2),
    this.lottieAsset = 'assets/lottie/loading-ai.json',
    this.lottieSize = 200,
  });

  @override
  State<AiLoadingOverlay> createState() => _AiLoadingOverlayState();
}

class _AiLoadingOverlayState extends State<AiLoadingOverlay> {
  late int _currentIndex;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _startTimer();
  }

  void _startTimer() {
    _stopTimer();
    if (widget.messages.length <= 1) return;

    _timer = Timer.periodic(widget.interval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.messages.length;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark || AppColors.isDark;

    // Theme-aware typography color (ConnectHub Luxury Warm Titanium palette)
    final textColor = isDark
        ? const Color(0xFFF5F2EC)
        : AppColors.lightTextPrimary;

    final currentMessage = widget.messages.isNotEmpty
        ? widget.messages[_currentIndex]
        : '';

    return RepaintBoundary(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Centered looping Lottie animation
            Lottie.asset(
              widget.lottieAsset,
              width: widget.lottieSize,
              height: widget.lottieSize,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 16),
            // Smoothly fading dynamic status message
            SizedBox(
              height: 40,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: Text(
                    currentMessage,
                    key: ValueKey<int>(_currentIndex),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      letterSpacing: -0.2,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper controller for showing/hiding the non-dismissible [AiLoadingOverlay].
class AiLoadingDialog {
  AiLoadingDialog._();

  static BuildContext? _activeDialogContext;
  static bool _isShowing = false;

  /// Shows the lightweight floating overlay with 10% background blur and no heavy card container.
  static void show(BuildContext context, {List<String>? messages}) {
    if (_isShowing) return;
    _isShowing = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      // Transparent barrier — blur + barrier color together look too dark.
      // We rely solely on the BackdropFilter for the 10% blur effect.
      barrierColor: Colors.transparent,
      useRootNavigator: true,
      builder: (dialogCtx) {
        _activeDialogContext = dialogCtx;
        return PopScope(
          canPop: false,
          // Material(transparency) provides the necessary Material ancestor so
          // that Lottie, Text, and other Material-dependent widgets render
          // correctly inside the dialog without a white card background.
          child: Material(
            type: MaterialType.transparency,
            child: BackdropFilter(
              // Lightweight ~10% background blur
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                color: Colors.black.withValues(alpha: 0.15),
                child: AiLoadingOverlay(
                  messages: messages ?? kAiUploadLoadingMessages,
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _isShowing = false;
      _activeDialogContext = null;
    });
  }

  /// Closes the active loading dialog if it is showing.
  static void hide(BuildContext context) {
    if (_isShowing) {
      if (_activeDialogContext != null && _activeDialogContext!.mounted) {
        Navigator.of(_activeDialogContext!).pop();
      }
      _isShowing = false;
      _activeDialogContext = null;
    }
  }
}
