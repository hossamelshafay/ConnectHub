import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:connecthub/core/theme/theme_cubit.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Small, premium theme switcher button for the Profile screen.
///
/// Features:
/// - Smooth animated Sun ↔ Moon transition
/// - Circular reveal animation starting exactly from this icon via [animated_theme_switcher]
/// - Expanding circular reveal on Light → Dark
/// - Contracting circular reveal on Dark → Light
/// - Seamless sync with [ThemeCubit] and SharedPreferences persistence
class AnimatedThemeToggle extends StatelessWidget {
  const AnimatedThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeSwitcher(
      builder: (switcherContext) {
        return BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            final isDark = themeMode == ThemeMode.dark;

            return Tooltip(
              message: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  final nextMode = isDark ? ThemeMode.light : ThemeMode.dark;
                  final nextTheme =
                      isDark ? AppTheme.lightTheme : AppTheme.darkTheme;

                  // Update global reactive flag immediately for screenshot rendering
                  AppColors.isDark = !isDark;

                  // Trigger circular reveal animation:
                  // Light -> Dark: isReversed = false (circle expands from icon)
                  // Dark -> Light: isReversed = true (circle contracts back to icon)
                  ThemeSwitcher.of(switcherContext).changeTheme(
                    theme: nextTheme,
                    isReversed: isDark,
                    onAnimationFinish: () {
                      context.read<ThemeCubit>().setTheme(nextMode);
                    },
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.glass,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, anim) {
                        return RotationTransition(
                          turns: Tween<double>(begin: 0.75, end: 1.0).animate(anim),
                          child: ScaleTransition(
                            scale: anim,
                            child: FadeTransition(
                              opacity: anim,
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: Icon(
                        isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                        key: ValueKey(isDark ? 'moon_icon' : 'sun_icon'),
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
