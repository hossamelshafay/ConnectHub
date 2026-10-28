import 'package:flutter/material.dart';
import '../theme/web_colors.dart';

class WebHireMePill extends StatefulWidget {
  final VoidCallback onTap;

  const WebHireMePill({super.key, required this.onTap});

  @override
  State<WebHireMePill> createState() => _WebHireMePillState();
}

class _WebHireMePillState extends State<WebHireMePill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            gradient: _hovered ? WebColors.primaryGradient : null,
            color: _hovered ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            border: const Border.fromBorderSide(
              BorderSide(color: WebColors.border, width: 1),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: WebColors.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            'Hire Me',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ).copyWith(
              color: _hovered ? WebColors.textDark : WebColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
