import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/theme/theme_cubit.dart';

/// Shows the theme selector bottom sheet (Light / Dark).
void showThemeBottomSheet(BuildContext context, bool isCurrentDark) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Text('Appearance', style: AppTextStyles.headline3),
              const SizedBox(height: 6),
              Text(
                'Choose your preferred visual theme',
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F2EE),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFFDCD5CA)),
                  ),
                  child: const Icon(Icons.light_mode_rounded,
                      color: Color(0xFF88735C), size: 20),
                ),
                title: Text(
                  'Light Mode',
                  style: AppTextStyles.body1
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle:
                    Text('Warm Titanium (Default)', style: AppTextStyles.caption),
                trailing: !isCurrentDark
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.success)
                    : null,
                onTap: () {
                  context
                      .read<ThemeCubit>()
                      .setTheme(ThemeMode.light);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF121110),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0x2AD4B982)),
                  ),
                  child: const Icon(Icons.dark_mode_rounded,
                      color: Color(0xFFD4B982), size: 20),
                ),
                title: Text(
                  'Dark Mode',
                  style: AppTextStyles.body1
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Dark Titanium & Champagne Gold',
                    style: AppTextStyles.caption),
                trailing: isCurrentDark
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.success)
                    : null,
                onTap: () {
                  context
                      .read<ThemeCubit>()
                      .setTheme(ThemeMode.dark);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}

/// Shows the language selector bottom sheet.
void showLanguageBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  title: Text(
                    'English',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                  trailing: Icon(
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
