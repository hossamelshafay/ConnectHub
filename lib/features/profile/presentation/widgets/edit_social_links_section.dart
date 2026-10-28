import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/profile/presentation/widgets/social_icons.dart';
import 'package:connecthub/features/profile/presentation/widgets/edit_social_tile.dart';

/// Clean and scannable Links editor section:
/// - Supports all persistent platforms (GitHub, LinkedIn, Website, Instagram, X, Facebook,
///   YouTube, Behance, Dribbble, Medium, Discord, Telegram, TikTok, Custom Links).
/// - Default preview of top 4 primary platforms with expandable view for the full list.
/// - Centered 32x32 brand icons and modern focus glow.
class EditSocialLinksSection extends StatefulWidget {
  final Map<String, TextEditingController> controllers;
  final List<MapEntry<TextEditingController, TextEditingController>> customLinkControllers;
  final VoidCallback onAddCustomLink;
  final void Function(int index) onRemoveCustomLink;

  const EditSocialLinksSection({
    super.key,
    required this.controllers,
    required this.customLinkControllers,
    required this.onAddCustomLink,
    required this.onRemoveCustomLink,
  });

  @override
  State<EditSocialLinksSection> createState() => _EditSocialLinksSectionState();
}

class _EditSocialLinksSectionState extends State<EditSocialLinksSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final standardList = SocialPlatformRegistry.all;
    final visibleCount = _isExpanded ? standardList.length : 4;
    final displayedPlatforms = standardList.take(visibleCount).toList();

    final linkActionColor = AppColors.isDark
        ? AppColors.primary
        : const Color(0xFFA67C52);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Links',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.isDark ? AppColors.textSecondary : const Color(0xFF6B5842),
                letterSpacing: -0.1,
              ),
            ),
            if (standardList.length > 4)
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  child: Text(
                    _isExpanded ? 'Show Less' : 'Show All (${standardList.length})',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: linkActionColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Standard Platform Rows ──────────────────────────────────
        ...displayedPlatforms.map((meta) {
          final controller = widget.controllers[meta.key]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: SocialInputTile(
              meta: meta,
              controller: controller,
            ),
          );
        }),

        // ── Custom Links ────────────────────────────────────────────
        if (widget.customLinkControllers.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'Custom Links',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ...widget.customLinkControllers.asMap().entries.map((entry) {
            final index = entry.key;
            final pair = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CustomLinkTile(
                titleController: pair.key,
                urlController: pair.value,
                onRemove: () => widget.onRemoveCustomLink(index),
              ),
            );
          }),
        ],

        // ── Add Custom Link Button ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: widget.onAddCustomLink,
              icon: Icon(
                Icons.add_rounded,
                size: 18,
                color: linkActionColor,
              ),
              label: Text(
                'Add Custom Link',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: linkActionColor,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
