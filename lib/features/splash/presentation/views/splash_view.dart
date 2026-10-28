import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_state.dart';
import 'package:connecthub/features/home/presentation/views/home_view.dart';
import 'package:connecthub/features/splash/presentation/widgets/splash_logo_header.dart';
import 'package:connecthub/features/splash/presentation/widgets/splash_welcome_actions.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoScaleAnim;
  late final Animation<double> _logoFadeAnim;

  late final AnimationController _welcomeController;
  late final Animation<double> _welcomeFadeAnim;
  late final Animation<Offset> _welcomeSlideAnim;

  bool _showWelcome = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoScaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    _logoFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    _welcomeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _welcomeFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _welcomeController, curve: Curves.easeOut),
    );

    _welcomeSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _welcomeController, curve: Curves.easeOutCubic),
    );

    _logoController.forward();

    // Check auth status
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        context.read<AuthCubit>().checkAuthStatus();
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _welcomeController.dispose();
    super.dispose();
  }

  void _onUnauthenticated() {
    setState(() => _showWelcome = true);
    _welcomeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (_, _, _) => const HomeView(),
              transitionDuration: const Duration(milliseconds: 500),
              transitionsBuilder: (_, anim, _, child) {
                return FadeTransition(opacity: anim, child: child);
              },
            ),
          );
        } else if (state is AuthUnauthenticated) {
          _onUnauthenticated();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: DarkGlassBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  // ── Upper Half: Centered Logo & Brand Experience ─────────
                  Expanded(
                    flex: 5,
                    child: SplashLogoHeader(
                      fadeAnimation: _logoFadeAnim,
                      scaleAnimation: _logoScaleAnim,
                    ),
                  ),

                  // ── Lower Half: Vertically Centered Actions & Welcome ─────
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: _showWelcome
                          ? SplashWelcomeActions(
                              fadeAnimation: _welcomeFadeAnim,
                              slideAnimation: _welcomeSlideAnim,
                            )
                          : const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.lightPrimary,
                                ),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
