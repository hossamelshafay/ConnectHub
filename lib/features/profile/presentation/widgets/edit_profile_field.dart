import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Single unified premium input control:
/// - ONE surface color throughout the entire component (no mixed white and beige).
/// - Completely removes the "box inside another box" look by disabling inherited TextField fills.
/// - Sleek iOS/macOS settings control with soft titanium/beige surface, subtle hairline border,
///   soft shadow, and refined focus glow.
class EditProfileField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const EditProfileField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.validator,
    this.onChanged,
  });

  @override
  State<EditProfileField> createState() => _EditProfileFieldState();
}

class _EditProfileFieldState extends State<EditProfileField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;

    // Single unified titanium/beige surface color for the entire control
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

    final labelColor = _isFocused
        ? (isDark ? AppColors.primary : const Color(0xFF5A4833))
        : (isDark ? AppColors.textSecondary : const Color(0xFF6B5842));

    final iconColor = _isFocused
        ? (isDark ? AppColors.primary : const Color(0xFFA67C52))
        : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: labelColor,
                letterSpacing: -0.1,
              ),
            ),
            if (widget.maxLength != null)
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.controller,
                builder: (context, value, _) {
                  return Text(
                    '${value.text.length}/${widget.maxLength}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textHint,
                    ),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 7),
        Focus(
          onFocusChange: (hasNav) => setState(() => _isFocused = hasNav),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOutCubic,
            decoration: BoxDecoration(
              color: _isFocused ? focusedBg : normalBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isFocused ? focusedBorder : normalBorder,
                width: _isFocused ? 1.3 : 0.9,
              ),
              boxShadow: shadow,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: widget.maxLines > 1 ? 7 : 3,
            ),
            child: TextFormField(
              controller: widget.controller,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              validator: widget.validator,
              onChanged: widget.onChanged,
              buildCounter: (context,
                      {required currentLength,
                      required isFocused,
                      maxLength}) =>
                  null,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                // Explicitly disable fill so the TextFormField never renders an inner box
                filled: false,
                fillColor: Colors.transparent,
                hoverColor: Colors.transparent,
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  color: AppColors.textHint,
                ),
                icon: widget.prefixIcon != null
                    ? Icon(widget.prefixIcon, size: 19, color: iconColor)
                    : null,
                suffixIcon: widget.suffixIcon,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: widget.maxLines > 1 ? 5 : 8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
