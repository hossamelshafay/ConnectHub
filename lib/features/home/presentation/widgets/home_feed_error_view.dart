import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';

class HomeFeedErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const HomeFeedErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                color: AppColors.textSecondary,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load feed',
              style: AppTextStyles.headline3,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SecondaryButton(
              text: 'Try Again',
              width: 140,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
