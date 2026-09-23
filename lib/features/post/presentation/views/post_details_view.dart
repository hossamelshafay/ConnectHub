import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/core/utils/mention_helper.dart';
import 'package:connecthub/core/utils/mention_text.dart';
import 'package:connecthub/features/notification/data/models/notification_model.dart';
import 'package:connecthub/features/notification/data/repos/notification_repo_imp.dart';
import 'package:connecthub/features/post/data/repos/post_repo.dart';
import 'package:connecthub/features/post/data/repos/post_repo_imp.dart';
import 'package:connecthub/features/post/presentation/widgets/comment_tile.dart';
import 'package:connecthub/features/post/presentation/widgets/liked_by_sheet.dart';
import 'package:connecthub/features/search/presentation/widgets/mention_autocomplete_overlay.dart';
import 'package:connecthub/core/utils/profile_navigation_helper.dart';
import 'package:connecthub/features/post/presentation/views/edit_post_view.dart';
import 'package:connecthub/features/post/presentation/widgets/delete_post_dialog.dart';
import 'package:connecthub/features/post/presentation/widgets/delete_comment_dialog.dart';
import 'package:connecthub/features/post/presentation/manager/cubit/post_action_cubit.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';
import 'package:connecthub/features/chat/presentation/widgets/share_post_sheet.dart';

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
  final _scrollController = ScrollController();
  final _commentFocusNode = FocusNode();
  bool _isSendingComment = false;
  bool _isProcessing = false;
  String? _editingCommentId;
  String? _editingCommentOriginalText;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _startEditingComment(String commentId, String commentText) {
    if (_isProcessing) return;
    setState(() {
      _editingCommentId = commentId;
      _editingCommentOriginalText = commentText;
      _commentController.text = commentText;
      _commentController.selection = TextSelection.fromPosition(
        TextPosition(offset: commentText.length),
      );
    });
    _commentFocusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _cancelEditingComment() {
    setState(() {
      _editingCommentId = null;
      _editingCommentOriginalText = null;
      _commentController.clear();
    });
  }

  Future<void> _confirmDeleteComment(String commentId) async {
    if (_isProcessing) return;
    final messenger = ScaffoldMessenger.of(context);
    DeleteCommentDialog.show(
      context,
      onConfirm: () async {
        setState(() => _isProcessing = true);
        try {
          await widget.postRepo.deleteComment(
            postId: widget.postId,
            commentId: commentId,
          );
          if (_editingCommentId == commentId) {
            _cancelEditingComment();
          }
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: const Text('Comment deleted successfully!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceFirst('Exception: ', '')),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isProcessing = false);
          }
        }
      },
    );
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
                  final postOwnerId = data['userId'] as String? ?? '';
                  final likes = List<String>.from(data['likes'] ?? []);
                  final isLiked = likes.contains(currentUserId);
                  final likeCount = data['likeCount'] ?? 0;
                  final createdAt =
                      (data['createdAt'] as Timestamp?)?.toDate() ??
                          DateTime.now();

                  return SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  final postOwnerId =
                                      data['userId'] as String? ?? '';
                                  final postOwnerName =
                                      data['userName'] as String? ?? 'Unknown';
                                  if (postOwnerId.isNotEmpty) {
                                    ProfileNavigationHelper.openUserProfile(
                                      context,
                                      userId: postOwnerId,
                                      userName: postOwnerName,
                                    );
                                  }
                                },
                                child: Row(
                                  children: [
                                    UserAvatar(
                                        name: data['userName'] ?? '', size: 50),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['userName'] ?? 'Unknown',
                                            style: AppTextStyles.body1.copyWith(
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                DateFormat(
                                                        'MMM d, yyyy • h:mm a')
                                                    .format(createdAt),
                                                style: AppTextStyles.caption,
                                              ),
                                              if (data['lastEditedAt'] !=
                                                  null) ...[
                                                const SizedBox(width: 4),
                                                const Text('•',
                                                    style:
                                                        AppTextStyles.caption),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Edited',
                                                  style: AppTextStyles.caption
                                                      .copyWith(
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
                            if (data['userId'] == currentUserId)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert,
                                    color: AppColors.textSecondary),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditPostView(
                                          postId: widget.postId,
                                          initialTitle: data['title'] ?? '',
                                          initialDescription:
                                              data['description'] ?? '',
                                          initialImageUrl: data['imageUrl'],
                                          initialDeleteHash: data['deleteHash'],
                                        ),
                                      ),
                                    );
                                  } else if (value == 'delete') {
                                    DeletePostDialog.show(
                                      context,
                                      description: data['description'] ?? '',
                                      onConfirm: () async {
                                        final cubit = PostActionCubit();
                                        try {
                                          await cubit.deletePost(
                                            postId: widget.postId,
                                            deleteHash: data['deleteHash'],
                                          );
                                          if (context.mounted) {
                                            Navigator.pop(
                                                context); // Pop PostDetailsView back to caller
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                    'Post deleted successfully!'),
                                                backgroundColor:
                                                    AppColors.success,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(e.toString()),
                                                backgroundColor:
                                                    AppColors.error,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
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
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined,
                                            size: 20,
                                            color: AppColors.textPrimary),
                                        SizedBox(width: 12),
                                        Text('Edit Post'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline,
                                            size: 20, color: AppColors.error),
                                        SizedBox(width: 12),
                                        Text('Delete Post',
                                            style: TextStyle(
                                                color: AppColors.error)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(data['title'] ?? '', style: AppTextStyles.headline1),
                        const SizedBox(height: 12),
                        MentionText(
                          text: data['description'] ?? '',
                          style: AppTextStyles.body1,
                        ),
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
                              const SizedBox(width: 16),
                              InkWell(
                                onTap: () {
                                  final user =
                                      FirebaseAuth.instance.currentUser;
                                  if (user == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                            'Please log in to share posts.'),
                                        backgroundColor: AppColors.error,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  final postObj =
                                      PostModel.fromDoc(snapshot.data!);
                                  SharePostSheet.show(
                                    context,
                                    post: postObj,
                                    myUid: user.uid,
                                    myName: (user.displayName != null &&
                                            user.displayName!.trim().isNotEmpty)
                                        ? user.displayName!.trim()
                                        : 'User',
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.share_outlined,
                                          color: AppColors.textHint, size: 22),
                                      SizedBox(width: 6),
                                      Text(
                                        'Share',
                                        style: TextStyle(
                                          color: AppColors.textHint,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                final commentDoc = comments[index];
                                final commentId = commentDoc.id;
                                final comm = commentDoc.data()
                                    as Map<String, dynamic>;
                                final commentUserId =
                                    comm['userId'] as String? ?? '';
                                final commentText =
                                    comm['text'] as String? ?? '';
                                final commentCreatedAt =
                                    (comm['createdAt'] as Timestamp?)
                                            ?.toDate() ??
                                        DateTime.now();
                                final commentLastEditedAt =
                                    (comm['lastEditedAt'] as Timestamp?)
                                        ?.toDate();

                                final isCommentOwner =
                                    currentUserId.isNotEmpty &&
                                        commentUserId == currentUserId;
                                final isPostOwner = currentUserId.isNotEmpty &&
                                    postOwnerId == currentUserId;

                                final canEdit = isCommentOwner;
                                final canDelete =
                                    isCommentOwner || isPostOwner;

                                return CommentTile(
                                  commentId: commentId,
                                  userId: commentUserId,
                                  userName: comm['userName'] ?? 'User',
                                  text: commentText,
                                  createdAt: commentCreatedAt,
                                  lastEditedAt: commentLastEditedAt,
                                  onEdit: canEdit
                                      ? () => _startEditingComment(
                                          commentId, commentText)
                                      : null,
                                  onDelete: canDelete
                                      ? () =>
                                          _confirmDeleteComment(commentId)
                                      : null,
                                  isProcessing: _isProcessing,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_editingCommentId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.edit,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            const Text(
                              'Editing comment',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: _cancelEditingComment,
                              child: const Icon(Icons.close,
                                  size: 18, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: MentionAutocompleteOverlay(
                              controller: _commentController,
                              showAbove: true,
                              child: TextField(
                                controller: _commentController,
                                focusNode: _commentFocusNode,
                                style: AppTextStyles.body1,
                                decoration: InputDecoration(
                                  hintText: _editingCommentId != null
                                      ? 'Edit your comment...'
                                      : 'Write a comment... (use @ to mention)',
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
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: (_isSendingComment || _isProcessing)
                                ? null
                                : () async {
                                    final messenger =
                                        ScaffoldMessenger.of(context);
                                    final text =
                                        _commentController.text.trim();
                                    if (text.isEmpty) {
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                              'Comment cannot be empty.'),
                                          backgroundColor: AppColors.error,
                                          behavior:
                                              SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    if (_editingCommentId != null) {
                                      // Editing comment mode
                                      if (text ==
                                          _editingCommentOriginalText) {
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                'No changes were made.'),
                                            backgroundColor:
                                                AppColors.textSecondary,
                                            behavior:
                                                SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      setState(() => _isProcessing = true);
                                      try {
                                        await widget.postRepo.updateComment(
                                          postId: widget.postId,
                                          commentId: _editingCommentId!,
                                          text: text,
                                          oldText:
                                              _editingCommentOriginalText,
                                        );
                                        _cancelEditingComment();
                                        if (mounted) {
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                  'Comment updated successfully!'),
                                              backgroundColor:
                                                  AppColors.success,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12),
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        final message = e
                                            .toString()
                                            .replaceFirst(
                                                'Exception: ', '');
                                        if (message.contains(
                                            'no longer exists')) {
                                          _cancelEditingComment();
                                        }
                                        if (mounted) {
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(message),
                                              backgroundColor:
                                                  AppColors.error,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12),
                                              ),
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() =>
                                              _isProcessing = false);
                                        }
                                      }
                                    } else {
                                      // New comment mode
                                      setState(
                                          () => _isSendingComment = true);
                                      try {
                                        final user = FirebaseAuth
                                            .instance.currentUser;
                                        final commentId = await widget
                                            .postRepo
                                            .addComment(
                                          widget.postId,
                                          {
                                            'userId': user?.uid ?? '',
                                            'userName': user?.displayName ??
                                                'User',
                                            'text': text,
                                            'createdAt':
                                                FieldValue.serverTimestamp(),
                                          },
                                        );

                                        // Fire mention notifications
                                        MentionHelper
                                            .sendMentionNotifications(
                                          text: text,
                                          postId: widget.postId,
                                          commentId: commentId,
                                        );

                                        // Fire comment notification (not to self).
                                        final postDoc = await FirebaseFirestore
                                            .instance
                                            .collection('posts')
                                            .doc(widget.postId)
                                            .get();
                                        final Map<String, dynamic> postData =
                                            postDoc.data() ?? {};
                                        final targetPostOwnerId = postData['userId']
                                                as String? ??
                                            '';
                                        if (user != null &&
                                            user.uid != targetPostOwnerId &&
                                            targetPostOwnerId.isNotEmpty) {
                                          try {
                                            final senderDoc =
                                                await FirebaseFirestore
                                                    .instance
                                                    .collection('users')
                                                    .doc(user.uid)
                                                    .get();
                                            final Map<String, dynamic>
                                                senderData =
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
                                                senderUsername: senderData[
                                                        'username']
                                                    as String? ??
                                                    '',
                                                senderPhoto: senderData[
                                                        'profileImage']
                                                    as String?,
                                                receiverId: targetPostOwnerId,
                                                type: NotificationType.comment,
                                                postId: widget.postId,
                                                commentId: commentId,
                                                createdAt: DateTime.now(),
                                                isRead: false,
                                              ),
                                            );
                                          } catch (_) {
                                            // Notification failure must not break comment.
                                          }
                                        }

                                        _commentController.clear();
                                      } catch (e) {
                                        if (mounted) {
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(e
                                                  .toString()
                                                  .replaceFirst(
                                                      'Exception: ', '')),
                                              backgroundColor:
                                                  AppColors.error,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12),
                                              ),
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() =>
                                              _isSendingComment = false);
                                        }
                                      }
                                    }
                                  },
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryDark
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: (_isSendingComment || _isProcessing)
                                  ? const Padding(
                                      padding: EdgeInsets.all(14),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      _editingCommentId != null
                                          ? Icons.check_rounded
                                          : Icons.send_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                            ),
                          ),
                        ],
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
