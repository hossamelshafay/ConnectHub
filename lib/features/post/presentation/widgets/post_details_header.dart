import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/core/utils/profile_navigation_helper.dart';
import 'package:connecthub/features/post/presentation/manager/cubit/post_action_cubit.dart';
import 'package:connecthub/features/post/presentation/views/edit_post_view.dart';
import 'package:connecthub/features/post/presentation/widgets/delete_post_dialog.dart';

class PostDetailsHeader extends StatelessWidget {
  final String postId;
  final String postOwnerId;
  final String postOwnerName;
  final DateTime createdAt;
  final dynamic lastEditedAt;
  final String currentUserId;
  final String title;
  final String description;
  final String? imageUrl;
  final String? deleteHash;

  const PostDetailsHeader({
    super.key,
    required this.postId,
    required this.postOwnerId,
    required this.postOwnerName,
    required this.createdAt,
    this.lastEditedAt,
    required this.currentUserId,
    required this.title,
    required this.description,
    this.imageUrl,
    this.deleteHash,
  });

  @override
  Widget build(BuildContext context) {
    if (postOwnerId.trim().isEmpty) {
      return _buildHeaderContent(
        context: context,
        displayOwnerName: postOwnerName,
        isVerified: false,
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(postOwnerId.trim())
          .snapshots(),
      builder: (context, snapshot) {
        String displayOwnerName = postOwnerName;
        bool isVerified = false;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final n = data?['name'] as String?;
          if (n != null && n.trim().isNotEmpty) displayOwnerName = n.trim();
          final acc = data?['accountType'] as String?;
          isVerified =
              (data?['isVerified'] as bool?) ?? (acc == 'professional');
        }

        return _buildHeaderContent(
          context: context,
          displayOwnerName: displayOwnerName,
          isVerified: isVerified,
        );
      },
    );
  }

  Widget _buildHeaderContent({
    required BuildContext context,
    required String displayOwnerName,
    required bool isVerified,
  }) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (postOwnerId.isNotEmpty) {
                ProfileNavigationHelper.openUserProfile(
                  context,
                  userId: postOwnerId,
                  userName: displayOwnerName,
                );
              }
            },
            child: Row(
              children: [
                UserAvatarById(
                  userId: postOwnerId,
                  fallbackName: displayOwnerName,
                  size: 50,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayOwnerName,
                              style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: AppColors.isDark
                                  ? AppColors.primary
                                  : const Color(0xFFA67C52),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            DateFormat('MMM d, yyyy • h:mm a').format(createdAt),
                            style: AppTextStyles.caption,
                          ),
                          if (lastEditedAt != null) ...[
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
        if (postOwnerId == currentUserId)
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditPostView(
                      postId: postId,
                      initialTitle: title,
                      initialDescription: description,
                      initialImageUrl: imageUrl,
                      initialDeleteHash: deleteHash,
                    ),
                  ),
                );
              } else if (value == 'delete') {
                DeletePostDialog.show(
                  context,
                  description: description,
                  onConfirm: () async {
                    final cubit = PostActionCubit();
                    try {
                      await cubit.deletePost(
                        postId: postId,
                        deleteHash: deleteHash,
                      );
                      if (context.mounted) {
                        Navigator.pop(context); // Pop PostDetailsView back to caller
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Post deleted successfully!'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    }
                  },
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20, color: AppColors.textPrimary),
                    const SizedBox(width: 12),
                    const Text('Edit Post'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: AppColors.error),
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
