import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_editor_cubit.dart';

class SkillsEditorSheet extends StatefulWidget {
  final String uid;
  final List<String> initialSkills;

  const SkillsEditorSheet({
    super.key,
    required this.uid,
    required this.initialSkills,
  });

  static Future<void> show(
    BuildContext context, {
    required String uid,
    required List<String> initialSkills,
  }) {
    final cubit = context.read<PortfolioEditorCubit>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: SkillsEditorSheet(uid: uid, initialSkills: initialSkills),
      ),
    );
  }

  @override
  State<SkillsEditorSheet> createState() => _SkillsEditorSheetState();
}

class _SkillsEditorSheetState extends State<SkillsEditorSheet> {
  late List<String> _skills;
  final _addCtrl = TextEditingController();

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

  void _addSkill() {
    final text = _addCtrl.text.trim();
    if (text.isEmpty) return;
    // Allow comma separated additions
    final newItems = text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && !_skills.contains(s));
    setState(() {
      _skills.addAll(newItems);
      _addCtrl.clear();
    });
  }

  void _removeSkill(int index) {
    setState(() => _skills.removeAt(index));
  }

  Future<void> _submit() async {
    final cubit = context.read<PortfolioEditorCubit>();
    await cubit.updateSkills(uid: widget.uid, skills: _skills);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (_, scrollCtrl) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: ListView(
          controller: scrollCtrl,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF475569),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Edit Skills',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add technical skills, languages, tools, or frameworks.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    onSubmitted: (_) => _addSkill(),
                    decoration: InputDecoration(
                      hintText: 'e.g. Flutter, Dart, Python',
                      hintStyle: const TextStyle(color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF334155)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  onPressed: _addSkill,
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_skills.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No skills added yet.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_skills.length, (index) {
                  return Chip(
                    label: Text(
                      _skills[index],
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    onDeleted: () => _removeSkill(index),
                    backgroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFF334155)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                      side: const BorderSide(color: Color(0xFF334155)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _submit,
                    child: const Text(
                      'Save Skills',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
