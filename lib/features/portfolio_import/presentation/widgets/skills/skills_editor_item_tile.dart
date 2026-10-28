import 'package:flutter/material.dart';

class SkillsEditorItemTile extends StatelessWidget {
  final int index;
  final String skill;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SkillsEditorItemTile({
    super.key,
    required this.index,
    required this.skill,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1A18) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFDCD5CA),
        ),
      ),
      child: Row(
        children: [
          // Drag handle
          ReorderableDragStartListener(
            index: index,
            child: Icon(
              Icons.drag_indicator_rounded,
              color: isDark ? const Color(0xFF888076) : const Color(0xFF6B645C),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          // Skill title
          Expanded(
            child: Text(
              skill,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Edit button
          GestureDetector(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                Icons.edit_outlined,
                color: isDark ? const Color(0xFFC7BFB5) : const Color(0xFF4B453F),
                size: 18,
              ),
            ),
          ),
          // Delete button
          GestureDetector(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFEF4444),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
