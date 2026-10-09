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
    if (widget.url == null || widget.url!.isEmpty) return;
    final uri = Uri.tryParse(widget.url!);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
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
                  ? WebColors.primary.withValues(alpha: 0.18)
                  : (widget.isDark ? WebColors.surfaceElevated : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isHovered
                    ? WebColors.primaryLight
                    : (widget.isDark ? WebColors.border : const Color(0xFFE2E8F0)),
                width: 1.2,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: WebColors.primary.withValues(alpha: 0.3),
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
                  ? WebColors.primaryLight
                  : (widget.isDark ? WebColors.textSecondary : WebColors.lightTextSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
