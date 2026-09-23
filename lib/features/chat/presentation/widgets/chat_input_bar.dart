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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
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
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 6,
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.body1,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: 'Message…',
                    hintStyle:
                        AppTextStyles.body2.copyWith(color: AppColors.textHint),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send button
            AnimatedScale(
              scale: controller.text.trim().isEmpty || isSending ? 0.85 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: GestureDetector(
                onTap: (controller.text.trim().isEmpty || isSending)
                    ? null
                    : onSend,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: (controller.text.trim().isEmpty || isSending)
                        ? LinearGradient(
                            colors: [
                              AppColors.textHint.withValues(alpha: 0.3),
                              AppColors.textHint.withValues(alpha: 0.3),
                            ],
                          )
                        : const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    shape: BoxShape.circle,
                  ),
                  child: isSending
                      ? const Padding(
                          padding: EdgeInsets.all(13),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
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
