import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/web_colors.dart';

/// Interactive social link icon button with hover animations and safe URL launching.
class SocialIconButton extends StatefulWidget {
  final IconData icon;
  final String? url;
  final String tooltip;
  final bool isDark;

  const SocialIconButton({
    super.key,
    required this.icon,
    this.url,
    required this.tooltip,
    this.isDark = true,
  });

  @override
  State<SocialIconButton> createState() => _SocialIconButtonState();
}

class _SocialIconButtonState extends State<SocialIconButton> {
  bool _isHovered = false;

  Future<void> _launch() async {
    final raw = widget.url?.trim();
    if (raw == null || raw.isEmpty) return;
    final normalized = (raw.startsWith('http://') || raw.startsWith('https://'))
        ? raw
        : 'https://$raw';
    final uri = Uri.tryParse(normalized);
    if (uri != null) {
      try {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
      } catch (e) {
        debugPrint('[SocialIconButton] Launch failed for $uri: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _launch,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isHovered
                  ? (widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary).withValues(alpha: 0.18)
                  : (widget.isDark ? WebColors.darkSurface : const Color(0xFFF7F4EE)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isHovered
                    ? (widget.isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary)
                    : (widget.isDark ? WebColors.darkBorder : const Color(0xFFEAE3D6)),
                width: 1.2,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: (widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary).withValues(alpha: 0.25),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              widget.icon,
              size: 20,
              color: _isHovered
                  ? (widget.isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary)
                  : (widget.isDark ? WebColors.darkTextSecondary : WebColors.lightTextSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
