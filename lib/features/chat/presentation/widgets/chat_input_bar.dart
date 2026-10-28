import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Bottom input bar for composing and sending messages.
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSending;
  final VoidCallback onSend;
  final ValueChanged<String> onChanged;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isSending,
    required this.onSend,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 0.8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text field
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.glassBorder, width: 0.8),
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: 'Message…',
                    hintStyle: AppTextStyles.body2.copyWith(
                      color: AppColors.textHint,
                      fontSize: 13.5,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send button
            AnimatedScale(
              scale: controller.text.trim().isEmpty || isSending ? 0.88 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: GestureDetector(
                onTap: (controller.text.trim().isEmpty || isSending)
                    ? null
                    : onSend,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: (controller.text.trim().isEmpty || isSending)
                        ? LinearGradient(
                            colors: [
                              AppColors.surfaceVariant,
                              AppColors.surfaceVariant,
                            ],
                          )
                        : LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    shape: BoxShape.circle,
                    boxShadow: (controller.text.trim().isEmpty || isSending)
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                  ),
                  child: isSending
                      ? const Padding(
                          padding: EdgeInsets.all(11),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          Icons.arrow_upward_rounded,
                          color: (controller.text.trim().isEmpty || isSending)
                              ? AppColors.textHint
                              : Colors.white,
                          size: 19,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
