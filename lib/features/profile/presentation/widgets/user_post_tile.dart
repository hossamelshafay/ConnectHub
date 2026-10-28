import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/core/utils/profile_navigation_helper.dart';
import 'package:connecthub/features/post/presentation/views/post_details_view.dart';

/// Feed-style Post Tile matching Mockup Screens 1 & 2:
/// - Author avatar, display name, time ago, and three-dots options menu.
/// - Text caption/content.
/// - Full-width rounded preview image (if available).
/// - Reaction bar: likes, comments, share.
class UserPostTile extends StatelessWidget {
  final String postId;
  final String? userId;
  final String title;
  final String description;
  final String? imageUrl;
  final String? deleteHash;
  final int likeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime? lastEditedAt;
  final String? userName;
  final String? userPhoto;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const UserPostTile({
    super.key,
    required this.postId,
    this.userId,
    required this.title,
    required this.description,
    this.imageUrl,
    this.deleteHash,
    required this.likeCount,
    required this.commentCount,
    required this.createdAt,
    this.lastEditedAt,
    this.userName,
    this.userPhoto,
    this.onEdit,
    this.onDelete,
  });

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${date.day}/${date.month}/${date.year}';
  }

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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.isDark
                ? const Color(0x28FFFFFF)
                : const Color(0xFFE8E0D5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row: Author Info Header ─────────────────────────
            _buildAuthorHeader(context),

            const SizedBox(height: 10),

            // ── Post Caption / Description ──────────────────────────
            if (description.isNotEmpty) ...[
              Text(
                description,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  height: 1.45,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
            ],

            // ── Post Image (if present) ─────────────────────────────
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: imageUrl!,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const ShimmerBox(
                    width: double.infinity,
                    height: 180,
                    borderRadius: 14,
                  ),
                  errorWidget: (_, _, _) => Container(
                    width: double.infinity,
                    height: 120,
                    color: AppColors.surfaceVariant,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textHint,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // ── Reaction Bar (Likes · Comments · Share) ─────────────
            Row(
              children: [
                // Likes
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      likeCount > 0
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 17,
                      color: likeCount > 0
                          ? const Color(0xFFEF4444)
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$likeCount',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Comments
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$commentCount',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Share
                Icon(
                  Icons.send_rounded,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorHeader(BuildContext context) {
    if (userId != null && userId!.trim().isNotEmpty) {
      return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId!.trim())
            .snapshots(),
        builder: (context, snapshot) {
          String authorName = (userName != null &&
                  userName!.trim().isNotEmpty &&
                  userName != 'Unknown')
              ? userName!.trim()
              : '';
          String? authorPhoto = userPhoto;
          bool isVerified = false;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            final n = data?['name'] as String?;
            if (n != null && n.trim().isNotEmpty) authorName = n.trim();
            final p = data?['profileImage'] as String?;
            if (p != null && p.trim().isNotEmpty) authorPhoto = p.trim();
            final acc = data?['accountType'] as String?;
            isVerified =
                (data?['isVerified'] as bool?) ?? (acc == 'professional');
          }

          if (authorName.isEmpty) {
            authorName = 'User';
          }

          final currentUserId = FirebaseAuth.instance.currentUser?.uid;
          final isOwnPost =
              currentUserId != null && userId!.trim() == currentUserId;

          return _buildAuthorRow(
            context: context,
            effectiveUserId: userId!.trim(),
            authorName: authorName,
            authorPhoto: authorPhoto,
            isVerified: isVerified,
            isOwnPost: isOwnPost,
          );
        },
      );
    }

    final fallbackName = (userName != null &&
            userName!.trim().isNotEmpty &&
            userName != 'Unknown')
        ? userName!.trim()
        : 'User';

    return _buildAuthorRow(
      context: context,
      effectiveUserId: null,
      authorName: fallbackName,
      authorPhoto: userPhoto,
      isVerified: false,
      isOwnPost: false,
    );
  }

  Widget _buildAuthorRow({
    required BuildContext context,
    required String? effectiveUserId,
    required String authorName,
    required String? authorPhoto,
    required bool isVerified,
    required bool isOwnPost,
  }) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (effectiveUserId != null && effectiveUserId.isNotEmpty) {
              ProfileNavigationHelper.openUserProfile(
                context,
                userId: effectiveUserId,
                userName: authorName,
              );
            }
          },
          child: UserAvatar(
            name: authorName,
            imageUrl: authorPhoto,
            size: 38,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (effectiveUserId != null && effectiveUserId.isNotEmpty) {
                ProfileNavigationHelper.openUserProfile(
                  context,
                  userId: effectiveUserId,
                  userName: authorName,
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        authorName,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: AppColors.isDark
                            ? AppColors.primary
                            : const Color(0xFFA67C52),
                      ),
                    ],
                    if (isOwnPost) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          'You',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _formatTimeAgo(createdAt),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (lastEditedAt != null) ...[
                      const SizedBox(width: 4),
                      Text('•',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textMuted)),
                      const SizedBox(width: 4),
                      Text(
                        'Edited',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        if (onEdit != null || onDelete != null)
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
            padding: EdgeInsets.zero,
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: AppColors.glassBorder),
            ),
            onSelected: (value) {
              if (value == 'edit' && onEdit != null) onEdit!();
              if (value == 'delete' && onDelete != null) onDelete!();
            },
            itemBuilder: (context) => [
              if (onEdit != null)
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 16, color: AppColors.textPrimary),
                      const SizedBox(width: 8),
                      Text('Edit Post',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          )),
                    ],
                  ),
                ),
              if (onDelete != null)
                PopupMenuItem(
                  value: 'delete',
                  child: const Row(
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 16, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppColors.error,
                          )),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
