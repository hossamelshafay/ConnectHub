import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppIconButton — Unified icon button with press state
// ─────────────────────────────────────────────────────────────────────────────
class AppIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final double size;
  final Widget? badge;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.onPressed,
    this.tooltip,
    this.color,
    this.size = 19,
    this.badge,
  });

  VoidCallback? get effectiveOnTap => onTap ?? onPressed;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.90,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final callback = widget.effectiveOnTap;
    Widget btn = GestureDetector(
      onTapDown: callback != null ? (_) => _ctrl.reverse() : null,
      onTapUp: callback != null ? (_) => _ctrl.forward() : null,
      onTapCancel: callback != null ? () => _ctrl.forward() : null,
      onTap: callback,
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                widget.icon,
                size: widget.size,
                color: widget.color ?? AppColors.textSecondary,
              ),
              if (widget.badge != null)
                Positioned(
                  top: 2,
                  right: 2,
                  child: widget.badge!,
                ),
            ],
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(message: widget.tooltip!, child: btn);
    }
    return btn;
  }
}
