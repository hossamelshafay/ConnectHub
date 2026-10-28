import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Shows a dialog informing the user that a verification email was sent.
Future<void> showChangeEmailVerificationDialog(
  BuildContext context, {
  required String newEmail,
  String? directUpdateError,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.mark_email_unread_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: 10),
          const Text('Verification Link Sent'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A verification link was sent to:\n$newEmail',
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            'Firebase Authentication requires you to click the link sent to your inbox to finalize the change before logging in with your new email.',
            style: AppTextStyles.body2,
          ),
          if (directUpdateError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Reason for verification email: Firebase project enforces email verification before update ($directUpdateError).',
                style: AppTextStyles.caption.copyWith(fontSize: 11),
              ),
            ),
          ],
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('I Understand'),
        ),
      ],
    ),
  );
}
