import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Default rotating status messages displayed while AI processes a CV.
const List<String> kDefaultAiProcessingMessages = [
  'Preparing your document...',
  'Uploading your CV...',
  'Initializing AI engine...',
  'Analyzing your resume...',
  'Identifying your skills...',
  'Reviewing your experience...',
  'Evaluating your qualifications...',
  'Generating personalized insights...',
  'Building your AI report...',
  'Finalizing analysis...',
];

/// Premium, minimal, reusable AI processing indicator.
///
/// Displays a centered looping Lottie animation with a single dynamic status
/// message below it that smoothly fades into the next message every [interval].
class AiProcessingWidget extends StatefulWidget {
  final List<String> messages;
  final Duration interval;
  final String lottieAsset;
  final double lottieSize;
  final TextStyle? textStyle;
  final bool isRunning;

  const AiProcessingWidget({
    super.key,
    this.messages = kDefaultAiProcessingMessages,
    this.interval = const Duration(seconds: 2),
    this.lottieAsset = 'assets/lottie/loading-ai.json',
    this.lottieSize = 240,
    this.textStyle,
    this.isRunning = true,
  });

  @override
  State<AiProcessingWidget> createState() => _AiProcessingWidgetState();
}

class _AiProcessingWidgetState extends State<AiProcessingWidget> {
  late int _currentIndex;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    if (widget.isRunning) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(covariant AiProcessingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRunning != widget.isRunning) {
      if (widget.isRunning) {
        _startTimer();
      } else {
        _stopTimer();
      }
    }
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
    final isDark = Theme.of(context).brightness == Brightness.dark || AppColors.isDark;

    // ConnectHub Luxury Warm Titanium palette
    final defaultTextColor = isDark
        ? const Color(0xFFF5F2EC) // Primary Text (Dark)
        : AppColors.lightTextPrimary; // Primary Text (Light)

    final effectiveTextStyle = widget.textStyle ??
        TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: defaultTextColor,
          letterSpacing: -0.2,
          height: 1.4,
        );

    final currentMessage = widget.messages.isNotEmpty
        ? widget.messages[_currentIndex]
        : '';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Centered looping Lottie animation
            Lottie.asset(
              widget.lottieAsset,
              width: widget.lottieSize,
              height: widget.lottieSize,
              fit: BoxFit.contain,
              repeat: true,
            ),
            const SizedBox(height: 28),
            // Smoothly fading dynamic status message
            SizedBox(
              height: 48,
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    currentMessage,
                    key: ValueKey<int>(_currentIndex),
                    textAlign: TextAlign.center,
                    style: effectiveTextStyle,
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
