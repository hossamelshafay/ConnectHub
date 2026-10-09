import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';
import '../animations/gold_shimmer.dart';
import '../animations/entrance_fader.dart';
import '../widgets/animated_glow_button.dart';

/// Luxury Black + Gold 404 Page when a user portfolio does not exist in Firestore.
class PortfolioNotFoundView extends StatelessWidget {
  final String? identifier;
  final VoidCallback? onRetry;
  final VoidCallback? onHome;

  const PortfolioNotFoundView({
    super.key,
    this.identifier,
    this.onRetry,
    this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final displayId = (identifier != null && identifier!.isNotEmpty)
        ? identifier!
        : 'requested';

    return Container(
      color: WebColors.background,
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: SingleChildScrollView(
          child: EntranceFader(
            offset: const Offset(0, 20),
            duration: const Duration(milliseconds: 600),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Metallic 404 Emblem
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          WebColors.primary.withValues(alpha: 0.25),
                          WebColors.surfaceCard,
                        ],
                      ),
                      border: Border.all(
                        color: WebColors.border,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: WebColors.primary.withValues(alpha: 0.2),
                          blurRadius: 36,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_search_rounded,
                        size: 48,
                        color: WebColors.primaryLight,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 404 Numerical Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: WebColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: WebColors.border),
                    ),
                    child: const Text(
                      'ERROR 404',
                      style: TextStyle(
                        color: WebColors.secondaryAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title with Gold Shimmer
                  GoldShimmerText(
                    child: Text(
                      'Portfolio Not Found',
                      textAlign: TextAlign.center,
                      style: WebTextStyles.sectionTitle(isDark: true).copyWith(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Message
                  Text(
                    'We could not find an engineering portfolio matching "$displayId". '
                    'The profile may have been modified, removed, or the link may be incorrect.',
                    style: WebTextStyles.bodyMedium(isDark: true).copyWith(
                      fontSize: 15,
                      color: WebColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 36),

                  // Action Buttons
                  Wrap(
                    spacing: 16,
                    runSpacing: 14,
                    alignment: WrapAlignment.center,
                    children: [
                      if (onRetry != null)
                        AnimatedGlowButton(
                          label: 'Try Again',
                          icon: Icons.refresh_rounded,
                          onTap: onRetry!,
                        ),
                      if (onHome != null)
                        AnimatedGlowButton(
                          label: 'ConnectHub Home',
                          icon: Icons.home_rounded,
                          onTap: onHome!,
                          isSecondary: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Luxury Black + Gold Offline View when user internet is unavailable.
class PortfolioOfflineView extends StatelessWidget {
  final VoidCallback onRetry;

  const PortfolioOfflineView({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WebColors.background,
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: SingleChildScrollView(
          child: EntranceFader(
            offset: const Offset(0, 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: WebColors.surfaceCard,
                      border: Border.all(
                        color: WebColors.accent.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: WebColors.accent.withValues(alpha: 0.18),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.wifi_off_rounded,
                        size: 44,
                        color: WebColors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  GoldShimmerText(
                    child: Text(
                      'Connection Unavailable',
                      textAlign: TextAlign.center,
                      style: WebTextStyles.sectionTitle(isDark: true).copyWith(
                        fontSize: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'You appear to be offline. ConnectHub requires an active internet connection to stream portfolio data from Firebase.',
                    style: WebTextStyles.bodyMedium(isDark: true).copyWith(
                      fontSize: 15,
                      color: WebColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AnimatedGlowButton(
                    label: 'Retry Connection',
                    icon: Icons.refresh_rounded,
                    onTap: onRetry,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Friendly server/error view matching the luxury Black + Gold aesthetic.
class PortfolioErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PortfolioErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: WebColors.background,
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: SingleChildScrollView(
          child: EntranceFader(
            offset: const Offset(0, 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: WebColors.surfaceCard,
                      border: Border.all(
                        color: WebColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.cloud_off_rounded,
                        size: 44,
                        color: WebColors.primaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  GoldShimmerText(
                    child: Text(
                      'Unable to Load Portfolio',
                      textAlign: TextAlign.center,
                      style: WebTextStyles.sectionTitle(isDark: true).copyWith(
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    message.isNotEmpty
                        ? message
                        : 'An unexpected issue occurred while communicating with Firebase. Please try again.',
                    style: WebTextStyles.bodyMedium(isDark: true).copyWith(
                      fontSize: 14.5,
                      color: WebColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AnimatedGlowButton(
                    label: 'Reload Page',
                    icon: Icons.refresh_rounded,
                    onTap: onRetry,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
