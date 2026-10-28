import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/chat/data/models/message_model.dart';
import 'package:connecthub/features/post/presentation/views/post_details_view.dart';

class ChatSharedPostCard extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const ChatSharedPostCard({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final preview = message.sharedPostPreview ?? {};
    final postId = message.sharedPostId ?? (preview['postId'] as String? ?? '');
    final title = (preview['title'] as String? ?? '').trim();
    final description = (preview['description'] as String? ?? '').trim();
    final imageUrl = preview['imageUrl'] as String?;
    final authorName = (preview['authorName'] as String? ?? 'User').trim();
    final authorPhoto = preview['authorPhoto'] as String?;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: postId.isNotEmpty
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailsView(postId: postId),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMe
                ? Colors.white.withValues(alpha: 0.12)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isMe
                  ? Colors.white.withValues(alpha: 0.25)
                  : AppColors.divider,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge + Author Row
              Row(
                children: [
                  UserAvatar(
                    name: authorName,
                    size: 26,
                    imageUrl: authorPhoto,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      authorName,
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isMe ? Colors.white : AppColors.textPrimary,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 11,
                          color: isMe ? Colors.white : AppColors.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Shared Post',
                          style: AppTextStyles.caption.copyWith(
                            color: isMe ? Colors.white : AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (imageUrl != null && imageUrl.isNotEmpty) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, _) => const ShimmerBox(
                      width: double.infinity,
                      height: 130,
                      borderRadius: 10,
                    ),
                    errorWidget: (_, _, _) => Container(
                      height: 130,
                      color: AppColors.surfaceVariant,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                ),
              ],
              if (title.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isMe ? Colors.white : AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.body2.copyWith(
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.85)
                        : AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
