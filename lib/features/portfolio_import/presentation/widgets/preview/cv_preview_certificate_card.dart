import 'package:flutter/material.dart';
import 'package:connecthub/features/portfolio_import/data/models/cv_portfolio_model.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_item_card.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/preview/cv_preview_sheet_helper.dart';

class CvPreviewCertificateCard extends StatelessWidget {
  final CvCertificateModel cert;
  final ValueChanged<CvCertificateModel> onEdit;
  final VoidCallback onDelete;

  const CvPreviewCertificateCard({
    super.key,
    required this.cert,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return CvPreviewItemCard(
      title: cert.title.isNotEmpty ? cert.title : 'Certificate',
      subtitle: cert.issuer,
      meta: cert.date,
      body: cert.url.isNotEmpty ? cert.url : '',
      onEdit: () => _openEditSheet(context),
      onDelete: onDelete,
    );
  }

  void _openEditSheet(BuildContext context) {
    final titleCtrl = TextEditingController(text: cert.title);
    final issuerCtrl = TextEditingController(text: cert.issuer);
    final dateCtrl = TextEditingController(text: cert.date);
    final urlCtrl = TextEditingController(text: cert.url);

    showCvEditSheet(
      context: context,
      title: 'Edit Certificate',
      fields: [
        CvPreviewSheetField(ctrl: titleCtrl, label: 'Title'),
        CvPreviewSheetField(ctrl: issuerCtrl, label: 'Issuing Organization'),
        CvPreviewSheetField(ctrl: dateCtrl, label: 'Date'),
        CvPreviewSheetField(ctrl: urlCtrl, label: 'Credential URL'),
      ],
      onSave: () => onEdit(cert.copyWith(
        title: titleCtrl.text.trim(),
        issuer: issuerCtrl.text.trim(),
        date: dateCtrl.text.trim(),
        url: urlCtrl.text.trim(),
      )),
    );
  }
}
