import 'package:flutter/material.dart';

class SkillsEditorSuggestionsBar extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  const SkillsEditorSuggestionsBar({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final sug = suggestions[i];
              return GestureDetector(
                onTap: () => onSelected(sug),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF262320) : const Color(0xFFEAE5DC),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFDCD5CA),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 12, color: primary),
                      const SizedBox(width: 4),
                      Text(
                        sug,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFFAF7F2) : const Color(0xFF1B1917),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
