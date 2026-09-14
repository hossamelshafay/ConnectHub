import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/auth/data/models/saved_account_model.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_state.dart';
import 'package:connecthub/features/auth/presentation/views/login_view.dart';

class ManageAccountsBottomSheet extends StatefulWidget {
  const ManageAccountsBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ManageAccountsBottomSheet(),
    );
  }

  @override
  State<ManageAccountsBottomSheet> createState() =>
      _ManageAccountsBottomSheetState();
}

class _ManageAccountsBottomSheetState
    extends State<ManageAccountsBottomSheet> {
  @override
  void initState() {
    super.initState();
    context.read<AuthCubit>().loadSavedAccounts();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header title
            Row(
              children: [
                Text('Accounts', style: AppTextStyles.headline3),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                List<SavedAccountModel> savedAccounts = [];
                SavedAccountModel? activeAccount;

                if (state is AuthSavedAccountsLoaded) {
                  savedAccounts = state.savedAccounts;
                  activeAccount = state.activeAccount;
                } else {
                  // Fallback while loading
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    activeAccount = SavedAccountModel(
                      uid: user.uid,
                      email: user.email ?? '',
                      displayName: user.displayName ?? 'User',
                      username: '',
                      profileImage: user.photoURL ?? '',
                    );
                    savedAccounts = [activeAccount];
                  }
                }

                // Find active and recent accounts
                SavedAccountModel? currentAccount = activeAccount;
                if (currentAccount == null && savedAccounts.isNotEmpty) {
                  try {
                    currentAccount = savedAccounts
                        .firstWhere((acc) => acc.uid == currentUid);
                  } catch (_) {
                    currentAccount = savedAccounts.first;
                  }
                }

                final recentAccounts = savedAccounts
                    .where((acc) => acc.uid != currentUid)
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Section: Current Account
                    Text(
                      'CURRENT ACCOUNT',
                      style: AppTextStyles.body2.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (currentAccount != null)
                      _buildCurrentAccountCard(context, currentAccount)
                    else
                      const SizedBox.shrink(),

                    const SizedBox(height: 20),

                    // Section: Recent Accounts
                    if (recentAccounts.isNotEmpty) ...[
                      Text(
                        'RECENT ACCOUNTS',
                        style: AppTextStyles.body2.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentAccounts.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final acc = recentAccounts[index];
                          return _buildRecentAccountTile(
                            context,
                            acc,
                            totalCount: savedAccounts.length,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                    ],

                    const Divider(height: 1, color: AppColors.divider),
                    const SizedBox(height: 16),

                    // Add Account button
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginView(
                              isAddingAccount: true,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Add Account',
                              style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentAccountCard(
      BuildContext context, SavedAccountModel account) {
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
            UserAvatar(
              name: account.displayName,
              imageUrl: account.profileImage,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  Widget _buildRecentAccountTile(
    BuildContext context,
    SavedAccountModel account, {
    required int totalCount,
  }) {
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
      onLongPress: () {
        _showRemoveAccountDialog(context, account, totalCount);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            UserAvatar(
              name: account.displayName,
              imageUrl: account.profileImage,
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
            const Icon(
              Icons.login_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveAccountDialog(
    BuildContext context,
    SavedAccountModel account,
    int totalCount,
  ) {
    if (totalCount <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('At least one account must remain on this device.'),
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
}
