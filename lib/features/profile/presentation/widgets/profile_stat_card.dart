import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

class ProfileStatCard extends StatelessWidget {
  final String count;
  final String label;
  final bool isClickable;
  final VoidCallback? onTap;

  const ProfileStatCard({
    super.key,
    required this.count,
    required this.label,
    this.isClickable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.glass,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isClickable
                  ? AppColors.primary.withValues(alpha: 0.25)
                  : AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Inter',
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight:
                          isClickable ? FontWeight.w500 : FontWeight.w400,
                      color: isClickable
                          ? AppColors.textSecondary
                          : AppColors.textHint,
                      fontSize: 11.5,
                    ),
                  ),
                  if (isClickable) ...[
                    const SizedBox(width: 3),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 8,
                      color: AppColors.textHint,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
