import 'package:flutter/material.dart';

/// Black + Gold luxury design tokens for ConnectHub Web Portfolio.
/// Inspired by premium luxury brands — cinematic, minimal, elegant.
///
/// Palette:
/// - Background : #090909
/// - Surface    : #141414
/// - Cards      : #1B1B1B
/// - Gold       : #D4AF37
/// - Light Gold : #F4D06F
/// - Text       : #F8F8F8
/// - Muted      : #A7A7A7
/// - Border     : rgba(212,175,55, 0.18)
class WebColors {
  WebColors._();

  // ── Light Palette (Warm Titanium / Beige — matches mockup) ──────────────────
  static const Color lightBackground       = Color(0xFFF3EFE9); // Warm Titanium Beige canvas
  static const Color lightSurface          = Color(0xFFFFFFFF); // Pristine ivory white cards
  static const Color lightSurfaceCard      = Color(0xFFFCFAF7); // Subtle warm tinted card
  static const Color lightSurfaceElevated  = Color(0xFFEFE9E0); // Elevated warm pill/plate
  static const Color lightBorder           = Color(0xFFE2DCD1); // Refined metallic hairline border
  static const Color lightBorderHover      = Color(0xFF88735C); // Warm Bronze hover
  static const Color lightBorderSubtle     = Color(0xFFECE6DC); // Extremely subtle divider
  static const Color lightPrimary          = Color(0xFF88735C); // Warm Bronze Titanium accent
  static const Color lightPrimaryLight     = Color(0xFFAFA08F); // Champagne titanium highlight
  static const Color lightPrimaryDark      = Color(0xFF5E4F3E); // Deep bronze cocoa
  static const Color lightTextPrimary      = Color(0xFF1B1917); // Obsidian graphite
  static const Color lightTextSecondary    = Color(0xFF5C554E); // Warm slate
  static const Color lightTextMuted        = Color(0xFF888076);
  static const Color lightTextHint         = Color(0xFFA39B90);

  // ── Dark Palette (Dark Titanium & Soft Graphite & Champagne Gold) ─────────
  static const Color darkBackground       = Color(0xFF121110); // Deep obsidian titanium
  static const Color darkSurface          = Color(0xFF1B1917); // Dark titanium cocoa graphite cards
  static const Color darkSurfaceCard      = Color(0xFF221F1C);
  static const Color darkSurfaceElevated  = Color(0xFF2A2622);
  static const Color darkBorder           = Color(0x29D4B982); // Metallic subtle champagne border
  static const Color darkBorderHover      = Color(0x66D4B982);
  static const Color darkBorderSubtle     = Color(0x18D4B982);
  static const Color darkPrimary          = Color(0xFFD4B982); // Metallic Champagne Gold
  static const Color darkPrimaryLight     = Color(0xFFE8D3A7);
  static const Color darkPrimaryDark      = Color(0xFFA38652);
  static const Color darkTextPrimary      = Color(0xFFFAF7F2); // Ivory White
  static const Color darkTextSecondary    = Color(0xFFB5ADA2);
  static const Color darkTextMuted        = Color(0xFF787268);
  static const Color darkTextHint         = Color(0xFF635D55);

  // ── Backward Compatible Static Defaults (Light by default to match mockup) ──
  static const Color background       = lightBackground;
  static const Color surface          = lightSurface;
  static const Color surfaceElevated  = lightSurfaceElevated;
  static const Color surfaceCard      = lightSurfaceCard;
  static const Color surfaceCardHover = Color(0xFFF7F3ED);
  static const Color border           = lightBorder;
  static const Color borderHover      = lightBorderHover;
  static const Color borderSubtle     = lightBorderSubtle;
  static const Color primary          = lightPrimary;
  static const Color primaryLight     = lightPrimaryLight;
  static const Color primaryDark      = lightPrimaryDark;
  static const Color accent           = lightPrimary;
  static const Color accentLight      = lightPrimaryLight;
  static const Color secondaryAccent  = lightPrimary;
  static const Color textPrimary      = lightTextPrimary;
  static const Color textSecondary    = lightTextSecondary;
  static const Color textMuted        = lightTextMuted;
  static const Color textDark         = Color(0xFF090909);

  // ── Dynamic Theme Helpers ──────────────────────────────────────────────────
  static Color getBackground({bool isDark = false}) => isDark ? darkBackground : lightBackground;
  static Color getSurface({bool isDark = false}) => isDark ? darkSurface : lightSurface;
  static Color getSurfaceCard({bool isDark = false}) => isDark ? darkSurfaceCard : lightSurfaceCard;
  static Color getSurfaceElevated({bool isDark = false}) => isDark ? darkSurfaceElevated : lightSurfaceElevated;
  static Color getBorder({bool isDark = false}) => isDark ? darkBorder : lightBorder;
  static Color getBorderHover({bool isDark = false}) => isDark ? darkBorderHover : lightBorderHover;
  static Color getBorderSubtle({bool isDark = false}) => isDark ? darkBorderSubtle : lightBorderSubtle;
  static Color getPrimary({bool isDark = false}) => isDark ? darkPrimary : lightPrimary;
  static Color getPrimaryLight({bool isDark = false}) => isDark ? darkPrimaryLight : lightPrimaryLight;
  static Color getPrimaryDark({bool isDark = false}) => isDark ? darkPrimaryDark : lightPrimaryDark;
  static Color getTextPrimary({bool isDark = false}) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color getTextSecondary({bool isDark = false}) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color getTextMuted({bool isDark = false}) => isDark ? darkTextMuted : lightTextMuted;

  // ── Status Colors ───────────────────────────────────────────────────────────
  static const Color emeraldAccent = Color(0xFF10B981); // availability badge
  static const Color cyanAccent    = Color(0xFF0EA5E9);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF88735C), Color(0xFFAFA08F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFF88735C), Color(0xFFAFA08F), Color(0xFF88735C)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFF88735C),
      Color(0xFFAFA08F),
      Color(0xFFD6C8B8),
      Color(0xFFAFA08F),
      Color(0xFF88735C),
    ],
    stops: [0.0, 0.3, 0.5, 0.7, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x0F88735C), Color(0x0388735C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
