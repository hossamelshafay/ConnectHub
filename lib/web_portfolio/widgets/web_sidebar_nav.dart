import 'package:flutter/material.dart';
import '../theme/web_colors.dart';

/// Sidebar navigation card matching the mockup for desktop viewports.
/// Contains Overview, Projects, Experience, Certificates, Skills, Posts, About,
/// and the "Let's connect" bottom CTA card.
class WebSidebarNav extends StatelessWidget {
  final int activeIndex;
  final Function(String title) onNavSelected;
  final VoidCallback onGetInTouch;
  final bool isDark;

  const WebSidebarNav({
    super.key,
    required this.activeIndex,
    required this.onNavSelected,
    required this.onGetInTouch,
    required this.isDark,
  });

  static const List<SidebarItemDef> items = [
    SidebarItemDef(title: 'Overview', icon: Icons.grid_view_rounded),
    SidebarItemDef(title: 'Projects', icon: Icons.folder_outlined),
    SidebarItemDef(title: 'Experience', icon: Icons.business_center_outlined),
    SidebarItemDef(title: 'Certificates', icon: Icons.verified_outlined),
    SidebarItemDef(title: 'Skills', icon: Icons.code_rounded),
    SidebarItemDef(title: 'Posts', icon: Icons.photo_size_select_actual_outlined),
    SidebarItemDef(title: 'About', icon: Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Navigation Menu Card
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
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
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = activeIndex == index;

              return _SidebarMenuItem(
                item: item,
                isActive: isActive,
                isDark: isDark,
                onTap: () => onNavSelected(item.title),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        // "Let's connect" bottom card
        Container(
          padding: const EdgeInsets.all(20),
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
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark
                      ? WebColors.darkPrimary.withValues(alpha: 0.18)
                      : WebColors.lightPrimary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 19,
                  color: isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Let's connect",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? WebColors.darkTextPrimary : WebColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "I'm open to opportunities and interesting projects.",
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  color: isDark ? WebColors.darkTextMuted : WebColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 16),
              // CTA Button
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onGetInTouch,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: isDark ? WebColors.darkPrimary : WebColors.lightPrimary,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? WebColors.darkPrimary : WebColors.lightPrimary)
                              .withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.near_me_rounded,
                          size: 14,
                          color: isDark ? const Color(0xFF141210) : Colors.white,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          'Get in touch',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF141210) : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SidebarItemDef {
  final String title;
  final IconData icon;

  const SidebarItemDef({required this.title, required this.icon});
}

class _SidebarMenuItem extends StatefulWidget {
  final SidebarItemDef item;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _SidebarMenuItem({
    required this.item,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_SidebarMenuItem> createState() => _SidebarMenuItemState();
}

class _SidebarMenuItemState extends State<_SidebarMenuItem> {
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
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: widget.isActive
                ? (widget.isDark ? const Color(0xFF88735C) : const Color(0xFF88735C))
                : (_hovered
                    ? (widget.isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : const Color(0xFFF1EBE2))
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(14),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF88735C).withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                widget.item.icon,
                size: 18,
                color: widget.isActive
                    ? Colors.white
                    : (widget.isDark ? WebColors.darkTextSecondary : const Color(0xFF5A524A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5,
                    fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
                    color: widget.isActive
                        ? Colors.white
                        : (widget.isDark ? WebColors.darkTextPrimary : const Color(0xFF2C2621)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
