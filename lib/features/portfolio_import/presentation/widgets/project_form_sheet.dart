import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/portfolio/data/models/project_model.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_editor_cubit.dart';

class ProjectFormSheet extends StatefulWidget {
  final String uid;
  final ProjectModel? project;

  const ProjectFormSheet({
    super.key,
    required this.uid,
    this.project,
  });

  static Future<void> show(
    BuildContext context, {
    required String uid,
    ProjectModel? project,
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
        child: ProjectFormSheet(uid: uid, project: project),
      ),
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
    if (widget.project != null) {
      await cubit.updateProject(uid: widget.uid, project: model);
    } else {
      await cubit.addProject(uid: widget.uid, project: model);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                    color: const Color(0xFF475569),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEditing ? 'Edit Project' : 'Add Project',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _buildField(
                label: 'PROJECT TITLE *',
                controller: _titleCtrl,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'DESCRIPTION *',
                controller: _descCtrl,
                maxLines: 4,
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'TECHNOLOGIES (COMMA SEPARATED)',
                controller: _techCtrl,
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'PROJECT / DEMO URL',
                controller: _projectUrlCtrl,
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'GITHUB REPOSITORY URL',
                controller: _githubUrlCtrl,
              ),
              const SizedBox(height: 14),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isFeatured,
                onChanged: (val) => setState(() => _isFeatured = val ?? false),
                title: const Text(
                  'Feature this project on portfolio',
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
