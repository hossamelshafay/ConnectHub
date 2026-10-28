import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Manages the application theme mode (Light/Dark).
/// Persists preference to [SharedPreferences].
/// Defaults to Light Mode (Warm Titanium).
class ThemeCubit extends Cubit<ThemeMode> {
  static const String _prefKey = 'app_theme_mode';
  final SharedPreferences _prefs;

  ThemeCubit(this._prefs) : super(_loadInitialMode(_prefs)) {
    AppColors.isDark = (state == ThemeMode.dark);
    _applySystemOverlay(AppColors.isDark);
  }

  static ThemeMode _loadInitialMode(SharedPreferences prefs) {
    final val = prefs.getString(_prefKey);
    if (val == 'dark') return ThemeMode.dark;
    // Default = Light (Warm Titanium)
    return ThemeMode.light;
  }

  bool get isDarkMode => state == ThemeMode.dark;

  Future<void> setTheme(ThemeMode mode) async {
    final isDark = mode == ThemeMode.dark;
    AppColors.isDark = isDark;
    _applySystemOverlay(isDark);
    await _prefs.setString(_prefKey, isDark ? 'dark' : 'light');
    emit(mode);
  }

  Future<void> toggleTheme() async {
    final next = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    await setTheme(next);
  }

  void _applySystemOverlay(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
    );
  }
}
