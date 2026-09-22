import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/auth/data/repos/auth_repo_imp.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_cubit.dart';

class ChangeEmailView extends StatefulWidget {
  const ChangeEmailView({super.key});

  @override
  State<ChangeEmailView> createState() => _ChangeEmailViewState();
}

class _ChangeEmailViewState extends State<ChangeEmailView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    if (!_formKey.currentState!.validate()) return;

    final currentPassword = _passwordController.text.trim();
    final newEmail = _emailController.text.trim();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User session not found. Please log in again.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (newEmail.toLowerCase() == user.email!.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New email cannot be the same as your current email.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Re-authenticate user with current password
      // ignore: avoid_print
      print('=== [ChangeEmail] Re-authenticating current user (${user.email}) ===');
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      // ignore: avoid_print
      print('=== [ChangeEmail] Reauthentication SUCCESS ===');

      bool isDirectUpdate = false;
      String? directUpdateError;

      // 2. Update email in Firebase Authentication
      try {
        // ignore: avoid_print
        print('=== [ChangeEmail] Attempting direct updateEmail("$newEmail") ===');
        // ignore: deprecated_member_use
        await user.updateEmail(newEmail);
        isDirectUpdate = true;
        // ignore: avoid_print
        print('=== [ChangeEmail] updateEmail() SUCCESS directly! ===');
      } on FirebaseAuthException catch (e) {
        directUpdateError = '${e.code}: ${e.message}';
        // ignore: avoid_print
        print('=== [ChangeEmail] updateEmail() threw FirebaseAuthException ===');
        // ignore: avoid_print
        print('Code: ${e.code}');
        // ignore: avoid_print
        print('Message: ${e.message}');
        // ignore: avoid_print
        print('=== [ChangeEmail] Falling back to verifyBeforeUpdateEmail("$newEmail") ===');
        try {
          await user.verifyBeforeUpdateEmail(newEmail);
          // ignore: avoid_print
          print('=== [ChangeEmail] verifyBeforeUpdateEmail() dispatched email link ===');
        } on FirebaseAuthException catch (vError) {
          // ignore: avoid_print
          print('=== [ChangeEmail] verifyBeforeUpdateEmail() threw FirebaseAuthException ===');
          // ignore: avoid_print
          print('Code: ${vError.code}');
          // ignore: avoid_print
          print('Message: ${vError.message}');
          rethrow;
        }
      } catch (e) {
        directUpdateError = e.toString();
        // ignore: avoid_print
        print('=== [ChangeEmail] updateEmail() threw Generic Exception: $e ===');
        await user.verifyBeforeUpdateEmail(newEmail);
      }

      // 3. Reload Firebase User to refresh local Auth token & email
      await user.reload();
      final reloadedUser = FirebaseAuth.instance.currentUser;
      final actualAuthEmail = reloadedUser?.email ?? '';

      // ignore: avoid_print
      print('=== [ChangeEmail] Post-reload FirebaseAuth.instance.currentUser?.email: "$actualAuthEmail" ===');
      final bool emailUpdatedInAuth =
          actualAuthEmail.toLowerCase() == newEmail.toLowerCase() || isDirectUpdate;

      // 4. Update email in Firestore users collection if updated or sync
      if (emailUpdatedInAuth) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'email': newEmail,
        });
        // ignore: avoid_print
        print('=== [ChangeEmail] Firestore users/${user.uid}.email updated to "$newEmail" ===');
      } else {
        // ignore: avoid_print
        print('=== [ChangeEmail] Auth email is still "$actualAuthEmail" pending verification link click ===');
      }

      // 5. Update local saved accounts store
      await AuthRepoImp().syncCurrentAccountToSaved();

      // 6. Refresh AuthCubit and ProfileCubit
      if (mounted) {
        try {
          context.read<AuthCubit>().reloadUser();
        } catch (_) {}
        try {
          context.read<ProfileCubit>().loadProfile();
        } catch (_) {}

        if (emailUpdatedInAuth) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Email updated to $newEmail! You can now sign in with your new email.'),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          // Alert the user that a confirmation link was sent
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.mark_email_unread_rounded, color: AppColors.primary, size: 28),
                  SizedBox(width: 10),
                  Text('Verification Link Sent'),
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

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMsg;
        switch (e.code) {
          case 'wrong-password':
          case 'invalid-credential':
            errorMsg = 'Current password is incorrect.';
            break;
          case 'email-already-in-use':
            errorMsg = 'This email address is already associated with another account.';
            break;
          case 'invalid-email':
            errorMsg = 'Please enter a valid email address.';
            break;
          case 'requires-recent-login':
            errorMsg = 'For security reasons, please log out and log back in before updating your email.';
            break;
          default:
            errorMsg = AuthRepoImp().getErrorMessage(e.code);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg.isNotEmpty ? msg : 'Failed to update email.'),
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Change Email', style: AppTextStyles.headline3),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info header card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.mail_outline_rounded,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Email',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentEmail.isNotEmpty ? currentEmail : 'No email set',
                              style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // New Email
                Text(
                  'New Email Address',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'Enter new email address',
                  prefixIcon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a new email address';
                    }
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Current Password
                Text(
                  'Current Password',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _passwordController,
                  hintText: 'Enter current password to confirm',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textHint,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your current password';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 36),

                // Submit button
                PrimaryButton(
                  text: 'Update Email',
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _updateEmail,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
