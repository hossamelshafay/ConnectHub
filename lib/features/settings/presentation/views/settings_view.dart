import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/theme/theme_cubit.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_state.dart';
import 'package:connecthub/features/auth/presentation/views/login_view.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_cubit.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_state.dart';
import 'package:connecthub/features/profile/presentation/views/edit_profile_view.dart';
import 'package:connecthub/features/settings/presentation/widgets/settings_account_header.dart';
import 'package:connecthub/features/settings/presentation/widgets/settings_sections.dart';

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
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: Center(
                child: AppIconButton(
                  icon: Icons.arrow_back_ios_new,
                  size: 18,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              title: Text('Settings', style: AppTextStyles.headline3),
              centerTitle: true,
            ),
            body: SafeArea(
              child: BlocBuilder<ProfileCubit, ProfileState>(
                builder: (context, profileState) {
                  final cubit = context.read<ProfileCubit>();
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    children: [
                      // ──────────────── Account Header ────────────────
                      if (profileState is ProfileLoaded)
                        SettingsAccountHeader(
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
                        const SettingsAccountHeaderSkeleton(),

                      const SizedBox(height: 28),

                      // ──────────────── Account Section ────────────────
                      SettingsAccountSection(cubit: cubit),

                      const SizedBox(height: 20),

                      // ──────────────── Preferences Section ────────────────
                      const SettingsPreferencesSection(),

                      const SizedBox(height: 20),

                      // ──────────────── Support Section ────────────────
                      SettingsSupportSection(
                        onAbout: () => _showAbout(context),
                        onComingSoon: (feature) =>
                            _showComingSoon(context, feature),
                      ),

                      const SizedBox(height: 20),

                      // ──────────────── Session Section ────────────────
                      const SettingsSessionSection(),

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
          );
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — Coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          gradient: LinearGradient(
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
