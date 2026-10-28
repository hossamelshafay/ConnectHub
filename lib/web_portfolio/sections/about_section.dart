import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../models/portfolio_view_data.dart';

/// About Section card matching the Titanium/Beige mockup design.
class AboutSection extends StatelessWidget {
  final PortfolioViewData data;
  final bool isDark;

  const AboutSection({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final aboutText = (data.user.about != null && data.user.about!.trim().isNotEmpty)
        ? data.user.about!.trim()
        : (data.user.bio != null && data.user.bio!.trim().isNotEmpty)
            ? data.user.bio!.trim()
            : 'Passionate software engineer focused on building clean, performant applications, solving real-world problems, and crafting exceptional user experiences.';

    final locationText = (data.user.location != null && data.user.location!.trim().isNotEmpty)
        ? data.user.location!.trim()
        : 'Available remotely';

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
                  Icons.person_outline_rounded,
                  size: 20,
                  color: isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'About Me',
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

          // About Body Text
          Text(
            aboutText,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.68,
              color: isDark ? WebColors.darkTextSecondary : const Color(0xFF4A433D),
            ),
          ),
          const SizedBox(height: 22),

          // Bottom Meta Chips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              // Location Chip
              _buildMetaChip(
                icon: Icons.location_on_outlined,
                text: locationText,
              ),
              // Open to opportunities Chip
              _buildMetaChip(
                icon: Icons.calendar_today_outlined,
                text: 'Open to opportunities',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? WebColors.darkSurface.withValues(alpha: 0.7)
            : const Color(0xFFF7F4EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? WebColors.darkBorder : const Color(0xFFE5DDD0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13.5,
            color: isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? WebColors.darkTextPrimary : const Color(0xFF332D28),
            ),
          ),
        ],
      ),
    );
  }
}
