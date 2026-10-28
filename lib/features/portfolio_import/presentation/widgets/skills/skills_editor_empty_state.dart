import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

class SkillsEditorEmptyState extends StatelessWidget {
  const SkillsEditorEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Icon(
              Icons.layers_outlined,
              color: AppColors.textMuted,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No skills added yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Type above or tap a suggestion to add custom skills.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
