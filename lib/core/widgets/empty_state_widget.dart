import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/widgets/primary_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EmptyStateWidget — Consistent empty state
// ─────────────────────────────────────────────────────────────────────────────
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.ctaLabel,
    this.onCta,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = ctaLabel ?? actionText;
    final effectiveAction = onCta ?? onAction;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.glass,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder, width: 1),
              ),
              child: Icon(icon, size: 32, color: AppColors.textHint),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[ 
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.body2,
                textAlign: TextAlign.center,
              ),
            ],
            if (effectiveLabel != null && effectiveAction != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                text: effectiveLabel,
                onPressed: effectiveAction,
                width: 180,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
