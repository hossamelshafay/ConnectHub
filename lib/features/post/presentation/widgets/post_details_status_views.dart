import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Error state view when post fails to load.
class PostDetailsErrorView extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const PostDetailsErrorView({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text('Failed to load post', style: AppTextStyles.headline3),
            const SizedBox(height: 8),
            Text(
              '$error'.replaceFirst('Exception: ', ''),
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Not-found state view when post document does not exist.
class PostDetailsNotFoundView extends StatelessWidget {
  final VoidCallback onGoBack;

  const PostDetailsNotFoundView({
    super.key,
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_outlined, size: 48, color: AppColors.textHint),
            const SizedBox(height: 12),
            Text('Post not found.', style: AppTextStyles.body1),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onGoBack,
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
