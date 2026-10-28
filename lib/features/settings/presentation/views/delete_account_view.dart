import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/auth/data/repos/auth_repo_imp.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:connecthub/features/auth/presentation/views/login_view.dart';
import 'package:connecthub/features/settings/presentation/widgets/delete_account_password_sheet.dart';
import 'package:connecthub/features/settings/presentation/widgets/delete_account_progress_overlay.dart';
import 'package:connecthub/features/settings/presentation/widgets/delete_account_warning_section.dart';

/// Screen allowing the user to review the consequences of account deletion,
/// confirm their password, and monitor progress through a safe, non-dismissible
/// deletion overlay.
class DeleteAccountView extends StatefulWidget {
  const DeleteAccountView({super.key});

  static const List<String> _dataItems = [
    'All your posts and published content',
    'All comments you have written on any post',
    'All likes and reactions you have given',
    'Follower and following relationships',
    'Direct messages and conversations',
    'Received and sent notifications',
    'Portfolio items and published website',
    'Your profile, username, and bio',
    'Saved accounts on this device',
    'Your Firebase Authentication account',
  ];

  @override
  State<DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends State<DeleteAccountView> {
  bool _isDeleting = false;
  String _deletionStep = 'Preparing deletion...';

  Future<void> _showPasswordPrompt() async {
    final password = await showDeleteAccountPasswordSheet(context);
    if (password != null && mounted) {
      _executeDeletion(password);
    }
  }

  Future<void> _executeDeletion(String password) async {
    setState(() {
      _isDeleting = true;
      _deletionStep = 'Re-authenticating your account...';
    });

    try {
      final authRepo = AuthRepoImp();
      await authRepo.deleteAccount(
        password: password,
        onProgress: (step) {
          if (mounted) {
            setState(() {
              _deletionStep = step;
            });
          }
        },
      );

      if (mounted) {
        try {
          context.read<AuthCubit>().emitUnauthenticated();
        } catch (_) {}

        // Navigate completely to LoginView
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your account and all associated data have been permanently deleted.',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.textPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        String errorMsg;
        switch (e.code) {
          case 'wrong-password':
          case 'invalid-credential':
            errorMsg = 'Incorrect password. Deletion was aborted.';
            break;
          case 'requires-recent-login':
            errorMsg =
                'For security reasons, please log out and log back in before deleting your account.';
            break;
          default:
            errorMsg = AuthRepoImp().getErrorMessage(e.code);
        }
        _showErrorDialog(errorMsg);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        final msg = e.toString().replaceAll('Exception: ', '');
        _showErrorDialog(
          msg.isNotEmpty ? msg : 'An error occurred during account deletion.',
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColors.error, size: 28),
            SizedBox(width: 10),
            Text('Deletion Aborted'),
          ],
        ),
        content: Text(
          message,
          style: AppTextStyles.body2,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDeleting,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_rounded,
                    color: AppColors.textPrimary),
                onPressed: _isDeleting ? null : () => Navigator.pop(context),
              ),
              title: Text('Delete Account', style: AppTextStyles.headline3),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DeleteAccountWarningSection(
                        dataItems: DeleteAccountView._dataItems,
                      ),
                    ),

                    // CTA button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isDeleting ? null : _showPasswordPrompt,
                        child: const Text(
                          'I Understand, Delete My Account',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _isDeleting ? null : () => Navigator.pop(context),
                        child: Text(
                          'Cancel, Keep My Account',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          if (_isDeleting)
            DeleteAccountProgressOverlay(step: _deletionStep),
        ],
      ),
    );
  }
}
