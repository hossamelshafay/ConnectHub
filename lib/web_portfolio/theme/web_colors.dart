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

  // ── Core Backgrounds ────────────────────────────────────────────────────────
  static const Color background       = Color(0xFF090909);
  static const Color surface          = Color(0xFF141414);
  static const Color surfaceElevated  = Color(0xFF1B1B1B);
  static const Color surfaceCard      = Color(0xFF1B1B1B);
  static const Color surfaceCardHover = Color(0xFF222222);

  // ── Borders ─────────────────────────────────────────────────────────────────
  /// rgba(212,175,55, 0.18)
  static const Color border       = Color(0x2ED4AF37);
  static const Color borderHover  = Color(0x66D4AF37);
  static const Color borderSubtle = Color(0x14D4AF37);

  // ── Gold Accents ─────────────────────────────────────────────────────────────
  static const Color primary          = Color(0xFFD4AF37); // Gold
  static const Color primaryLight     = Color(0xFFF4D06F); // Light Gold
  static const Color primaryDark      = Color(0xFF9E7F1A); // Deep Gold
  static const Color accent           = Color(0xFFD4AF37); // alias
  static const Color accentLight      = Color(0xFFF4D06F); // alias
  static const Color secondaryAccent  = Color(0xFFD4AF37); // kept for compat

  // ── Text ─────────────────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFFF8F8F8);
  static const Color textSecondary  = Color(0xFFA7A7A7);
  static const Color textMuted      = Color(0xFF6B6B6B);
  static const Color textDark       = Color(0xFF090909);

  // ── Gradients ────────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF4D06F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cinematic diagonal shimmer sweep (used with ShaderMask + animation).
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFFD4AF37), // gold
      Color(0xFFF4D06F), // light gold
      Color(0xFFFFEA8A), // bright highlight
      Color(0xFFF4D06F), // light gold
      Color(0xFFD4AF37), // gold
    ],
    stops: [0.0, 0.3, 0.5, 0.7, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient textGradient = LinearGradient(
    colors: [Color(0xFFF8F8F8), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF4D06F), Color(0xFFD4AF37)],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x0FD4AF37), Color(0x05D4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Light Mode (kept for compat — portfolio is primarily dark) ───────────────
  static const Color lightBackground       = Color(0xFFF5F0E8);
  static const Color lightSurface          = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated  = Color(0xFFF8F3E8);
  static const Color lightBorder           = Color(0x33D4AF37);
  static const Color lightTextPrimary      = Color(0xFF1A1A1A);
  static const Color lightTextSecondary    = Color(0xFF5A5A5A);
  static const Color lightTextMuted        = Color(0xFF8A8A8A);

  // ── Status ───────────────────────────────────────────────────────────────────
  static const Color emeraldAccent = Color(0xFF10B981); // availability badge
  static const Color cyanAccent    = Color(0xFFD4AF37); // alias kept for compat
}
