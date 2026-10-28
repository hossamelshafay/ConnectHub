import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/theme/theme_cubit.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:connecthub/features/auth/presentation/widgets/manage_accounts_bottom_sheet.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_cubit.dart';
import 'package:connecthub/features/profile/presentation/views/edit_profile_view.dart';
import 'package:connecthub/features/settings/presentation/views/change_email_view.dart';
import 'package:connecthub/features/settings/presentation/views/change_password_view.dart';
import 'package:connecthub/features/settings/presentation/views/delete_account_view.dart';
import 'package:connecthub/features/settings/presentation/widgets/logout_dialog.dart';
import 'package:connecthub/features/settings/presentation/widgets/settings_bottom_sheets.dart';
import 'package:connecthub/features/settings/presentation/widgets/settings_tile.dart';

/// Account management settings section.
class SettingsAccountSection extends StatelessWidget {
  final ProfileCubit cubit;

  const SettingsAccountSection({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
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
    );
  }
}

/// Appearance settings section.
class SettingsAppearanceSection extends StatelessWidget {
  const SettingsAppearanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, currentMode) {
        final isDark = currentMode == ThemeMode.dark;
        return SettingsSection(
          title: 'Appearance',
          tiles: [
            SettingsTile(
              icon: isDark
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              title: 'Theme',
              subtitle: isDark
                  ? 'Dark Mode'
                  : 'Light Mode (Warm Titanium)',
              trailing: Switch(
                value: isDark,
                onChanged: (val) {
                  context.read<ThemeCubit>().setTheme(
                        val ? ThemeMode.dark : ThemeMode.light,
                      );
                },
              ),
              onTap: () => showThemeBottomSheet(context, isDark),
            ),
          ],
        );
      },
    );
  }
}

/// Preferences settings section.
class SettingsPreferencesSection extends StatelessWidget {
  const SettingsPreferencesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Preferences',
      tiles: [
        SettingsTile(
          icon: Icons.language_rounded,
          title: 'Language',
          subtitle: 'English (default)',
          onTap: () => showLanguageBottomSheet(context),
        ),
      ],
    );
  }
}

/// Support & About settings section.
class SettingsSupportSection extends StatelessWidget {
  final VoidCallback onAbout;
  final void Function(String) onComingSoon;

  const SettingsSupportSection({
    super.key,
    required this.onAbout,
    required this.onComingSoon,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Support',
      tiles: [
        SettingsTile(
          icon: Icons.info_outline_rounded,
          title: 'About ConnectHub',
          subtitle: 'Version 1.0.0',
          onTap: onAbout,
        ),
        SettingsTile(
          icon: Icons.description_outlined,
          title: 'Terms of Service',
          onTap: () => onComingSoon('Terms of Service'),
        ),
        SettingsTile(
          icon: Icons.help_outline_rounded,
          title: 'Help & Support',
          onTap: () => onComingSoon('Help & Support'),
        ),
      ],
    );
  }
}

/// Session & Sign out settings section.
class SettingsSessionSection extends StatelessWidget {
  const SettingsSessionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'Session',
      tiles: [
        SettingsTile(
          icon: Icons.logout_rounded,
          title: 'Log Out',
          isDestructive: false,
          onTap: () => LogoutDialog.show(
            context,
            onConfirm: () => context.read<AuthCubit>().signOut(),
          ),
        ),
      ],
    );
  }
}
