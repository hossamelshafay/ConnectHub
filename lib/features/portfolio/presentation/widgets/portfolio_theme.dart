import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design Tokens (Warm Titanium & Apple Glassmorphism Aesthetics)
// ─────────────────────────────────────────────────────────────────────────────
Color get kPortfolioAccent        => AppColors.primary;

/// Translucent warm titanium / beige glass surface blending naturally with wallpaper
Color get kPortfolioCardBg        => AppColors.isDark
    ? const Color(0xB81C1A18)
    : const Color(0xB5F4ECE2);

/// Delicate titanium hairline border
Color get kPortfolioCardBorder    => AppColors.isDark
    ? const Color(0x30FFFFFF)
    : const Color(0x60D5C9B8);

/// Chip background for badges and tags
Color get kPortfolioChipBg        => AppColors.isDark
    ? const Color(0x402E2B27)
    : const Color(0x75EAE2D5);

Color get kPortfolioChipBorder    => AppColors.isDark
    ? const Color(0x28FFFFFF)
    : const Color(0x55D0C3B0);

/// Inner nested card surface
Color get kPortfolioInnerCardBg   => AppColors.isDark
    ? const Color(0x35282624)
    : const Color(0x55EFE7DC);

/// Action button glass background
Color get kPortfolioGlassButtonBg => AppColors.isDark
    ? const Color(0xC024221F)
    : const Color(0xC8F6EFE6);

Color get kPortfolioTextPrimary   => AppColors.textPrimary;
Color get kPortfolioTextSecondary => AppColors.textSecondary;
Color get kPortfolioTextMuted     => AppColors.textMuted;

const double kPortfolioRadius = 18.0;

/// Refined warm titanium elevation shadow
List<BoxShadow> get kPortfolioSoftShadow => [
  BoxShadow(
    color: AppColors.isDark
        ? const Color(0x28000000)
        : const Color(0x0C5C4F3D),
    blurRadius: 10,
    offset: const Offset(0, 3),
  ),
];
