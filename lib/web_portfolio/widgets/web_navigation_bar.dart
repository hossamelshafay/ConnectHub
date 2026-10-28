import 'package:flutter/material.dart';
import '../theme/web_colors.dart';

class NavItemDef {
  final String title;
  final IconData icon;

  const NavItemDef({required this.title, required this.icon});
}

class WebNavigationBar extends StatelessWidget {
  final int activeIndex;
  final Function(int index) onSectionSelected;
  final VoidCallback onToggleTheme;
  final bool isDark;
  final VoidCallback onOpenMobileMenu;
  final List<String>? visibleNavItems;
  final Function(String title)? onNavItemClick;

  const WebNavigationBar({
    super.key,
    required this.activeIndex,
    required this.onSectionSelected,
    required this.onToggleTheme,
    required this.isDark,
    required this.onOpenMobileMenu,
    this.visibleNavItems,
    this.onNavItemClick,
  });

  static const List<NavItemDef> defaultNavItems = [
    NavItemDef(title: 'Home', icon: Icons.home_outlined),
    NavItemDef(title: 'Projects', icon: Icons.folder_outlined),
    NavItemDef(title: 'Experience', icon: Icons.business_center_outlined),
    NavItemDef(title: 'Certificates', icon: Icons.verified_outlined),
    NavItemDef(title: 'About', icon: Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isDesktop = width >= 1050;

        return Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(
            horizontal: width < 400 ? 16.0 : (width < 800 ? 28.0 : 48.0),
            vertical: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ── Brand Logo: Circular App Logo Only (Fills full circle, no padding/border/frame) ──
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    if (onNavItemClick != null) {
                      onNavItemClick!('Home');
                    } else {
                      onSectionSelected(0);
                    }
                  },
                  child: ClipOval(
                    child: Image.asset(
                      'assets/img/logo.png',
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.hub_rounded,
                        size: 32,
                        color: isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Center Navigation Buttons (Desktop) ───────────────────
              if (isDesktop)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: defaultNavItems.map((item) {
                    final isActive = activeIndex == defaultNavItems.indexOf(item);
                    return _PillNavItem(
                      item: item,
                      isActive: isActive,
                      isDark: isDark,
                      onTap: () {
                        if (onNavItemClick != null) {
                          onNavItemClick!(item.title);
                        } else {
                          onSectionSelected(defaultNavItems.indexOf(item));
                        }
                      },
                    );
                  }).toList(),
                ),

              // ── Right Actions: Theme Toggle & Get in touch CTA ───────────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sun / Moon toggle pill
                  _ThemeToggleSwitch(
                    isDark: isDark,
                    onToggle: onToggleTheme,
                  ),
                  const SizedBox(width: 14),

                  // "Get in touch" pill button
                  if (width >= 480)
                    _GetInTouchButton(
                      isDark: isDark,
                      onTap: () {
                        if (onNavItemClick != null) {
                          onNavItemClick!('Contact');
                        } else {
                          onSectionSelected(defaultNavItems.length);
                        }
                      },
                    ),

                  // Mobile / Tablet Drawer toggle button
                  if (!isDesktop) ...[
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: (isDark ? WebColors.darkSurface : WebColors.lightSurface)
                            .withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? WebColors.darkBorder : WebColors.lightBorder,
                        ),
                      ),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.menu_rounded,
                          color: isDark ? WebColors.darkTextPrimary : WebColors.lightTextPrimary,
                          size: 22,
                        ),
                        onPressed: onOpenMobileMenu,
                        tooltip: 'Open Menu',
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PillNavItem extends StatefulWidget {
  final NavItemDef item;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _PillNavItem({
    required this.item,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_PillNavItem> createState() => _PillNavItemState();
}

class _PillNavItemState extends State<_PillNavItem> {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? (widget.isDark
                    ? WebColors.darkPrimary.withValues(alpha: 0.28)
                    : const Color(0xFFE5DDD0))
                : (_hovered
                    ? (widget.isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04))
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.item.icon,
                size: 15,
                color: widget.isActive
                    ? (widget.isDark ? WebColors.darkPrimaryLight : const Color(0xFF231F1C))
                    : (widget.isDark ? WebColors.darkTextSecondary : const Color(0xFF5A524A)),
              ),
              const SizedBox(width: 7),
              Text(
                widget.item.title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isActive
                      ? (widget.isDark ? WebColors.darkTextPrimary : const Color(0xFF231F1C))
                      : (widget.isDark ? WebColors.darkTextSecondary : const Color(0xFF5A524A)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeToggleSwitch extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const _ThemeToggleSwitch({
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          decoration: BoxDecoration(
            color: (isDark ? WebColors.darkSurfaceCard : WebColors.lightSurfaceElevated),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? WebColors.darkBorder : WebColors.lightBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: !isDark ? WebColors.lightSurface : Colors.transparent,
                  boxShadow: !isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.wb_sunny_rounded,
                  size: 14,
                  color: !isDark ? const Color(0xFFD97706) : WebColors.darkTextMuted,
                ),
              ),
              const SizedBox(width: 2),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? WebColors.darkSurface : Colors.transparent,
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  Icons.nightlight_round_rounded,
                  size: 14,
                  color: isDark ? WebColors.darkPrimaryLight : WebColors.lightTextMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GetInTouchButton extends StatefulWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _GetInTouchButton({
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_GetInTouchButton> createState() => _GetInTouchButtonState();
}

class _GetInTouchButtonState extends State<_GetInTouchButton> {
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: widget.isDark
                ? (_hovered ? WebColors.darkPrimaryLight : WebColors.darkPrimary)
                : (_hovered ? WebColors.lightPrimaryDark : WebColors.lightPrimary),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (widget.isDark ? WebColors.darkPrimary : WebColors.lightPrimary)
                    .withValues(alpha: _hovered ? 0.4 : 0.22),
                blurRadius: _hovered ? 14 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.near_me_rounded,
                size: 15,
                color: widget.isDark ? const Color(0xFF141210) : Colors.white,
              ),
              const SizedBox(width: 7),
              Text(
                'Get in touch',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? const Color(0xFF141210) : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
