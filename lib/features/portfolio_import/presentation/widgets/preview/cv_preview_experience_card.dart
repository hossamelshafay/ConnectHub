import 'package:flutter/material.dart';
import 'package:connecthub/features/portfolio_import/data/models/cv_portfolio_model.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_item_card.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_sheet_helper.dart';

class CvPreviewExperienceCard extends StatelessWidget {
  final CvExperienceModel exp;
  final ValueChanged<CvExperienceModel> onEdit;
  final VoidCallback onDelete;

  const CvPreviewExperienceCard({
    super.key,
    required this.exp,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CvPreviewItemCard(
      title: exp.position.isNotEmpty ? exp.position : 'Untitled Role',
      subtitle: exp.company,
      meta:
          [exp.startDate, exp.endDate].where((s) => s.isNotEmpty).join(' – '),
      body: exp.description,
      onEdit: () => _openEditSheet(context),
      onDelete: onDelete,
    );
  }

  void _openEditSheet(BuildContext context) {
    final compCtrl = TextEditingController(text: exp.company);
    final posCtrl = TextEditingController(text: exp.position);
    final startCtrl = TextEditingController(text: exp.startDate);
    final endCtrl = TextEditingController(text: exp.endDate);
    final descCtrl = TextEditingController(text: exp.description);

    showCvEditSheet(
      context: context,
      title: 'Edit Experience',
      fields: [
        CvPreviewSheetField(ctrl: compCtrl, label: 'Company'),
        CvPreviewSheetField(ctrl: posCtrl, label: 'Position'),
        CvPreviewSheetField(ctrl: startCtrl, label: 'Start Date'),
        CvPreviewSheetField(ctrl: endCtrl, label: 'End Date (or "Present")'),
        CvPreviewSheetField(ctrl: descCtrl, label: 'Description', maxLines: 3),
      ],
      onSave: () => onEdit(exp.copyWith(
        company: compCtrl.text.trim(),
        position: posCtrl.text.trim(),
        startDate: startCtrl.text.trim(),
        endDate: endCtrl.text.trim(),
        description: descCtrl.text.trim(),
      )),
    );
  }
}
