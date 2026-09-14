import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/notification/data/models/notification_model.dart';
import 'package:connecthub/features/notification/data/repos/notification_repo_imp.dart';
import 'package:connecthub/features/post/data/repos/post_repo.dart';
import 'package:connecthub/features/post/data/repos/post_repo_imp.dart';
import 'package:connecthub/features/post/presentation/widgets/comment_tile.dart';
import 'package:connecthub/features/post/presentation/widgets/liked_by_sheet.dart';

class PostDetailsView extends StatefulWidget {
  final String postId;
  final PostRepo postRepo;

  PostDetailsView({
    super.key,
    required this.postId,
    PostRepo? postRepo,
  }) : postRepo = postRepo ?? PostRepoImp();

  @override
  State<PostDetailsView> createState() => _PostDetailsViewState();
}

class _PostDetailsViewState extends State<PostDetailsView> {
  final _commentController = TextEditingController();
  bool _isSendingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Post Details', style: AppTextStyles.headline2),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: widget.postRepo.getPostStream(widget.postId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.primary),
                    );
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                        child: Text('Post not found.',
                            style: AppTextStyles.body2));
                  }

                  final data =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final likes = List<String>.from(data['likes'] ?? []);
                  final isLiked = likes.contains(currentUserId);
                  final likeCount = data['likeCount'] ?? 0;
                  final createdAt =
                      (data['createdAt'] as Timestamp?)?.toDate() ??
                          DateTime.now();

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            UserAvatar(
                                name: data['userName'] ?? '', size: 50),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['userName'] ?? 'Unknown',
                                  style: AppTextStyles.body1.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  DateFormat('MMM d, yyyy • h:mm a')
                                      .format(createdAt),
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(data['title'] ?? '', style: AppTextStyles.headline1),
                        const SizedBox(height: 12),
                        Text(data['description'] ?? '',
                            style: AppTextStyles.body1),
                        if (data['imageUrl'] != null &&
                            (data['imageUrl'] as String).isNotEmpty) ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CachedNetworkImage(
                              imageUrl: data['imageUrl'],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                height: 250,
                                color: AppColors.surfaceVariant,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              errorWidget: (_, _, _) => Container(
                                height: 250,
                                color: AppColors.surfaceVariant,
                                child: const Icon(Icons.broken_image_outlined,
                                    color: AppColors.textHint, size: 40),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  widget.postRepo.toggleLike(
                                      widget.postId, currentUserId);
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      isLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isLiked
                                          ? AppColors.accent
                                          : AppColors.textHint,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '$likeCount',
                                      style: AppTextStyles.body1.copyWith(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () =>
                                    _showLikedBySheet(context, likes),
                                child: Text(
                                  'Liked By',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.chat_bubble_outline,
                                  color: AppColors.textHint, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                '${data['commentCount'] ?? 0}',
                                style: AppTextStyles.body1
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text('Comments', style: AppTextStyles.headline3),
                        const SizedBox(height: 12),
                        StreamBuilder<QuerySnapshot>(
                          stream: widget.postRepo.getCommentsStream(
                              widget.postId),
                          builder: (context, commSnap) {
                            if (commSnap.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }
                            final comments = commSnap.data?.docs ?? [];
                            if (comments.isEmpty) {
                              return const Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: Text(
                                    'No comments yet. Be the first!',
                                    style: AppTextStyles.body2,
                                  ),
                                ),
                              );
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final comm = comments[index].data()
                                    as Map<String, dynamic>;
                                return CommentTile(
                                  userName: comm['userName'] ?? 'User',
                                  text: comm['text'] ?? '',
                                  createdAt:
                                      (comm['createdAt'] as Timestamp?)
                                              ?.toDate() ??
                                          DateTime.now(),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: AppTextStyles.body1,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          hintStyle: AppTextStyles.body2
                              .copyWith(color: AppColors.textHint),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _isSendingComment
                          ? null
                          : () async {
                              final text = _commentController.text.trim();
                              if (text.isEmpty) return;

                              setState(() => _isSendingComment = true);
                              final user =
                                  FirebaseAuth.instance.currentUser;
                              await widget.postRepo.addComment(
                                widget.postId,
                                {
                                  'userId': user?.uid ?? '',
                                  'userName':
                                      user?.displayName ?? 'User',
                                  'text': text,
                                  'createdAt':
                                      FieldValue.serverTimestamp(),
                                },
                              );

                              // Fire comment notification (not to self).
                              final postDoc = await FirebaseFirestore.instance
                                  .collection('posts')
                                  .doc(widget.postId)
                                  .get();
                              final Map<String, dynamic> postData =
                                  postDoc.data() ?? {};
                              final postOwnerId =
                                  postData['userId'] as String? ?? '';
                              if (user != null &&
                                  user.uid != postOwnerId &&
                                  postOwnerId.isNotEmpty) {
                                try {
                                  final senderDoc = await FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .get();
                                  final Map<String, dynamic> senderData =
                                      senderDoc.data() ?? {};
                                  await NotificationRepoImp()
                                      .createNotification(
                                    NotificationModel(
                                      id: '',
                                      senderId: user.uid,
                                      senderName: senderData['name']
                                              as String? ??
                                          user.displayName ??
                                          'Someone',
                                      senderUsername: senderData['username']
                                              as String? ??
                                          '',
                                      senderPhoto: senderData['profileImage']
                                          as String?,
                                      receiverId: postOwnerId,
                                      type: NotificationType.comment,
                                      postId: widget.postId,
                                      createdAt: DateTime.now(),
                                      isRead: false,
                                    ),
                                  );
                                } catch (_) {
                                  // Notification failure must not break comment.
                                }
                              }

                              _commentController.clear();
                              setState(() => _isSendingComment = false);
                            },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: _isSendingComment
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send_rounded,
                                color: Colors.white, size: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLikedBySheet(BuildContext context, List<String> userIds) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => LikedBySheet(userIds: userIds, postRepo: widget.postRepo),
    );
  }
}
