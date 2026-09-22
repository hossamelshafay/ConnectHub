import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// A reusable settings list tile with optional subtitle, trailing widget,
/// and a destructive styling mode (red text/icon for dangerous actions).
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    final iconBg = isDestructive
        ? AppColors.error.withValues(alpha: 0.08)
        : AppColors.surfaceVariant;
    final iconColor =
        isDestructive ? AppColors.error : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Leading icon container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),

              // Title + optional subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body1.copyWith(
                        color: color,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing: custom widget OR default arrow
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: isDestructive
                      ? AppColors.error.withValues(alpha: 0.5)
                      : AppColors.textHint,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A section card containing a group of [SettingsTile]s with a header label.
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> tiles;

  const SettingsSection({
    super.key,
    required this.title,
    required this.tiles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              fontSize: 11,
            ),
          ),
        ),

        // Section card
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              children: _withDividers(tiles),
            ),
          ),
        ),
      ],
    );
  }

  /// Inserts a thin divider between tiles (but not at the start/end).
  List<Widget> _withDividers(List<Widget> items) {
    final result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(
          const Divider(
            height: 1,
            thickness: 1,
            indent: 70,
            color: AppColors.divider,
          ),
        );
      }
    }
    return result;
  }
}
