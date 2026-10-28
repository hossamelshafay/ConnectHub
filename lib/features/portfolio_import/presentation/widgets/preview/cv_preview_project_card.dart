import 'package:flutter/material.dart';
import 'package:connecthub/features/portfolio_import/data/models/cv_portfolio_model.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_item_card.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_sheet_helper.dart';

class CvPreviewProjectCard extends StatelessWidget {
  final CvProjectModel project;
  final ValueChanged<CvProjectModel> onEdit;
  final VoidCallback onDelete;

  const CvPreviewProjectCard({
    super.key,
    required this.project,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CvPreviewItemCard(
      title: project.title.isNotEmpty ? project.title : 'Untitled Project',
      subtitle:
          project.techStack.isNotEmpty ? project.techStack.join(', ') : '',
      meta: project.github.isNotEmpty ? project.github : project.liveDemo,
      body: project.description,
      onEdit: () => _openEditSheet(context),
      onDelete: onDelete,
    );
  }

  void _openEditSheet(BuildContext context) {
    final titleCtrl = TextEditingController(text: project.title);
    final descCtrl = TextEditingController(text: project.description);
    final techCtrl = TextEditingController(text: project.techStack.join(', '));
    final githubCtrl = TextEditingController(text: project.github);
    final demoCtrl = TextEditingController(text: project.liveDemo);

    showCvEditSheet(
      context: context,
      title: 'Edit Project',
      fields: [
        CvPreviewSheetField(ctrl: titleCtrl, label: 'Title'),
        CvPreviewSheetField(ctrl: descCtrl, label: 'Description', maxLines: 3),
        CvPreviewSheetField(
          ctrl: techCtrl,
          label: 'Tech Stack (comma-separated)',
        ),
        CvPreviewSheetField(ctrl: githubCtrl, label: 'GitHub URL'),
        CvPreviewSheetField(ctrl: demoCtrl, label: 'Live Demo URL'),
      ],
      onSave: () => onEdit(project.copyWith(
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        techStack: techCtrl.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        github: githubCtrl.text.trim(),
        liveDemo: demoCtrl.text.trim(),
      )),
    );
  }
}
