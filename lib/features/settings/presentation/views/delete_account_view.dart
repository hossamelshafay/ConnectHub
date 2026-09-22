import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/auth/data/repos/auth_repo_imp.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:connecthub/features/auth/presentation/views/login_view.dart';

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
    'Received and sent notifications',
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

  void _showPasswordPrompt() {
    final passwordController = TextEditingController();
    bool obscurePassword = true;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 20,
                  bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
                ),
                child: Form(
                  key: formKey,
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
                      const SizedBox(height: 18),

                      Text(
                        'Confirm Your Password',
                        style: AppTextStyles.headline3,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Please enter your password to authorize permanent deletion of your account.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        controller: passwordController,
                        hintText: 'Enter your password',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textHint,
                          ),
                          onPressed: () {
                            setSheetState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Delete confirmation button
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
                          onPressed: () {
                            if (!formKey.currentState!.validate()) return;
                            final password = passwordController.text.trim();
                            Navigator.pop(sheetContext);
                            _executeDeletion(password);
                          },
                          child: const Text(
                            'Permanently Delete Account',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      Center(
                        child: TextButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
                icon: const Icon(Icons.arrow_back_ios_rounded,
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
                    const SizedBox(height: 20),

                    // Warning banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.error,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Permanent Action',
                                style: AppTextStyles.headline3.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Deleting your account is permanent and irreversible. '
                            'Once deleted, all of your data, posts, comments, likes, and followers will be permanently removed.',
                            style: AppTextStyles.body2.copyWith(height: 1.55),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'The following will be permanently removed:',
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Bullet list of data that will be deleted
                    Expanded(
                      child: ListView(
                        children: DeleteAccountView._dataItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(item, style: AppTextStyles.body2),
                                ),
                              ],
                            ),
                          ),
                        ).toList(),
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

          // Non-dismissible full-screen progress overlay
          if (_isDeleting)
            Container(
              color: Colors.black.withValues(alpha: 0.75),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(AppColors.error),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Deleting Account',
                        style: AppTextStyles.headline3,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _deletionStep,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please do not close or exit the app...',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
