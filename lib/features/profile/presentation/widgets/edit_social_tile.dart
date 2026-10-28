import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/profile/presentation/widgets/social_icons.dart';

/// Clean, seamless tile for editing a standard social platform link:
/// - Shares the EXACT same design language, colors, borders, and shadows as EditProfileField.
/// - Single unified titanium/beige surface with zero inner boxes or dividers.
/// - Perfectly centered optical brand icon.
class SocialInputTile extends StatefulWidget {
  final SocialPlatformMeta meta;
  final TextEditingController controller;

  const SocialInputTile({
    super.key,
    required this.meta,
    required this.controller,
  });

  @override
  State<SocialInputTile> createState() => _SocialInputTileState();
}

class _SocialInputTileState extends State<SocialInputTile> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    // Single unified titanium/beige surface matching EditProfileField
    final normalBg = isDark
        ? const Color(0x352A2622)
        : const Color(0xFFEFE8DE);
    final focusedBg = isDark
        ? const Color(0x50302B26)
        : const Color(0xFFF6F0E6);

    final normalBorder = isDark
        ? const Color(0x28FFFFFF)
        : const Color(0x65D0C4B2);
    final focusedBorder = isDark
        ? AppColors.primary
        : const Color(0xFFA67C52);

    final shadow = _isFocused
        ? [
            BoxShadow(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.20)
                  : const Color(0x24A67C52),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : [
            BoxShadow(
              color: isDark
                  ? const Color(0x10000000)
                  : const Color(0x0A5C4A33),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ];

    final iconColor = _isFocused
        ? (isDark ? AppColors.primary : const Color(0xFFA67C52))
        : AppColors.textPrimary;

    return Focus(
      onFocusChange: (hasNav) => setState(() => _isFocused = hasNav),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        height: 48,
        decoration: BoxDecoration(
          color: _isFocused ? focusedBg : normalBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isFocused ? focusedBorder : normalBorder,
            width: _isFocused ? 1.3 : 0.9,
          ),
          boxShadow: shadow,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Perfectly Centered Optical Brand Icon ───────────────
            SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: widget.meta.iconBuilder(
                  context,
                  size: 19,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Platform Title Label ────────────────────────────────
            SizedBox(
              width: 76,
              child: Text(
                widget.meta.title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: _isFocused
                      ? (isDark ? AppColors.primary : const Color(0xFF5A4833))
                      : AppColors.textPrimary,
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),

            // ── Unified Input (Zero Inner White Fill) ────────────────
            Expanded(
              child: TextField(
                controller: widget.controller,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  filled: false,
                  fillColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  hintText: widget.meta.hint,
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textHint,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clean, seamless tile for editing a custom user link:
/// - Shares the exact same unified surface color, border, and shadows.
class CustomLinkTile extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController urlController;
  final VoidCallback onRemove;

  const CustomLinkTile({
    super.key,
    required this.titleController,
    required this.urlController,
    required this.onRemove,
  });

  @override
  State<CustomLinkTile> createState() => _CustomLinkTileState();
}

class _CustomLinkTileState extends State<CustomLinkTile> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    final normalBg = isDark
        ? const Color(0x352A2622)
        : const Color(0xFFEFE8DE);
    final focusedBg = isDark
        ? const Color(0x50302B26)
        : const Color(0xFFF6F0E6);

    final normalBorder = isDark
        ? const Color(0x28FFFFFF)
        : const Color(0x65D0C4B2);
    final focusedBorder = isDark
        ? AppColors.primary
        : const Color(0xFFA67C52);

    final shadow = _isFocused
        ? [
            BoxShadow(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.20)
                  : const Color(0x24A67C52),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
        : [
            BoxShadow(
              color: isDark
                  ? const Color(0x10000000)
                  : const Color(0x0A5C4A33),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ];

    final iconColor = _isFocused
        ? (isDark ? AppColors.primary : const Color(0xFFA67C52))
        : AppColors.textPrimary;

    return Focus(
      onFocusChange: (hasNav) => setState(() => _isFocused = hasNav),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
        height: 48,
        decoration: BoxDecoration(
          color: _isFocused ? focusedBg : normalBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isFocused ? focusedBorder : normalBorder,
            width: _isFocused ? 1.3 : 0.9,
          ),
          boxShadow: shadow,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Perfectly Centered Link Icon ─────────────────────────
            SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: Icon(
                  Icons.link_rounded,
                  size: 20,
                  color: iconColor,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Title Input ─────────────────────────────────────────
            SizedBox(
              width: 76,
              child: TextField(
                controller: widget.titleController,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  filled: false,
                  fillColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  hintText: 'Label',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: AppColors.textHint,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // ── URL Input ───────────────────────────────────────────
            Expanded(
              child: TextField(
                controller: widget.urlController,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  filled: false,
                  fillColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  hintText: 'https://...',
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    color: AppColors.textHint,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // ── Clean Delete Action ─────────────────────────────────
            GestureDetector(
              onTap: widget.onRemove,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 17,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
