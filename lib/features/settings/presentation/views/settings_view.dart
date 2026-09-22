import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_state.dart';
import 'package:connecthub/features/auth/presentation/views/login_view.dart';
import 'package:connecthub/features/auth/presentation/widgets/manage_accounts_bottom_sheet.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_cubit.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_state.dart';
import 'package:connecthub/features/profile/presentation/views/edit_profile_view.dart';
import 'package:connecthub/features/settings/presentation/views/change_email_view.dart';
import 'package:connecthub/features/settings/presentation/views/change_password_view.dart';
import 'package:connecthub/features/settings/presentation/views/delete_account_view.dart';
import 'package:connecthub/features/settings/presentation/widgets/settings_tile.dart';

/// Full Settings screen with grouped sections.
/// Opened from ProfileView via the gear icon.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..loadProfile(),
      child: const _SettingsBody(),
    );
  }
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginView()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
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
          title: Text('Settings', style: AppTextStyles.headline3),
        ),
        body: SafeArea(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              final cubit = context.read<ProfileCubit>();
              return ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // ──────────────── Account Header ────────────────
                  if (profileState is ProfileLoaded)
                    _AccountHeader(
                      displayName: profileState.displayName,
                      username: profileState.username,
                      email: profileState.email,
                      profileImage: profileState.profileImage,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: const EditProfileView(),
                          ),
                        ),
                      ),
                    )
                  else
                    _AccountHeaderSkeleton(),

                  const SizedBox(height: 28),

                  // ──────────────── Account Section ────────────────
                  SettingsSection(
                    title: 'Account',
                    tiles: [
                      SettingsTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profile',
                        subtitle: 'Update name, bio and avatar',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: cubit,
                                child: const EditProfileView(),
                              ),
                            ),
                          );
                        },
                      ),
                      SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Change Password',
                        subtitle: 'Update your account password',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePasswordView(),
                          ),
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.email_outlined,
                        title: 'Change Email',
                        subtitle: 'Update your email address',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider.value(value: cubit),
                                BlocProvider.value(
                                  value: context.read<AuthCubit>(),
                                ),
                              ],
                              child: const ChangeEmailView(),
                            ),
                          ),
                        ),
                      ),
                      SettingsTile(
                        icon: Icons.manage_accounts_rounded,
                        title: 'Manage Accounts',
                        subtitle: 'Switch between saved accounts',
                        onTap: () => ManageAccountsBottomSheet.show(context),
                      ),
                      SettingsTile(
                        icon: Icons.delete_forever_rounded,
                        title: 'Delete Account',
                        subtitle: 'Permanently remove your account',
                        isDestructive: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<AuthCubit>(),
                              child: const DeleteAccountView(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ──────────────── Preferences Section ────────────────
                  SettingsSection(
                    title: 'Preferences',
                    tiles: [
                      SettingsTile(
                        icon: Icons.language_rounded,
                        title: 'Language',
                        subtitle: 'English (default)',
                        onTap: () => _showLanguageBottomSheet(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ──────────────── Support Section ────────────────
                  SettingsSection(
                    title: 'Support',
                    tiles: [
                      SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'About ConnectHub',
                        subtitle: 'Version 1.0.0',
                        onTap: () => _showAbout(context),
                      ),
                      SettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        onTap: () => _showComingSoon(context, 'Terms of Service'),
                      ),
                      SettingsTile(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        onTap: () => _showComingSoon(context, 'Help & Support'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ──────────────── Session Section ────────────────
                  SettingsSection(
                    title: 'Session',
                    tiles: [
                      SettingsTile(
                        icon: Icons.logout_rounded,
                        title: 'Log Out',
                        isDestructive: false,
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // App version footer
                  Center(
                    child: Text(
                      'ConnectHub v1.0.0',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text('Select Language', style: AppTextStyles.headline3),
                const SizedBox(height: 6),
                Text(
                  'Choose your preferred language for the interface',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: const Text(
                      '🇺🇸',
                      style: TextStyle(fontSize: 24),
                    ),
                    title: const Text(
                      'English',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    onTap: () => Navigator.pop(ctx),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out? '
          'Your saved accounts will remain intact.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().signOut();
              // Navigation is handled by the BlocListener above.
            },
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — Coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ConnectHub',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.hub_rounded,
          color: Colors.white,
          size: 30,
        ),
      ),
      children: [
        const Text(
          'ConnectHub is a modern social networking app built with Flutter and Firebase.',
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Account Header
// ─────────────────────────────────────────────────────────────────────────────

class _AccountHeader extends StatelessWidget {
  final String displayName;
  final String username;
  final String email;
  final String? profileImage;
  final VoidCallback onTap;

  const _AccountHeader({
    required this.displayName,
    required this.username,
    required this.email,
    this.profileImage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Hero(
              tag: 'settings_avatar',
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.surfaceVariant,
                backgroundImage:
                    (profileImage != null && profileImage!.isNotEmpty)
                        ? CachedNetworkImageProvider(profileImage!)
                        : null,
                child: (profileImage == null || profileImage!.isEmpty)
                    ? const Icon(Icons.person_rounded,
                        size: 30, color: AppColors.textHint)
                    : null,
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName.isEmpty ? 'User' : displayName,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    username.startsWith('@') ? username : '@$username',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),

            // Edit arrow
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountHeaderSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.surfaceVariant,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 11,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
