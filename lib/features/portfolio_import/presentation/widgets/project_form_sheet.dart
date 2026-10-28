import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/portfolio/data/models/project_model.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_editor_cubit.dart';

import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/portfolio_form_field.dart';

class ProjectFormSheet extends StatefulWidget {
  final String uid;
  final ProjectModel? project;
  final PortfolioCubit? portfolioCubit;

  const ProjectFormSheet({
    super.key,
    required this.uid,
    this.project,
    this.portfolioCubit,
  });

  static Future<void> show(
    BuildContext context, {
    required String uid,
    ProjectModel? project,
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
        Widget content = ProjectFormSheet(
          uid: uid,
          project: project,
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
  State<ProjectFormSheet> createState() => _ProjectFormSheetState();
}

class _ProjectFormSheetState extends State<ProjectFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _techCtrl;
  late final TextEditingController _projectUrlCtrl;
  late final TextEditingController _githubUrlCtrl;
  late bool _isFeatured;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _titleCtrl = TextEditingController(text: p?.title ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _techCtrl = TextEditingController(text: p?.technologies.join(', ') ?? '');
    _projectUrlCtrl = TextEditingController(text: p?.projectUrl ?? '');
    _githubUrlCtrl = TextEditingController(text: p?.githubUrl ?? '');
    _isFeatured = p?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _techCtrl.dispose();
    _projectUrlCtrl.dispose();
    _githubUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final technologies = _techCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final model = ProjectModel(
      id: widget.project?.id ?? '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      technologies: technologies,
      projectUrl: _projectUrlCtrl.text.trim().isEmpty ? null : _projectUrlCtrl.text.trim(),
      githubUrl: _githubUrlCtrl.text.trim().isEmpty ? null : _githubUrlCtrl.text.trim(),
      isFeatured: _isFeatured,
      isVisible: widget.project?.isVisible ?? true,
      startDate: widget.project?.startDate,
      endDate: widget.project?.endDate,
      imageUrl: widget.project?.imageUrl,
    );

    final cubit = context.read<PortfolioEditorCubit>();
    PortfolioCubit? portCubit = widget.portfolioCubit;
    if (portCubit == null) {
      try {
        portCubit = context.read<PortfolioCubit>();
      } catch (_) {}
    }

    if (widget.project != null) {
      await cubit.updateProject(uid: widget.uid, project: model);
    } else {
      await cubit.addProject(uid: widget.uid, project: model);
    }

    portCubit?.loadPortfolio(widget.uid);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.project != null;
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
                isEditing ? 'Edit Project' : 'Add Project',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              PortfolioFormField(
                label: 'PROJECT TITLE *',
                controller: _titleCtrl,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 14),
              PortfolioFormField(
                label: 'DESCRIPTION *',
                controller: _descCtrl,
                maxLines: 4,
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 14),
              PortfolioFormField(
                label: 'TECHNOLOGIES (COMMA SEPARATED)',
                controller: _techCtrl,
              ),
              const SizedBox(height: 14),
              PortfolioFormField(
                label: 'PROJECT / DEMO URL',
                controller: _projectUrlCtrl,
              ),
              const SizedBox(height: 14),
              PortfolioFormField(
                label: 'GITHUB REPOSITORY URL',
                controller: _githubUrlCtrl,
              ),
              const SizedBox(height: 14),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isFeatured,
                onChanged: (val) => setState(() => _isFeatured = val ?? false),
                title: Text(
                  'Feature this project on portfolio',
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
