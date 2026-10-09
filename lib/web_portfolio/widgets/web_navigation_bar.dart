import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';
import '../animations/gold_shimmer.dart';
import '../responsive/responsive.dart';

/// Luxury black + gold navigation bar with blur backdrop and gold accent line.
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

  static const List<String> navItems = [
    'About',
    'Skills',
    'Experience',
    'Projects',
    'Education',
    'Certificates',
    'Contact',
  ];

  List<String> get _effectiveNavItems => visibleNavItems ?? navItems;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final showFullLogo = width >= 420;
        final canFitFullNav = width >= 1150;
        final canFitCompactNav = width >= 860 && width < 1150;
        final showHireMeButton = width >= 520;

        final double horizontalPadding = width < 360
            ? 12.0
            : width < 600
                ? 16.0
                : width < 900
                    ? 24.0
                    : width < 1200
                        ? 32.0
                        : 48.0;

        return ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: ResponsiveBreakpoints.navBarHeight,
              decoration: BoxDecoration(
                color: WebColors.background.withValues(alpha: 0.94),
                border: const Border(
                  bottom: BorderSide(
                    color: WebColors.border,
                    width: 1.0,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Brand Logo ──────────────────────────────────────────────
                    Flexible(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          if (onNavItemClick != null) {
                            onNavItemClick!('Hero');
                          } else {
                            onSectionSelected(0);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Gold monogram box
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: WebColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: const Border.fromBorderSide(
                                  BorderSide(color: WebColors.border, width: 1),
                                ),
                              ),
                              child: Center(
                                child: GoldShimmerText(
                                  duration: const Duration(milliseconds: 4000),
                                  child: const Text(
                                    'CH',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                      color: WebColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (showFullLogo) ...[
                              const SizedBox(width: 10),
                              Flexible(
                                child: GoldShimmerText(
                                  duration: const Duration(milliseconds: 4000),
                                  child: Text(
                                    'ConnectHub',
                                    style: WebTextStyles.cardTitle(isDark: isDark).copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                      color: WebColors.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Right Navigation Actions ────────────────────────────────
                  if (canFitFullNav)
                    // Full Desktop Navigation (>= 1150px)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < _effectiveNavItems.length; i++)
                          _NavLinkItem(
                            title: _effectiveNavItems[i],
                            isActive: activeIndex == i + 1,
                            onTap: () {
                              if (onNavItemClick != null) {
                                onNavItemClick!(_effectiveNavItems[i]);
                              } else {
                                onSectionSelected(i + 1);
                              }
                            },
                          ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            if (onNavItemClick != null) {
                              onNavItemClick!('Contact');
                            } else {
                              onSectionSelected(navItems.length);
                            }
                          },
                          child: _HireMePill(),
                        ),
                      ],
                    )
                  else if (canFitCompactNav)
                    // Compact Laptop / Tablet Navigation (860px - 1149px)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final item in ['About', 'Projects', 'Experience', 'Contact'].where((t) => _effectiveNavItems.contains(t)))
                          _NavLinkItem(
                            title: item,
                            isActive: false,
                            onTap: () {
                              if (onNavItemClick != null) {
                                onNavItemClick!(item);
                              }
                            },
                          ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            if (onNavItemClick != null) {
                              onNavItemClick!('Contact');
                            } else {
                              onSectionSelected(navItems.length);
                            }
                          },
                          child: _HireMePill(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          icon: const Icon(
                            Icons.menu_rounded,
                            color: WebColors.textSecondary,
                            size: 22,
                          ),
                          onPressed: onOpenMobileMenu,
                          tooltip: 'All Sections',
                        ),
                      ],
                    )
                  else
                    // Mobile & Compact Tablet Navigation (< 860px)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showHireMeButton) ...[
                          GestureDetector(
                            onTap: () {
                              if (onNavItemClick != null) {
                                onNavItemClick!('Contact');
                              } else {
                                onSectionSelected(navItems.length);
                              }
                            },
                            child: _HireMePill(),
                          ),
                          const SizedBox(width: 12),
                        ],
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                          icon: const Icon(
                            Icons.menu_rounded,
                            color: WebColors.textSecondary,
                            size: 24,
                          ),
                          onPressed: onOpenMobileMenu,
                          tooltip: 'Open Menu',
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HireMePill extends StatefulWidget {
  @override
  State<_HireMePill> createState() => _HireMePillState();
}

class _HireMePillState extends State<_HireMePill> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
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
          style: GoogleFontsInter.navLink.copyWith(
            color: _hovered ? WebColors.textDark : WebColors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class GoogleFontsInter {
  static const TextStyle navLink = TextStyle(
    fontFamily: 'Inter',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.8,
    color: WebColors.textSecondary,
  );
}

class _NavLinkItem extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _NavLinkItem({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavLinkItem> createState() => _NavLinkItemState();
}

class _NavLinkItemState extends State<_NavLinkItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.isActive || _isHovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: 0.8,
                  color: isHighlighted
                      ? WebColors.primaryLight
                      : WebColors.textSecondary,
                ),
                child: Text(widget.title),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 1.5,
                width: isHighlighted ? 18 : 0,
                decoration: BoxDecoration(
                  gradient: WebColors.primaryGradient,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
