import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/search/presentation/widgets/mention_autocomplete_overlay.dart';

class PostCommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? editingCommentId;
  final bool isSendingComment;
  final bool isProcessing;
  final VoidCallback onCancelEditing;
  final VoidCallback onSubmit;

  const PostCommentInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.editingCommentId,
    required this.isSendingComment,
    required this.isProcessing,
    required this.onCancelEditing,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            if (editingCommentId != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Editing comment',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onCancelEditing,
                      child: Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: MentionAutocompleteOverlay(
                      controller: controller,
                      showAbove: true,
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: AppTextStyles.body1,
                        decoration: InputDecoration(
                          hintText: editingCommentId != null
                              ? 'Edit your comment...'
                              : 'Write a comment... (use @ to mention)',
                          hintStyle: AppTextStyles.body2.copyWith(color: AppColors.textHint),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: (isSendingComment || isProcessing) ? null : onSubmit,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryDark,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: (isSendingComment || isProcessing)
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              editingCommentId != null ? Icons.check_rounded : Icons.send_rounded,
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
    );
  }
}
