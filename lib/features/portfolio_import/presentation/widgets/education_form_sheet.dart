import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/portfolio/data/models/education_model.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_editor_cubit.dart';

class EducationFormSheet extends StatefulWidget {
  final String uid;
  final EducationModel? education;

  const EducationFormSheet({
    super.key,
    required this.uid,
    this.education,
  });

  static Future<void> show(
    BuildContext context, {
    required String uid,
    EducationModel? education,
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
        child: EducationFormSheet(uid: uid, education: education),
      ),
    );
  }

  @override
  State<EducationFormSheet> createState() => _EducationFormSheetState();
}

class _EducationFormSheetState extends State<EducationFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _institutionCtrl;
  late final TextEditingController _degreeCtrl;
  late final TextEditingController _fieldOfStudyCtrl;
  late final TextEditingController _gradeCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    final edu = widget.education;
    _institutionCtrl = TextEditingController(text: edu?.institution ?? '');
    _degreeCtrl = TextEditingController(text: edu?.degree ?? '');
    _fieldOfStudyCtrl = TextEditingController(text: edu?.fieldOfStudy ?? '');
    _gradeCtrl = TextEditingController(text: edu?.grade ?? '');
    _descCtrl = TextEditingController(text: edu?.description ?? '');
  }

  @override
  void dispose() {
    _institutionCtrl.dispose();
    _degreeCtrl.dispose();
    _fieldOfStudyCtrl.dispose();
    _gradeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final model = EducationModel(
      id: widget.education?.id ?? '',
      institution: _institutionCtrl.text.trim(),
      degree: _degreeCtrl.text.trim(),
      fieldOfStudy: _fieldOfStudyCtrl.text.trim().isEmpty
          ? null
          : _fieldOfStudyCtrl.text.trim(),
      grade: _gradeCtrl.text.trim().isEmpty ? null : _gradeCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      isVisible: widget.education?.isVisible ?? true,
      startDate: widget.education?.startDate,
      endDate: widget.education?.endDate,
      activities: widget.education?.activities,
    );

    final cubit = context.read<PortfolioEditorCubit>();
    if (widget.education != null) {
      await cubit.updateEducation(uid: widget.uid, education: model);
    } else {
      await cubit.addEducation(uid: widget.uid, education: model);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.education != null;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
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
                isEditing ? 'Edit Education' : 'Add Education',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _buildField(
                label: 'INSTITUTION / UNIVERSITY *',
                controller: _institutionCtrl,
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Institution is required'
                    : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'DEGREE *',
                controller: _degreeCtrl,
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Degree is required'
                    : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'FIELD OF STUDY / MAJOR',
                controller: _fieldOfStudyCtrl,
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'GRADE / GPA',
                controller: _gradeCtrl,
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'DESCRIPTION / HIGHLIGHTS',
                controller: _descCtrl,
                maxLines: 3,
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
