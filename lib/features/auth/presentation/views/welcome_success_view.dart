import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/home/presentation/views/home_view.dart';

/// Clean, minimal, and premium Welcome Screen shown ONLY once after finishing
/// the signup flow (after uploading photo or pressing skip).
///
/// It never appears on login, app reopen, or for existing users.
/// Plays `assets/lottie/done.json` once, centered, with no text, buttons, or
/// progress indicators, then fades smoothly into [HomeView].
class WelcomeSuccessView extends StatefulWidget {
  const WelcomeSuccessView({super.key});

  @override
  State<WelcomeSuccessView> createState() => _WelcomeSuccessViewState();
}

class _WelcomeSuccessViewState extends State<WelcomeSuccessView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _fallbackTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHome();
      }
    });

    // Fallback timer: guarantees transition to Home if animation finishes or hits 2.2s
    _fallbackTimer = Timer(const Duration(milliseconds: 2200), () {
      _navigateToHome();
    });
  }

  void _navigateToHome() {
    if (_navigated || !mounted) return;
    _navigated = true;
    _fallbackTimer?.cancel();

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const HomeView(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Lottie.asset(
          'assets/lottie/done.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward();
          },
          width: 220,
          height: 220,
          fit: BoxFit.contain,
          repeat: false,
        ),
      ),
    );
  }
}
