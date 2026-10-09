import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'web_colors.dart';

/// Typography system for ConnectHub Web Portfolio.
/// Cormorant Garamond for luxury headings, Inter for readable body.
class WebTextStyles {
  WebTextStyles._();

  static TextStyle displayHero({bool isDark = true}) => GoogleFonts.cormorantGaramond(
        fontSize: 58,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -1.0,
        color: isDark ? WebColors.textPrimary : WebColors.lightTextPrimary,
      );

  static TextStyle displayHeroMobile({bool isDark = true}) => GoogleFonts.cormorantGaramond(
        fontSize: 38,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.5,
        color: isDark ? WebColors.textPrimary : WebColors.lightTextPrimary,
      );

  static TextStyle sectionTitle({bool isDark = true}) => GoogleFonts.cormorantGaramond(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        height: 1.15,
        letterSpacing: -0.5,
        color: isDark ? WebColors.textPrimary : WebColors.lightTextPrimary,
      );

  static TextStyle sectionTitleMobile({bool isDark = true}) => GoogleFonts.cormorantGaramond(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.3,
        color: isDark ? WebColors.textPrimary : WebColors.lightTextPrimary,
      );

  static TextStyle sectionSubtitle({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.5,
        color: WebColors.primary,
      );

  static TextStyle cardTitle({bool isDark = true}) => GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: isDark ? WebColors.textPrimary : WebColors.lightTextPrimary,
      );

  static TextStyle cardSubtitle({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isDark ? WebColors.textSecondary : WebColors.lightTextSecondary,
      );

  static TextStyle bodyLarge({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.75,
        color: isDark ? WebColors.textSecondary : WebColors.lightTextSecondary,
      );

  static TextStyle bodyMedium({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.65,
        color: isDark ? WebColors.textSecondary : WebColors.lightTextSecondary,
      );

  static TextStyle bodySmall({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: isDark ? WebColors.textMuted : WebColors.lightTextMuted,
      );

  static TextStyle navLink({bool isActive = false, bool isDark = true}) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        letterSpacing: 0.8,
        color: isActive
            ? WebColors.primaryLight
            : (isDark ? WebColors.textSecondary : WebColors.lightTextSecondary),
      );

  static TextStyle techChip({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: WebColors.primaryLight,
      );

  static TextStyle buttonText() => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: WebColors.textDark,
      );

  static TextStyle statNumber({bool isDark = true}) => GoogleFonts.cormorantGaramond(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: isDark ? WebColors.textPrimary : WebColors.lightTextPrimary,
      );

  static TextStyle statLabel({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.8,
        color: isDark ? WebColors.textMuted : WebColors.lightTextMuted,
      );
}
