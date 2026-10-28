import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/auth/data/models/saved_account_model.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:connecthub/features/auth/presentation/views/login_view.dart';

class CurrentAccountCard extends StatelessWidget {
  final SavedAccountModel account;

  const CurrentAccountCard({
    super.key,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    final usernameText = account.username.isNotEmpty
        ? '@${account.username}'
        : (account.email.isNotEmpty ? account.email : '');

    return InkWell(
      onTap: () {
        // Tapping current account simply closes bottom sheet
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            UserAvatarById(
              userId: account.uid,
              fallbackName: account.displayName,
              fallbackImageUrl: account.profileImage,
              size: 46,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.displayName,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (usernameText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      usernameText,
                      style: AppTextStyles.body2.copyWith(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
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

class RecentAccountTile extends StatelessWidget {
  final SavedAccountModel account;
  final int totalCount;

  const RecentAccountTile({
    super.key,
    required this.account,
    required this.totalCount,
  });

  void _showRemoveAccountDialog(BuildContext context) {
    if (totalCount <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('At least one account must remain on this device.'),
          backgroundColor: AppColors.textSecondary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Remove Account'),
        content: Text(
          'Are you sure you want to remove "${account.displayName}" from this device? This will not delete the Firebase account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              context.read<AuthCubit>().removeSavedAccount(account.uid);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usernameText = account.username.isNotEmpty
        ? '@${account.username}'
        : (account.email.isNotEmpty ? account.email : '');

    return InkWell(
      onTap: () {
        // Tapping recent account opens LoginView with prefilled email
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LoginView(
              isAddingAccount: true,
              initialEmail: account.email,
            ),
          ),
        );
      },
      onLongPress: () => _showRemoveAccountDialog(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            UserAvatarById(
              userId: account.uid,
              fallbackName: account.displayName,
              fallbackImageUrl: account.profileImage,
              size: 44,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.displayName,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (usernameText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      usernameText,
                      style: AppTextStyles.body2.copyWith(
                        fontSize: 13,
                        color: AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.login_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
