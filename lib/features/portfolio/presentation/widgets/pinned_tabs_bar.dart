import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pinned Glass Navigation Tabs Bar
// ─────────────────────────────────────────────────────────────────────────────
class PinnedTabsBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const PinnedTabsBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  static IconData iconForTab(String tab) {
    switch (tab) {
      case 'Overview':
        return Icons.dashboard_outlined;
      case 'Projects':
        return Icons.folder_outlined;
      case 'Experience':
        return Icons.business_center_outlined;
      case 'Skills':
        return Icons.code_rounded;
      case 'Certificates':
        return Icons.verified_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onTabSelected(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
                  decoration: BoxDecoration(
                    color: isSelected ? kPortfolioAccent.withValues(alpha: 0.16) : kPortfolioChipBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? kPortfolioAccent.withValues(alpha: 0.45) : kPortfolioChipBorder,
                      width: 0.8,
                    ),
                    boxShadow: kPortfolioSoftShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        iconForTab(title),
                        size: 13.5,
                        color: isSelected ? kPortfolioAccent : kPortfolioTextSecondary,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? kPortfolioAccent : kPortfolioTextSecondary,
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
