import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/auth/presentation/views/login_view.dart';
import 'package:connecthub/features/auth/presentation/views/signup_view.dart';

/// Animated welcome CTAs, feature pills, and footer for SplashView.
class SplashWelcomeActions extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const SplashWelcomeActions({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Feature pills
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: const [
                _FeaturePill(icon: Icons.hub_outlined, label: 'Network'),
                _FeaturePill(icon: Icons.language_rounded, label: 'Portfolio'),
                _FeaturePill(icon: Icons.auto_awesome_rounded, label: 'AI Assistant'),
              ],
            ),
            const SizedBox(height: 32),

            // CTA Buttons with Apple-grade touch targets
            PrimaryButton(
              text: 'Create an Account',
              height: 52,
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, _, _) => const SignupView(),
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder: (_, anim, _, child) {
                      return FadeTransition(
                        opacity: anim,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            SecondaryButton(
              text: 'Sign In to Workspace',
              height: 52,
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, _, _) => const LoginView(),
                    transitionDuration: const Duration(milliseconds: 300),
                    transitionsBuilder: (_, anim, _, child) {
                      return FadeTransition(
                        opacity: anim,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Designed with Apple-grade precision',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textHint,
                fontSize: 12,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}
