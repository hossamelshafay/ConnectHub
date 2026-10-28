import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/portfolio/data/models/education_model.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_editor_cubit.dart';

import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/portfolio_form_field.dart';

class EducationFormSheet extends StatefulWidget {
  final String uid;
  final EducationModel? education;
  final PortfolioCubit? portfolioCubit;

  const EducationFormSheet({
    super.key,
    required this.uid,
    this.education,
    this.portfolioCubit,
  });

  static Future<void> show(
    BuildContext context, {
    required String uid,
    EducationModel? education,
    PortfolioCubit? portfolioCubit,
  }) {
    final cubit = context.read<PortfolioEditorCubit>();
    PortfolioCubit? effectivePortfolioCubit = portfolioCubit;
    if (effectivePortfolioCubit == null) {
      try {
        effectivePortfolioCubit = context.read<PortfolioCubit>();
      } catch (_) {}
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1C1A18) : const Color(0xFFFAF8F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        Widget content = EducationFormSheet(
          uid: uid,
          education: education,
          portfolioCubit: effectivePortfolioCubit,
        );
        if (effectivePortfolioCubit != null) {
          content = BlocProvider.value(
            value: effectivePortfolioCubit,
            child: content,
          );
        }
        return BlocProvider.value(
          value: cubit,
          child: content,
        );
      },
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
    PortfolioCubit? portCubit = widget.portfolioCubit;
    if (portCubit == null) {
      try {
        portCubit = context.read<PortfolioCubit>();
      } catch (_) {}
    }

    if (widget.education != null) {
      await cubit.updateEducation(uid: widget.uid, education: model);
    } else {
      await cubit.addEducation(uid: widget.uid, education: model);
    }

    portCubit?.loadPortfolio(widget.uid);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                    color: isDark ? const Color(0xFF55504A) : const Color(0xFFD4CDC5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEditing ? 'Edit Education' : 'Add Education',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              PortfolioFormField(
                label: 'INSTITUTION / UNIVERSITY *',
                controller: _institutionCtrl,
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Institution is required'
                    : null,
              ),
              const SizedBox(height: 14),
              PortfolioFormField(
                label: 'DEGREE *',
                controller: _degreeCtrl,
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Degree is required'
                    : null,
              ),
              const SizedBox(height: 14),
              PortfolioFormField(
                label: 'FIELD OF STUDY / MAJOR',
                controller: _fieldOfStudyCtrl,
              ),
              const SizedBox(height: 14),
              PortfolioFormField(
                label: 'GRADE / GPA',
                controller: _gradeCtrl,
              ),
              const SizedBox(height: 14),
              PortfolioFormField(
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
                        foregroundColor: AppColors.textMuted,
                        side: BorderSide(color: AppColors.glassBorder),
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
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.isDark ? const Color(0xFF141210) : Colors.white,
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
}
