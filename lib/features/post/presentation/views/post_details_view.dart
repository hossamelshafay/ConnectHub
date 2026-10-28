import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/core/utils/mention_helper.dart';
import 'package:connecthub/features/notification/data/models/notification_model.dart';
import 'package:connecthub/features/notification/data/repos/notification_repo_imp.dart';
import 'package:connecthub/features/post/data/repos/post_repo.dart';
import 'package:connecthub/features/post/data/repos/post_repo_imp.dart';
import 'package:connecthub/features/post/presentation/widgets/delete_comment_dialog.dart';
import 'package:connecthub/features/post/presentation/widgets/post_details_header.dart';
import 'package:connecthub/features/post/presentation/widgets/post_details_content.dart';
import 'package:connecthub/features/post/presentation/widgets/post_details_actions_bar.dart';
import 'package:connecthub/features/post/presentation/widgets/post_details_comments_section.dart';
import 'package:connecthub/features/post/presentation/widgets/post_comment_input_bar.dart';
import 'package:connecthub/features/post/presentation/widgets/post_details_status_views.dart';

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
  bool? _optimisticLiked;
  int? _optimisticLikeCount;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  void _handleToggleLike(
    String currentUserId,
    List<String> serverLikes,
    int serverCount,
  ) {
    if (currentUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please log in to like posts.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    final currentlyLiked = _optimisticLiked ?? serverLikes.contains(currentUserId);
    final count = _optimisticLikeCount ?? serverCount;
    setState(() {
      _optimisticLiked = !currentlyLiked;
      _optimisticLikeCount = (_optimisticLiked! ? count + 1 : count - 1).clamp(0, 999999);
    });
    widget.postRepo.toggleLike(widget.postId, currentUserId);
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Future<void> _handleCommentSubmit() async {
    final messenger = ScaffoldMessenger.of(context);
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Comment cannot be empty.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (_editingCommentId != null) {
      // Editing comment mode
      if (text == _editingCommentOriginalText) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('No changes were made.'),
            backgroundColor: AppColors.textSecondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          oldText: _editingCommentOriginalText,
        );
        _cancelEditingComment();
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: const Text('Comment updated successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        final message = e.toString().replaceFirst('Exception: ', '');
        if (message.contains('no longer exists')) {
          _cancelEditingComment();
        }
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    } else {
      // New comment mode
      setState(() => _isSendingComment = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        String commenterName = (user?.displayName ?? '').trim();
        if (commenterName.isEmpty && user != null) {
          try {
            final senderDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
            final sData = senderDoc.data() ?? {};
            commenterName = (sData['name'] as String? ?? sData['username'] as String? ?? '').trim();
          } catch (_) {}
        }
        if (commenterName.isEmpty) {
          commenterName = 'User';
        }

        final commentId = await widget.postRepo.addComment(
          widget.postId,
          {
            'userId': user?.uid ?? '',
            'userName': commenterName,
            'text': text,
            'createdAt': FieldValue.serverTimestamp(),
          },
        );

        // Fire mention notifications
        MentionHelper.sendMentionNotifications(
          text: text,
          postId: widget.postId,
          commentId: commentId,
        );

        // Fire comment notification (not to self)
        final postDoc = await FirebaseFirestore.instance.collection('posts').doc(widget.postId).get();
        final Map<String, dynamic> postData = postDoc.data() ?? {};
        final targetPostOwnerId = postData['userId'] as String? ?? '';
        if (user != null && user.uid != targetPostOwnerId && targetPostOwnerId.isNotEmpty) {
          try {
            final senderDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
            final Map<String, dynamic> senderData = senderDoc.data() ?? {};
            await NotificationRepoImp().createNotification(
              NotificationModel(
                id: '',
                senderId: user.uid,
                senderName: senderData['name'] as String? ?? user.displayName ?? 'Someone',
                senderUsername: senderData['username'] as String? ?? '',
                senderPhoto: senderData['profileImage'] as String?,
                receiverId: targetPostOwnerId,
                type: NotificationType.comment,
                postId: widget.postId,
                commentId: commentId,
                createdAt: DateTime.now(),
                isRead: false,
              ),
            );
          } catch (_) {}
        }

        _commentController.clear();
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceFirst('Exception: ', '')),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSendingComment = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Post'),
        leading: AppIconButton(
          icon: Icons.arrow_back_ios_new,
          size: 16,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: widget.postRepo.getPostStream(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView(
                    padding: const EdgeInsets.only(top: 12),
                    children: const [
                      PostCardShimmer(hasImage: true),
                      SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: CommentShimmer(itemCount: 2),
                      ),
                    ],
                  );
                }
                if (snapshot.hasError) {
                  return PostDetailsErrorView(
                    error: snapshot.error,
                    onRetry: () => setState(() {}),
                  );
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return PostDetailsNotFoundView(
                    onGoBack: () => Navigator.pop(context),
                  );
                }

                final postDoc = snapshot.data!;
                final data = postDoc.data() as Map<String, dynamic>;
                final postOwnerId = data['userId'] as String? ?? '';
                final postOwnerName = data['userName'] as String? ?? 'Unknown';
                final serverLikes = List<String>.from(data['likes'] ?? []);
                final serverLikeCount = (data['likeCount'] as num?)?.toInt() ?? serverLikes.length;

                // Clear optimistic state when server state matches
                if (_optimisticLiked != null && serverLikes.contains(currentUserId) == _optimisticLiked) {
                  _optimisticLiked = null;
                  _optimisticLikeCount = null;
                }

                final isLiked = _optimisticLiked ?? serverLikes.contains(currentUserId);
                final likeCount = _optimisticLikeCount ?? serverLikeCount;
                final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

                return StreamBuilder<QuerySnapshot>(
                  stream: widget.postRepo.getCommentsStream(widget.postId),
                  builder: (context, commSnap) {
                    final commentCount = commSnap.hasData
                        ? commSnap.data!.docs.length
                        : ((data['commentCount'] as num?)?.toInt() ?? 0);

                    return SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PostDetailsHeader(
                            postId: widget.postId,
                            postOwnerId: postOwnerId,
                            postOwnerName: postOwnerName,
                            createdAt: createdAt,
                            lastEditedAt: data['lastEditedAt'],
                            currentUserId: currentUserId,
                            title: data['title'] ?? '',
                            description: data['description'] ?? '',
                            imageUrl: data['imageUrl'],
                            deleteHash: data['deleteHash'],
                          ),
                          PostDetailsContent(
                            title: data['title'] ?? '',
                            description: data['description'] ?? '',
                            imageUrl: data['imageUrl'],
                          ),
                          PostDetailsActionsBar(
                            postId: widget.postId,
                            postDoc: postDoc,
                            isLiked: isLiked,
                            likeCount: likeCount,
                            commentCount: commentCount,
                            serverLikes: serverLikes,
                            postRepo: widget.postRepo,
                            onToggleLike: () => _handleToggleLike(currentUserId, serverLikes, serverLikeCount),
                          ),
                          PostDetailsCommentsSection(
                            commSnap: commSnap,
                            currentUserId: currentUserId,
                            postOwnerId: postOwnerId,
                            isProcessing: _isProcessing,
                            onStartEditing: _startEditingComment,
                            onConfirmDelete: _confirmDeleteComment,
                            onRetry: () => setState(() {}),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          PostCommentInputBar(
            controller: _commentController,
            focusNode: _commentFocusNode,
            editingCommentId: _editingCommentId,
            isSendingComment: _isSendingComment,
            isProcessing: _isProcessing,
            onCancelEditing: _cancelEditingComment,
            onSubmit: _handleCommentSubmit,
          ),
        ],
      ),
    );
  }
}
