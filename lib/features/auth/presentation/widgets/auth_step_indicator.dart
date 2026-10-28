import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

class AuthStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const AuthStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.glass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 1; i <= totalSteps; i++) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: i <= currentStep
                    ? AppColors.primary
                    : AppColors.textHint.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
            if (i < totalSteps) const SizedBox(width: 6),
          ],
          const SizedBox(width: 8),
          Text(
            'Step $currentStep of $totalSteps',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
