import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'web_colors.dart';

/// Typography system for ConnectHub Web Portfolio.
/// Cormorant Garamond for luxury headings, Inter for readable body.
class WebTextStyles {
  WebTextStyles._();

  static TextStyle displayHero({bool isDark = false}) => GoogleFonts.plusJakartaSans(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -1.0,
        color: isDark ? WebColors.darkTextPrimary : WebColors.lightTextPrimary,
      );

  static TextStyle displayHeroMobile({bool isDark = false}) => GoogleFonts.plusJakartaSans(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        height: 1.2,
        letterSpacing: -0.5,
        color: isDark ? WebColors.darkTextPrimary : WebColors.lightTextPrimary,
      );

  static TextStyle sectionTitle({bool isDark = false}) => GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.4,
        color: isDark ? WebColors.darkTextPrimary : WebColors.lightTextPrimary,
      );

  static TextStyle sectionTitleMobile({bool isDark = false}) => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.2,
        color: isDark ? WebColors.darkTextPrimary : WebColors.lightTextPrimary,
      );

  static TextStyle sectionSubtitle({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.5,
        color: isDark ? WebColors.darkPrimary : WebColors.lightPrimary,
      );

  static TextStyle cardTitle({bool isDark = true}) => GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: isDark ? WebColors.darkTextPrimary : WebColors.lightTextPrimary,
      );

  static TextStyle cardSubtitle({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isDark ? WebColors.darkTextSecondary : WebColors.lightTextSecondary,
      );

  static TextStyle bodyLarge({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        height: 1.75,
        color: isDark ? WebColors.darkTextSecondary : WebColors.lightTextSecondary,
      );

  static TextStyle bodyMedium({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.65,
        color: isDark ? WebColors.darkTextSecondary : WebColors.lightTextSecondary,
      );

  static TextStyle bodySmall({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: isDark ? WebColors.darkTextSecondary : WebColors.lightTextSecondary,
      );

  static TextStyle navLink({bool isActive = false, bool isDark = true}) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
        letterSpacing: 0.8,
        color: isActive
            ? (isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary)
            : (isDark ? WebColors.darkTextSecondary : WebColors.lightTextSecondary),
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

  static TextStyle statNumber({bool isDark = false}) => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: isDark ? WebColors.darkTextPrimary : WebColors.lightTextPrimary,
      );

  static TextStyle statLabel({bool isDark = true}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.8,
        color: isDark ? WebColors.textMuted : WebColors.lightTextMuted,
      );
}
