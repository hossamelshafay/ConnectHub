import 'package:flutter/material.dart';
import 'web_colors.dart';

/// Web Portfolio Theme & Breakpoint Constants — Black/Gold luxury theme.
class WebTheme {
  WebTheme._();

  // Responsive Breakpoints
  static const double mobileBreakpoint  = 600;
  static const double tabletBreakpoint  = 900;
  static const double laptopBreakpoint  = 1200;
  static const double desktopBreakpoint = 1600;

  static const double maxContentWidth = 1240;
  static const double navBarHeight    = 76;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isLaptop(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tabletBreakpoint && width < laptopBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= laptopBreakpoint;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopBreakpoint;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: WebColors.background,
      primaryColor: WebColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: WebColors.primary,
        secondary: WebColors.accent,
        surface: WebColors.surface,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: WebColors.lightBackground,
      primaryColor: WebColors.primary,
      colorScheme: const ColorScheme.light(
        primary: WebColors.primary,
        secondary: WebColors.accent,
        surface: WebColors.lightSurface,
      ),
      useMaterial3: true,
    );
  }
}
