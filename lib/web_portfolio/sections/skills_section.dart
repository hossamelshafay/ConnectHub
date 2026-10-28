import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../models/portfolio_view_data.dart';

/// Skills Section card matching the Titanium/Beige mockup design.
class SkillsSection extends StatelessWidget {
  final PortfolioViewData data;
  final bool isDark;

  const SkillsSection({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamically gather skills from Firestore data
    final Set<String> gatheredSkills = {};
    for (final s in data.skills) {
      gatheredSkills.add(s.name);
    }
    for (final s in data.user.skills) {
      gatheredSkills.add(s);
    }
    for (final p in data.projects) {
      gatheredSkills.addAll(p.technologies);
    }
    for (final e in data.experiences) {
      gatheredSkills.addAll(e.skills);
    }

    final skillsList = gatheredSkills.isNotEmpty
        ? gatheredSkills.toList()
        : ['Flutter', 'Dart', 'Firebase', 'REST APIs', 'Git', 'Clean Architecture', 'UI/UX', 'State Management'];

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? WebColors.darkSurfaceCard : WebColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? WebColors.darkBorder : WebColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? WebColors.darkPrimary.withValues(alpha: 0.18)
                      : const Color(0xFFF0EAE1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.code_rounded,
                  size: 20,
                  color: isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Skills',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? WebColors.darkTextPrimary : const Color(0xFF1B1917),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Skill Chips Wrap
          Wrap(
            spacing: 8,
            runSpacing: 9,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ...skillsList.take(13).map((skill) {
                return _SkillPill(
                  label: skill,
                  isDark: isDark,
                );
              }),
              if (skillsList.length > 13)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0x332B2520)
                        : const Color(0xFFEDE7DD),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? WebColors.darkBorder : const Color(0xFFDCD4C6),
                    ),
                  ),
                  child: Text(
                    '+ More',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? WebColors.darkTextSecondary : const Color(0xFF5A524A),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillPill extends StatefulWidget {
  final String label;
  final bool isDark;

  const _SkillPill({
    required this.label,
    required this.isDark,
  });

  @override
  State<_SkillPill> createState() => _SkillPillState();
}

class _SkillPillState extends State<_SkillPill> {
  bool _hovered = false;

  IconData _getSkillIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('flutter')) return Icons.flutter_dash;
    if (lower.contains('dart')) return Icons.arrow_outward_rounded;
    if (lower.contains('firebase')) return Icons.local_fire_department_rounded;
    if (lower.contains('api') || lower.contains('rest')) return Icons.sync_alt_rounded;
    if (lower.contains('git')) return Icons.commit_rounded;
    if (lower.contains('clean') || lower.contains('arch')) return Icons.verified_user_outlined;
    if (lower.contains('ui') || lower.contains('ux') || lower.contains('design')) return Icons.brush_rounded;
    if (lower.contains('state') || lower.contains('bloc') || lower.contains('provider')) return Icons.account_tree_outlined;
    if (lower.contains('python')) return Icons.terminal_rounded;
    if (lower.contains('docker')) return Icons.inventory_2_outlined;
    if (lower.contains('postgres') || lower.contains('database') || lower.contains('sql')) return Icons.storage_rounded;
    if (lower.contains('ai') || lower.contains('machine')) return Icons.psychology_outlined;
    return Icons.code_rounded;
  }

  Color _getSkillColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('flutter')) return const Color(0xFF02569B);
    if (lower.contains('dart')) return const Color(0xFF0175C2);
    if (lower.contains('firebase')) return const Color(0xFFFFA000);
    if (lower.contains('api') || lower.contains('rest')) return const Color(0xFF009688);
    if (lower.contains('git')) return const Color(0xFFF05032);
    if (lower.contains('clean') || lower.contains('arch')) return const Color(0xFF2563EB);
    if (lower.contains('ui') || lower.contains('ux')) return const Color(0xFF8B5CF6);
    if (lower.contains('state') || lower.contains('bloc')) return const Color(0xFF0284C7);
    if (lower.contains('python')) return const Color(0xFF3776AB);
    if (lower.contains('docker')) return const Color(0xFF2496ED);
    if (lower.contains('postgres') || lower.contains('sql')) return const Color(0xFF336791);
    if (lower.contains('ai') || lower.contains('machine')) return const Color(0xFF7C3AED);
    return widget.isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getSkillColor(widget.label);
    final icon = _getSkillIcon(widget.label);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
        decoration: BoxDecoration(
          color: widget.isDark
              ? (_hovered ? WebColors.darkSurfaceElevated : WebColors.darkSurface)
              : (_hovered ? const Color(0xFFEFE9DF) : const Color(0xFFF6F2EB)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovered
                ? (widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary)
                : (widget.isDark ? WebColors.darkBorder : const Color(0xFFE8E2D7)),
            width: 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: widget.isDark ? 0.2 : 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 13.5,
              color: iconColor,
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: widget.isDark ? WebColors.darkTextPrimary : const Color(0xFF2C2723),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
