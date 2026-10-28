import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ConnectHub Design System — Warm Titanium Light & Dark Mode
// Default: Warm Titanium Light (Apple-style productivity)
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  /// Global reactive theme flag.
  /// Set by [ThemeCubit]. Defaults to false (Light Mode).
  static bool isDark = false;

  // ── Light Palette (Warm Titanium Luxury) ──────────────────────────────────
  static const Color lightBackground     = Color(0xFFF4F2EE); // Crisp warm metallic titanium canvas
  static const Color lightSurface        = Color(0xFFFFFFFF); // Pristine ivory white cards
  static const Color lightSurfaceVariant = Color(0xFFEAE5DC); // Secondary polished titanium surface
  static const Color lightPrimary        = Color(0xFF88735C); // Warm Bronze Titanium accent
  static const Color lightPrimaryLight   = Color(0xFFAFA08F); // Champagne titanium highlight
  static const Color lightPrimaryDark    = Color(0xFF5E4F3E); // Deep Dark Cocoa bronze
  static const Color lightPrimarySoft    = Color(0x2488735C); // Delicate warm titanium tint
  static const Color lightBorder         = Color(0xFFDCD5CA); // Refined metallic hairline border
  static const Color lightTextPrimary    = Color(0xFF1B1917); // Deep high-contrast obsidian graphite
  static const Color lightTextSecondary  = Color(0xFF5C554E); // Warm graphite slate
  static const Color lightTextMuted      = Color(0xFF888076);
  static const Color lightTextHint       = Color(0xFFA39B90);
  static const Color lightDivider        = Color(0xFFE4DFD5);
  static const Color lightShadow         = Color(0x08000000); // Faint subtle Apple-style shadow

  // ── Dark Palette (Dark Titanium & Soft Graphite & Champagne Gold) ─────────
  static const Color darkBackground      = Color(0xFF121110); // Deep obsidian titanium (Apple Vision Pro)
  static const Color darkSurface         = Color(0xFF1B1917); // Dark titanium cocoa graphite cards
  static const Color darkSurfaceVariant  = Color(0xFF262320); // Elevated warm graphite plate
  static const Color darkPrimary         = Color(0xFFD4B982); // Metallic Champagne Gold
  static const Color darkPrimaryLight    = Color(0xFFE8D3A7); // Radiant champagne sheen
  static const Color darkPrimaryDark     = Color(0xFFA38652); // Burnished bronze depth
  static const Color darkPrimarySoft     = Color(0x28D4B982); // Luminous champagne glow
  static const Color darkGlass           = Color(0x18FFFFFF);
  static const Color darkGlassBorder      = Color(0x26FFFFFF);
  static const Color darkGlassHighlight   = Color(0x3DFFFFFF);
  static const Color darkTextPrimary     = Color(0xFFFAF7F2); // Ivory White
  static const Color darkTextSecondary   = Color(0xFFB5ADA2); // Soft metallic graphite
  static const Color darkTextMuted       = Color(0xFF787268);
  static const Color darkTextHint        = Color(0xFF635D55);
  static const Color darkDivider         = Color(0x1AFAF7F2);
  static const Color darkShadow          = Color(0x28000000); // Soft, refined dark shadow

  // ── Status Colors ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color error   = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // ── Adaptive Dynamic Color Getters ────────────────────────────────────────
  static Color get background     => isDark ? darkBackground : lightBackground;
  static Color get surface        => isDark ? darkSurface : lightSurface;
  static Color get surfaceVariant => isDark ? darkSurfaceVariant : lightSurfaceVariant;
  static Color get card           => isDark ? darkSurface : lightSurface;
  static Color get glass          => isDark ? darkGlass : lightSurface;
  static Color get glassBorder    => isDark ? darkGlassBorder : lightBorder;
  static Color get glassHighlight => isDark ? darkGlassHighlight : const Color(0x40FFFFFF);

  static Color get primary      => isDark ? darkPrimary : lightPrimary;
  static Color get primaryLight => isDark ? darkPrimaryLight : lightPrimaryLight;
  static Color get primaryDark  => isDark ? darkPrimaryDark : lightPrimaryDark;
  static Color get primarySoft  => isDark ? darkPrimarySoft : lightPrimarySoft;

  // Legacy aliases
  static Color get accent      => primary;
  static Color get accentLight => primaryLight;

  static Color get textPrimary   => isDark ? darkTextPrimary : lightTextPrimary;
  static Color get textSecondary => isDark ? darkTextSecondary : lightTextSecondary;
  static Color get textMuted     => isDark ? darkTextMuted : lightTextMuted;
  static Color get textHint      => isDark ? darkTextHint : lightTextHint;

  static Color get divider => isDark ? darkDivider : lightDivider;
  static Color get shadow  => isDark ? darkShadow : lightShadow;

  // ── Shimmer Theme Colors ──────────────────────────────────────────────────
  static Color get shimmerBase =>
      isDark ? const Color(0xFF262320) : const Color(0xFFE8E3DA);
  static Color get shimmerHighlight =>
      isDark ? const Color(0xFF38332D) : const Color(0xFFF7F5F0);

  static Color get cardGradientStart => surface;
  static Color get cardGradientEnd   => surfaceVariant;
}

/// Subtle, professional elevation system (Apple / GitHub / Linear style)
class AppShadows {
  AppShadows._();

  /// Small elevation: Almost invisible (cards, list tiles, input bars, chips)
  static List<BoxShadow> get small => [
    BoxShadow(
      color: AppColors.isDark ? const Color(0x18000000) : const Color(0x06000000),
      blurRadius: 6,
      offset: const Offset(0, 1.5),
    ),
  ];

  /// Medium elevation: Soft (floating action bars, dropdowns, popups)
  static List<BoxShadow> get medium => [
    BoxShadow(
      color: AppColors.isDark ? const Color(0x28000000) : const Color(0x0A000000),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ];

  /// Large elevation: For dialogs and modal bottom sheets only
  static List<BoxShadow> get large => [
    BoxShadow(
      color: AppColors.isDark ? const Color(0x40000000) : const Color(0x12000000),
      blurRadius: 24,
      offset: const Offset(0, 6),
    ),
  ];
}

class AppTextStyles {
  AppTextStyles._();

  static const String _font = 'Inter';

  static TextStyle get headline1 => TextStyle(
    fontFamily: _font,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static TextStyle get headline2 => TextStyle(
    fontFamily: _font,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
    height: 1.25,
  );

  static TextStyle get headline3 => TextStyle(
    fontFamily: _font,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle get body1 => TextStyle(
    fontFamily: _font,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.55,
  );

  static TextStyle get body2 => TextStyle(
    fontFamily: _font,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static TextStyle get caption => TextStyle(
    fontFamily: _font,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.4,
  );

  static TextStyle get button => const TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: -0.2,
  );

  static TextStyle get label => TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get theme => AppColors.isDark ? darkTheme : lightTheme;

  // ── Warm Titanium Light Theme ─────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,

      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        secondary: AppColors.lightPrimaryLight,
        surface: AppColors.lightSurface,
        surfaceContainerHighest: AppColors.lightSurfaceVariant,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(
          color: AppColors.lightTextPrimary,
          size: 20,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightTextPrimary,
          side: const BorderSide(color: AppColors.lightBorder, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.lightTextHint,
          fontSize: 14.5,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.lightTextSecondary,
          fontSize: 14,
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.error,
          fontSize: 12,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
        space: 1,
      ),

      iconTheme: const IconThemeData(
        color: AppColors.lightTextSecondary,
        size: 20,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shadowColor: const Color(0x0A000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.lightTextPrimary,
          fontSize: 14,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.lightTextSecondary,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightTextPrimary,
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          color: Colors.white,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return AppColors.lightTextHint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.lightPrimary;
          }
          return AppColors.lightSurfaceVariant;
        }),
      ),
    );
  }

  // ── Dark Glass Theme (Preserved) ──────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkPrimaryLight,
        surface: AppColors.darkSurface,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        error: AppColors.error,
        onPrimary: Color(0xFF141210),
        onSecondary: Color(0xFF141210),
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(
          color: AppColors.darkTextPrimary,
          size: 20,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: const Color(0xFF141210),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          side: const BorderSide(color: AppColors.darkPrimary, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGlass,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkGlassBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkGlassBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: AppColors.darkPrimary.withValues(alpha: 0.7),
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.darkTextHint,
          fontSize: 14.5,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.darkTextSecondary,
          fontSize: 14,
        ),
        errorStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.error,
          fontSize: 12,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.darkGlassBorder, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      iconTheme: const IconThemeData(
        color: AppColors.darkTextSecondary,
        size: 20,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkSurfaceVariant,
        elevation: 2,
        shadowColor: const Color(0x30000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.darkGlassBorder, width: 1),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.darkTextPrimary,
          fontSize: 14,
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkGlassBorder, width: 1),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: AppColors.darkTextSecondary,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.darkTextPrimary,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.darkPrimary;
          return AppColors.darkTextHint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPrimary.withValues(alpha: 0.3);
          }
          return AppColors.darkGlassBorder;
        }),
      ),
    );
  }
}
