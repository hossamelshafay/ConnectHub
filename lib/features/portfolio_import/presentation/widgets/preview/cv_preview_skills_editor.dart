import 'package:flutter/material.dart';

class CvPreviewSkillsEditor extends StatefulWidget {
  final List<String> skills;
  final ValueChanged<List<String>> onChanged;

  const CvPreviewSkillsEditor({
    super.key,
    required this.skills,
    required this.onChanged,
  });

  @override
  State<CvPreviewSkillsEditor> createState() => _CvPreviewSkillsEditorState();
}

class _CvPreviewSkillsEditorState extends State<CvPreviewSkillsEditor> {
  late List<String> _skills;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _skills = List.from(widget.skills);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _add() {
    final v = _ctrl.text.trim();
    if (v.isEmpty || _skills.contains(v)) return;
    setState(() => _skills.add(v));
    _ctrl.clear();
    widget.onChanged(_skills);
  }

  void _remove(int i) {
    setState(() => _skills.removeAt(i));
    widget.onChanged(_skills);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skills.asMap().entries.map((e) {
            return Chip(
              label: Text(
                e.value,
                style: TextStyle(
                  color: isDark ? const Color(0xFFFAF7F2) : const Color(0xFF1B1917),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: isDark
                  ? primary.withValues(alpha: 0.18)
                  : primary.withValues(alpha: 0.10),
              side: BorderSide(
                color: isDark
                    ? primary.withValues(alpha: 0.5)
                    : primary.withValues(alpha: 0.35),
                width: 1,
              ),
              deleteIcon: Icon(
                Icons.close,
                size: 14,
                color: isDark ? const Color(0xFFC7BFB5) : const Color(0xFF5C554E),
              ),
              onDeleted: () => _remove(e.key),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _ctrl,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Add skill…',
                  hintStyle: TextStyle(
                    color: isDark ? const Color(0xFF888076) : const Color(0xFF787268),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF141210) : Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFDCD5CA),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFDCD5CA),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primary, width: 1.5),
                  ),
                ),
                onFieldSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _add,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.add,
                  color: isDark ? const Color(0xFF141210) : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
