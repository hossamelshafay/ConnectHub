import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Pill tab bar matching the mockup ("Posts" & "Liked"):
/// - Selected tab has warm caramel background with contrasting text.
/// - Unselected tab has transparent background.
/// - Smooth animated transition on tab change.
class ProfileTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final String firstTabLabel;
  final String secondTabLabel;

  const ProfileTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    this.firstTabLabel = 'Posts',
    this.secondTabLabel = 'Liked',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.isDark
            ? const Color(0x352E2B27)
            : const Color(0xFFEDE6DC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.isDark
              ? const Color(0x28FFFFFF)
              : const Color(0xFFDFD6C8),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              title: firstTabLabel,
              isSelected: selectedIndex == 0,
              onTap: () => onTabSelected(0),
            ),
          ),
          Expanded(
            child: _TabButton(
              title: secondTabLabel,
              isSelected: selectedIndex == 1,
              onTap: () => onTabSelected(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.isDark
        ? AppColors.primary
        : const Color(0xFFA67C52);
    final activeTextColor = AppColors.isDark
        ? Colors.black
        : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? activeTextColor : AppColors.textSecondary,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }
}
