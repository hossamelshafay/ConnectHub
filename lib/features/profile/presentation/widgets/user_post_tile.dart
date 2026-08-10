import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/post/presentation/views/post_details_view.dart';

class UserPostTile extends StatelessWidget {
  final String postId;
  final String title;
  final String description;
  final String? imageUrl;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;

  const UserPostTile({
    super.key,
    required this.postId,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailsView(postId: postId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Container(
                    width: 64,
                    height: 64,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.image, color: AppColors.textHint),
                  ),
                ),
              )
            else
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.article,
                    color: AppColors.primary, size: 28),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.favorite,
                          size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text('$likeCount', style: AppTextStyles.caption),
                      const SizedBox(width: 14),
                      const Icon(Icons.chat_bubble,
                          size: 14, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text('$commentCount',
                          style: AppTextStyles.caption),
                      const Spacer(),
                      Text(
                        DateFormat('MMM d').format(createdAt),
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: AppColors.textHint, size: 22),
          ],
        ),
      ),
    );
  }
}
