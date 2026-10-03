import 'package:flutter/material.dart';

enum ProfileSwitchTarget { portfolio, social }

/// Material 3 OutlinedButton for toggling between Social Profile and Portfolio.
/// Features animated icon and label transitions.
class PortfolioSwitchButton extends StatelessWidget {
  final ProfileSwitchTarget target;
  final VoidCallback onPressed;
  final bool isDarkTheme;

  const PortfolioSwitchButton({
    super.key,
    required this.target,
    required this.onPressed,
    this.isDarkTheme = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPortfolio = target == ProfileSwitchTarget.portfolio;
    final primaryColor = isDarkTheme ? const Color(0xFF38BDF8) : Colors.white;
    final backgroundColor = isDarkTheme
        ? const Color(0xFF38BDF8).withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.12);
    final borderColor = isDarkTheme
        ? const Color(0xFF38BDF8).withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.85);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: borderColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: backgroundColor,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation,
                child: child,
              ),
            );
          },
          child: Row(
            key: ValueKey(target),
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPortfolio ? Icons.work_outline : Icons.person_outline,
                size: 18,
                color: primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                isPortfolio ? 'View Portfolio' : 'View Social Profile',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
