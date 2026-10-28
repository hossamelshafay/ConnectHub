import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/core/utils/mention_text.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';
import 'package:connecthub/features/home/presentation/widgets/post_card_actions.dart';
import 'package:connecthub/features/home/presentation/widgets/post_card_header.dart';
import 'package:connecthub/features/post/presentation/views/post_details_view.dart';
import 'package:connecthub/features/chat/presentation/widgets/share_post_sheet.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isOwnPost;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    this.onEdit,
    this.onDelete,
    this.isOwnPost = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late final AnimationController _likeController;
  late final Animation<double> _likeScaleAnim;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _likeScaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.22)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.22, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_likeController);
  }

  @override
  void dispose() {
    _likeController.dispose();
    super.dispose();
  }

  void _handleLike() {
    HapticFeedback.lightImpact();
    _likeController.forward(from: 0.0);
    widget.onLike();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isLiked = widget.post.likes.contains(currentUserId);
    final timeAgo = _getTimeAgo(widget.post.createdAt);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailsView(postId: widget.post.id),
          ),
        );
      },
      onLongPress: () => _openShareSheet(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isOwnPost
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.glassBorder,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PostCardHeader(
                  userId: widget.post.userId,
                  userName: widget.post.userName,
                  timeAgo: timeAgo,
                  isOwnPost: widget.isOwnPost,
                  isEdited: widget.post.lastEditedAt != null,
                  onEdit: widget.onEdit,
                  onDelete: widget.onDelete,
                ),

                const SizedBox(height: 8),
                Text(
                  widget.post.title,
                  style: AppTextStyles.headline3.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                MentionText(
                  text: widget.post.description,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                // Post Image with Dark Shimmer placeholder
                if (widget.post.imageUrl != null &&
                    widget.post.imageUrl!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 16 / 8.5,
                      child: CachedNetworkImage(
                        imageUrl: widget.post.imageUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const ShimmerBox(
                          width: double.infinity,
                          height: double.infinity,
                          borderRadius: 12,
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: AppColors.surfaceVariant,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.textHint,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 6),

                // Action buttons row: Like, Comment, Share
                PostCardActions(
                  isLiked: isLiked,
                  likeCount: widget.post.likeCount,
                  commentCount: widget.post.commentCount,
                  likeScaleAnim: _likeScaleAnim,
                  onLike: _handleLike,
                  onComment: widget.onComment,
                  onShare: () => _openShareSheet(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openShareSheet(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please log in to share posts.'),
          backgroundColor: AppColors.surfaceVariant,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.error, width: 1),
          ),
        ),
      );
      return;
    }
    SharePostSheet.show(
      context,
      post: widget.post,
      myUid: user.uid,
      myName: (user.displayName != null && user.displayName!.trim().isNotEmpty)
          ? user.displayName!.trim()
          : 'User',
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 7) {
      return DateFormat('MMM d').format(dateTime);
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
