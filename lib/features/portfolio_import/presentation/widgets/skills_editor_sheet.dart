import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_editor_cubit.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/skills/skills_editor_suggestions_bar.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/skills/skills_editor_item_tile.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/skills/skills_editor_empty_state.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/skills/skills_editor_edit_dialog.dart';

class SkillsEditorSheet extends StatefulWidget {
  final String uid;
  final List<String> initialSkills;
  final ValueChanged<List<String>>? onSaved;

  const SkillsEditorSheet({
    super.key,
    required this.uid,
    required this.initialSkills,
    this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required String uid,
    required List<String> initialSkills,
    ValueChanged<List<String>>? onSaved,
  }) {
    final cubit = context.read<PortfolioEditorCubit>();
    PortfolioCubit? portfolioCubit;
    try {
      portfolioCubit = context.read<PortfolioCubit>();
    } catch (_) {}

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        Widget content = SkillsEditorSheet(
          uid: uid,
          initialSkills: initialSkills,
          onSaved: onSaved,
        );
        if (portfolioCubit != null) {
          content = BlocProvider.value(value: portfolioCubit, child: content);
        }
        return BlocProvider.value(value: cubit, child: content);
      },
    );
  }

  @override
  State<SkillsEditorSheet> createState() => _SkillsEditorSheetState();
}

class _SkillsEditorSheetState extends State<SkillsEditorSheet> {
  late List<String> _skills;
  final _addCtrl = TextEditingController();
  bool _isSaving = false;

  static const List<String> _suggestions = [
    'Flutter',
    'Dart',
    'Python',
    'Firebase',
    'Machine Learning',
    'Generative AI',
    'TensorFlow',
    'React',
    'TypeScript',
    'Node.js',
    'PostgreSQL',
    'Docker',
    'Git',
    'UI/UX Design',
    'REST APIs',
    'Swift',
    'Kotlin',
  ];

  @override
  void initState() {
    super.initState();
    _skills = List<String>.from(widget.initialSkills);
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  void _addSkill([String? customText]) {
    final raw = customText ?? _addCtrl.text;
    final text = raw.trim();
    if (text.isEmpty) return;

    final newItems = text
        .split(',')
        .map((s) => s.trim())
        .where((s) =>
            s.isNotEmpty &&
            !_skills.any((existing) => existing.toLowerCase() == s.toLowerCase()))
        .toList();

    if (newItems.isNotEmpty) {
      setState(() {
        _skills.addAll(newItems);
        if (customText == null) {
          _addCtrl.clear();
        }
      });
    }
  }

  void _removeSkill(int index) {
    setState(() => _skills.removeAt(index));
  }

  void _editSkillDialog(int index) {
    SkillsEditorEditDialog.show(
      context,
      initialSkill: _skills[index],
      onUpdated: (newText) {
        setState(() {
          _skills[index] = newText;
        });
      },
    );
  }

  Future<void> _submit() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final cubit = context.read<PortfolioEditorCubit>();
      PortfolioCubit? portCubit;
      try {
        portCubit = context.read<PortfolioCubit>();
      } catch (_) {}
      await cubit.updateSkills(uid: widget.uid, skills: _skills);
      widget.onSaved?.call(_skills);
      portCubit?.loadPortfolio(widget.uid);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableSuggestions = _suggestions
        .where((s) =>
            !_skills.any((existing) => existing.toLowerCase() == s.toLowerCase()))
        .take(8)
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag bar
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.glassBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title and count badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Skills & Tech Stack',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${_skills.length} skills',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Add, edit, delete, or drag to reorder your skills.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),

              // Add Skill Input Field
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addCtrl,
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addSkill(),
                      decoration: InputDecoration(
                        hintText: 'Type a skill (e.g. Flutter, PyTorch)',
                        hintStyle: TextStyle(
                            color: AppColors.textHint, fontSize: 13.5),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.glassBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.glassBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _addSkill(),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 46,
                      width: 46,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: AppColors.isDark
                            ? const Color(0xFF141210)
                            : Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),

              // Suggestions Row (Quick Add)
              SkillsEditorSuggestionsBar(
                suggestions: availableSuggestions,
                onSelected: _addSkill,
              ),
              const SizedBox(height: 14),

              // Skills List (Reorderable)
              Expanded(
                child: _skills.isEmpty
                    ? const SkillsEditorEmptyState()
                    : Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: ReorderableListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _skills.length,
                          // ignore: deprecated_member_use
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) newIndex -= 1;
                              final item = _skills.removeAt(oldIndex);
                              _skills.insert(newIndex, item);
                            });
                          },
                          itemBuilder: (context, index) {
                            final skill = _skills[index];
                            return SkillsEditorItemTile(
                              key: ValueKey('$skill-$index'),
                              index: index,
                              skill: skill,
                              onEdit: () => _editSkillDialog(index),
                              onDelete: () => _removeSkill(index),
                            );
                          },
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              // Bottom Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
                        side: BorderSide(color: AppColors.glassBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.isDark
                            ? const Color(0xFF141210)
                            : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isSaving ? null : _submit,
                      child: _isSaving
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.surface,
                              ),
                            )
                          : const Text(
                              'Save Skills',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
