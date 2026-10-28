import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/core/utils/mention_text.dart';

class PostDetailsContent extends StatelessWidget {
  final String title;
  final String description;
  final String? imageUrl;

  const PostDetailsContent({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(title, style: AppTextStyles.headline1),
        const SizedBox(height: 12),
        MentionText(
          text: description,
          style: AppTextStyles.body1,
        ),
        if (hasImage) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, _) => const ShimmerBox(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: 16,
                ),
                errorWidget: (_, _, _) => Container(
                  color: AppColors.surfaceVariant,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textHint,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
