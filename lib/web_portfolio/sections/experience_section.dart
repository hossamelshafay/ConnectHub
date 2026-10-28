import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/web_colors.dart';
import '../models/portfolio_view_data.dart';
import '../widgets/section_empty_state.dart';

/// Experience Section card matching the Titanium/Beige mockup design.
class ExperienceSection extends StatelessWidget {
  final PortfolioViewData data;
  final bool isDark;

  const ExperienceSection({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (data.experiences.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? WebColors.darkSurfaceCard : WebColors.lightSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? WebColors.darkBorder : WebColors.lightBorder,
          ),
        ),
        child: SectionEmptyState(
          icon: Icons.business_center_outlined,
          message: 'No experience added yet.',
          isDark: isDark,
        ),
      );
    }

    final dateFormat = DateFormat('MMM yyyy');

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                      Icons.business_center_outlined,
                      size: 20,
                      color: isDark ? WebColors.darkPrimaryLight : WebColors.lightPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Experience',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? WebColors.darkTextPrimary : const Color(0xFF1B1917),
                    ),
                  ),
                ],
              ),
              // View all Pill Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? WebColors.darkSurface.withValues(alpha: 0.8)
                      : const Color(0xFFF7F3EC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? WebColors.darkBorder : const Color(0xFFE2DCD1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? WebColors.darkTextSecondary : const Color(0xFF4A433D),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: isDark ? WebColors.darkTextSecondary : const Color(0xFF4A433D),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Experience Timeline List
          Column(
            children: data.experiences.asMap().entries.map((entry) {
              final index = entry.key;
              final exp = entry.value;
              final isLast = index == data.experiences.length - 1;

              final startDateStr = exp.startDate != null ? dateFormat.format(exp.startDate!) : '';
              final endDateStr = exp.isCurrent
                  ? 'Present'
                  : (exp.endDate != null ? dateFormat.format(exp.endDate!) : '');
              final dateStr = '$startDateStr – $endDateStr';

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline vertical line + dot
                    Column(
                      children: [
                        Container(
                          width: 8.5,
                          height: 8.5,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF88735C) : const Color(0xFF88735C),
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 1.5,
                              color: isDark
                                  ? WebColors.darkBorder
                                  : const Color(0xFFE2DCD1),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Content
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  exp.role,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? WebColors.darkTextPrimary : const Color(0xFF1C1917),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? WebColors.darkSurface
                                        : const Color(0xFFF7F4EE),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark ? WebColors.darkBorder : const Color(0xFFEAE3D6),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    dateStr,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? WebColors.darkTextMuted : const Color(0xFF6B6258),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              exp.company + (exp.location != null ? ' • ${exp.location}' : ''),
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12.5,
                                fontWeight: FontWeight.w500,
                                color: isDark ? WebColors.darkPrimaryLight : const Color(0xFF6B6258),
                              ),
                            ),
                            if (exp.description.trim().isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                exp.description,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.45,
                                  color: isDark ? WebColors.darkTextSecondary : const Color(0xFF5A524A),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
