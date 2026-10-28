import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Reusable empty state view for followers and following lists.
class FollowEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FollowEmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: AppTextStyles.headline3),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.body2.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
