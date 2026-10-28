import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';

class PortfolioVisibilityCard extends StatelessWidget {
  final SectionVisibilityModel visibility;
  final ValueChanged<SectionVisibilityModel> onChanged;

  const PortfolioVisibilityCard({
    super.key,
    required this.visibility,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          _buildToggle(
            'About Section',
            visibility.about,
            (v) => onChanged(visibility.copyWith(about: v)),
          ),
          Divider(color: AppColors.glassBorder, height: 1),
          _buildToggle(
            'Experience Section',
            visibility.experience,
            (v) => onChanged(visibility.copyWith(experience: v)),
          ),
          Divider(color: AppColors.glassBorder, height: 1),
          _buildToggle(
            'Projects Section',
            visibility.projects,
            (v) => onChanged(visibility.copyWith(projects: v)),
          ),
          Divider(color: AppColors.glassBorder, height: 1),
          _buildToggle(
            'Skills Section',
            visibility.skills,
            (v) => onChanged(visibility.copyWith(skills: v)),
          ),
          Divider(color: AppColors.glassBorder, height: 1),
          _buildToggle(
            'Education Section',
            visibility.education,
            (v) => onChanged(visibility.copyWith(education: v)),
          ),
          Divider(color: AppColors.glassBorder, height: 1),
          _buildToggle(
            'Certificates Section',
            visibility.certificates,
            (v) => onChanged(visibility.copyWith(certificates: v)),
          ),
          Divider(color: AppColors.glassBorder, height: 1),
          _buildToggle(
            'Contact Section',
            visibility.contact,
            (v) => onChanged(visibility.copyWith(contact: v)),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String title, bool val, ValueChanged<bool> onToggle) {
    return SwitchListTile(
      value: val,
      onChanged: onToggle,
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      activeThumbColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }
}
