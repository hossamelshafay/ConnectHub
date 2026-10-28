import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/core/utils/profile_navigation_helper.dart';

class PostCardHeader extends StatelessWidget {
  final String userId;
  final String userName;
  final String timeAgo;
  final bool isOwnPost;
  final bool isEdited;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCardHeader({
    super.key,
    required this.userId,
    required this.userName,
    required this.timeAgo,
    required this.isOwnPost,
    required this.isEdited,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (userId.trim().isEmpty) {
      return _buildHeaderRow(
        context: context,
        displayName: userName,
        isVerified: false,
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId.trim())
          .snapshots(),
      builder: (context, snapshot) {
        String displayName = userName;
        bool isVerified = false;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final n = data?['name'] as String?;
          if (n != null && n.trim().isNotEmpty) displayName = n.trim();
          final acc = data?['accountType'] as String?;
          isVerified =
              (data?['isVerified'] as bool?) ?? (acc == 'professional');
        }

        return _buildHeaderRow(
          context: context,
          displayName: displayName,
          isVerified: isVerified,
        );
      },
    );
  }

  Widget _buildHeaderRow({
    required BuildContext context,
    required String displayName,
    required bool isVerified,
  }) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ProfileNavigationHelper.openUserProfile(
              context,
              userId: userId,
              userName: displayName,
            ),
            child: Row(
              children: [
                UserAvatarById(
                  userId: userId,
                  fallbackName: displayName,
                  size: 36,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 15,
                              color: AppColors.isDark
                                  ? AppColors.primary
                                  : const Color(0xFFA67C52),
                            ),
                          ],
                          if (isOwnPost) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'You',
                                style: AppTextStyles.caption.copyWith(
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
                          Text(timeAgo, style: AppTextStyles.caption),
                          if (isEdited) ...[
                            const SizedBox(width: 4),
                            Text('•', style: AppTextStyles.caption),
                            const SizedBox(width: 4),
                            Text(
                              'Edited',
                              style: AppTextStyles.caption.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isOwnPost && (onEdit != null || onDelete != null))
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_horiz_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: AppColors.glassBorder),
            ),
            color: AppColors.surfaceVariant,
            elevation: 8,
            onSelected: (value) {
              if (value == 'edit') {
                onEdit?.call();
              } else if (value == 'delete') {
                onDelete?.call();
              }
            },
            itemBuilder: (context) => [
              if (onEdit != null)
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 18, color: AppColors.textPrimary),
                      const SizedBox(width: 12),
                      const Text('Edit Post'),
                    ],
                  ),
                ),
              if (onDelete != null)
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 18, color: AppColors.error),
                      const SizedBox(width: 12),
                      Text(
                        'Delete Post',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ],
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
