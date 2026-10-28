import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

class PostCardActions extends StatelessWidget {
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final Animation<double> likeScaleAnim;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const PostCardActions({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
    required this.likeScaleAnim,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ScaleTransition(
          scale: likeScaleAnim,
          child: _ActionButton(
            icon: isLiked
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: '$likeCount',
            color: isLiked
                ? AppColors.primary
                : AppColors.textSecondary,
            onTap: onLike,
          ),
        ),
        const SizedBox(width: 18),
        _ActionButton(
          icon: Icons.chat_bubble_outline_rounded,
          label: '$commentCount',
          color: AppColors.textSecondary,
          onTap: onComment,
        ),
        const Spacer(),
        _ActionButton(
          icon: Icons.share_outlined,
          label: 'Share',
          color: AppColors.textSecondary,
          onTap: onShare,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
