import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_editor_cubit.dart';

class ExperienceFormSheet extends StatefulWidget {
  final String uid;
  final ExperienceModel? experience;

  const ExperienceFormSheet({
    super.key,
    required this.uid,
    this.experience,
  });

  static Future<void> show(
    BuildContext context, {
    required String uid,
    ExperienceModel? experience,
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
        child: ExperienceFormSheet(uid: uid, experience: experience),
      ),
    );
  }

  @override
  State<ExperienceFormSheet> createState() => _ExperienceFormSheetState();
}

class _ExperienceFormSheetState extends State<ExperienceFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _roleCtrl;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _skillsCtrl;
  late bool _isCurrent;

  @override
  void initState() {
    super.initState();
    final exp = widget.experience;
    _roleCtrl = TextEditingController(text: exp?.role ?? '');
    _companyCtrl = TextEditingController(text: exp?.company ?? '');
    _locationCtrl = TextEditingController(text: exp?.location ?? '');
    _descriptionCtrl = TextEditingController(text: exp?.description ?? '');
    _skillsCtrl = TextEditingController(text: exp?.skills.join(', ') ?? '');
    _isCurrent = exp?.isCurrent ?? false;
  }

  @override
  void dispose() {
    _roleCtrl.dispose();
    _companyCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    _skillsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final skills = _skillsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final model = ExperienceModel(
      id: widget.experience?.id ?? '',
      role: _roleCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      isCurrent: _isCurrent,
      skills: skills,
      startDate: widget.experience?.startDate,
      endDate: _isCurrent ? null : widget.experience?.endDate,
      isVisible: widget.experience?.isVisible ?? true,
    );

    final cubit = context.read<PortfolioEditorCubit>();
    if (widget.experience != null) {
      await cubit.updateExperience(uid: widget.uid, experience: model);
    } else {
      await cubit.addExperience(uid: widget.uid, experience: model);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.experience != null;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Form(
          key: _formKey,
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
              Text(
                isEditing ? 'Edit Experience' : 'Add Experience',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _buildField(
                label: 'ROLE / TITLE *',
                controller: _roleCtrl,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Role is required' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'COMPANY *',
                controller: _companyCtrl,
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Company is required'
                    : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'LOCATION',
                controller: _locationCtrl,
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'SKILLS / TECHNOLOGIES (COMMA SEPARATED)',
                controller: _skillsCtrl,
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'DESCRIPTION / RESPONSIBILITIES',
                controller: _descriptionCtrl,
                maxLines: 4,
              ),
              const SizedBox(height: 14),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isCurrent,
                onChanged: (val) => setState(() => _isCurrent = val ?? false),
                title: const Text(
                  'I currently work here',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                activeColor: const Color(0xFF38BDF8),
                checkColor: const Color(0xFF0F172A),
              ),
              const SizedBox(height: 20),
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
                      child: Text(
                        isEditing ? 'Save' : 'Add',
                        style: const TextStyle(fontWeight: FontWeight.w700),
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

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF0F172A),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
          ),
        ),
      ],
    );
  }
}
