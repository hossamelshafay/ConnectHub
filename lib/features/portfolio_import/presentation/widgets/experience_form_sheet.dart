import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/portfolio/data/models/experience_model.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_editor_cubit.dart';

import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/portfolio_form_field.dart';

class ExperienceFormSheet extends StatefulWidget {
  final String uid;
  final ExperienceModel? experience;
  final PortfolioCubit? portfolioCubit;

  const ExperienceFormSheet({
    super.key,
    required this.uid,
    this.experience,
    this.portfolioCubit,
  });

  static Future<void> show(
    BuildContext context, {
    required String uid,
    ExperienceModel? experience,
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
        Widget content = ExperienceFormSheet(
          uid: uid,
          experience: experience,
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
    PortfolioCubit? portCubit = widget.portfolioCubit;
    if (portCubit == null) {
      try {
        portCubit = context.read<PortfolioCubit>();
      } catch (_) {}
    }

    if (widget.experience != null) {
      await cubit.updateExperience(uid: widget.uid, experience: model);
    } else {
      await cubit.addExperience(uid: widget.uid, experience: model);
    }

    portCubit?.loadPortfolio(widget.uid);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                    color: isDark ? const Color(0xFF55504A) : const Color(0xFFD4CDC5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEditing ? 'Edit Experience' : 'Add Experience',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              PortfolioFormField(
                label: 'ROLE / TITLE *',
                controller: _roleCtrl,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Role is required' : null,
              ),
              const SizedBox(height: 14),
              PortfolioFormField(
                label: 'COMPANY *',
                controller: _companyCtrl,
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Company is required'
                    : null,
              ),
              const SizedBox(height: 14),
              PortfolioFormField(
                label: 'LOCATION',
                controller: _locationCtrl,
              ),
              const SizedBox(height: 14),
              PortfolioFormField(
                label: 'SKILLS / TECHNOLOGIES (COMMA SEPARATED)',
                controller: _skillsCtrl,
              ),
              const SizedBox(height: 14),
              PortfolioFormField(
                label: 'DESCRIPTION / RESPONSIBILITIES',
                controller: _descriptionCtrl,
                maxLines: 4,
              ),
              const SizedBox(height: 14),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isCurrent,
                onChanged: (val) => setState(() => _isCurrent = val ?? false),
                title: Text(
                  'I currently work here',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                ),
                activeColor: AppColors.primary,
                checkColor: AppColors.isDark ? const Color(0xFF141210) : Colors.white,
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
