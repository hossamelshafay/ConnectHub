import 'package:flutter/material.dart';
import 'package:connecthub/features/portfolio_import/data/models/cv_portfolio_model.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_item_card.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_sheet_helper.dart';

class CvPreviewEducationCard extends StatelessWidget {
  final CvEducationModel edu;
  final ValueChanged<CvEducationModel> onEdit;
  final VoidCallback onDelete;

  const CvPreviewEducationCard({
    super.key,
    required this.edu,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CvPreviewItemCard(
      title: edu.institution.isNotEmpty ? edu.institution : 'Institution',
      subtitle: edu.degree,
      meta: edu.field.isNotEmpty ? edu.field : '',
      body: [edu.startDate, edu.endDate].where((s) => s.isNotEmpty).join(' – '),
      onEdit: () => _openEditSheet(context),
      onDelete: onDelete,
    );
  }

  void _openEditSheet(BuildContext context) {
    final instCtrl = TextEditingController(text: edu.institution);
    final degCtrl = TextEditingController(text: edu.degree);
    final fieldCtrl = TextEditingController(text: edu.field);
    final startCtrl = TextEditingController(text: edu.startDate);
    final endCtrl = TextEditingController(text: edu.endDate);

    showCvEditSheet(
      context: context,
      title: 'Edit Education',
      fields: [
        CvPreviewSheetField(ctrl: instCtrl, label: 'Institution'),
        CvPreviewSheetField(ctrl: degCtrl, label: 'Degree'),
        CvPreviewSheetField(ctrl: fieldCtrl, label: 'Field of Study'),
        CvPreviewSheetField(ctrl: startCtrl, label: 'Start Date'),
        CvPreviewSheetField(ctrl: endCtrl, label: 'End Date'),
      ],
      onSave: () => onEdit(edu.copyWith(
        institution: instCtrl.text.trim(),
        degree: degCtrl.text.trim(),
        field: fieldCtrl.text.trim(),
        startDate: startCtrl.text.trim(),
        endDate: endCtrl.text.trim(),
      )),
    );
  }
}
