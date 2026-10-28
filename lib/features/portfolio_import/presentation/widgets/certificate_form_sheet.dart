import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/portfolio/data/models/certificate_model.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_editor_cubit.dart';

import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/portfolio_import/presentation/widgets/portfolio_form_field.dart';

class CertificateFormSheet extends StatefulWidget {
  final String uid;
  final CertificateModel? certificate;
  final PortfolioCubit? portfolioCubit;

  const CertificateFormSheet({
    super.key,
    required this.uid,
    this.certificate,
    this.portfolioCubit,
  });

  static Future<void> show(
    BuildContext context, {
    required String uid,
    CertificateModel? certificate,
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
        Widget content = CertificateFormSheet(
          uid: uid,
          certificate: certificate,
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
  State<CertificateFormSheet> createState() => _CertificateFormSheetState();
}

class _CertificateFormSheetState extends State<CertificateFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _orgCtrl;
  late final TextEditingController _credIdCtrl;
  late final TextEditingController _credUrlCtrl;

  @override
  void initState() {
    super.initState();
    final cert = widget.certificate;
    _titleCtrl = TextEditingController(text: cert?.title ?? '');
    _orgCtrl = TextEditingController(text: cert?.issuingOrganization ?? '');
    _credIdCtrl = TextEditingController(text: cert?.credentialId ?? '');
    _credUrlCtrl = TextEditingController(text: cert?.credentialUrl ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _orgCtrl.dispose();
    _credIdCtrl.dispose();
    _credUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final model = CertificateModel(
      id: widget.certificate?.id ?? '',
      title: _titleCtrl.text.trim(),
      issuingOrganization: _orgCtrl.text.trim(),
      credentialId: _credIdCtrl.text.trim().isEmpty ? null : _credIdCtrl.text.trim(),
      credentialUrl: _credUrlCtrl.text.trim().isEmpty ? null : _credUrlCtrl.text.trim(),
      isVisible: widget.certificate?.isVisible ?? true,
      issueDate: widget.certificate?.issueDate,
      expirationDate: widget.certificate?.expirationDate,
    );

    final cubit = context.read<PortfolioEditorCubit>();
    PortfolioCubit? portCubit = widget.portfolioCubit;
    if (portCubit == null) {
      try {
        portCubit = context.read<PortfolioCubit>();
      } catch (_) {}
    }

    if (widget.certificate != null) {
      await cubit.updateCertificate(uid: widget.uid, certificate: model);
    } else {
      await cubit.addCertificate(uid: widget.uid, certificate: model);
    }

    portCubit?.loadPortfolio(widget.uid);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.certificate != null;
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
                isEditing ? 'Edit Certificate' : 'Add Certificate',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              PortfolioFormField(
                label: 'CERTIFICATE TITLE *',
                controller: _titleCtrl,
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 14),
              PortfolioFormField(
                label: 'ISSUING ORGANIZATION *',
                controller: _orgCtrl,
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Organization is required'
                    : null,
              ),
              const SizedBox(height: 14),
              PortfolioFormField(
                label: 'CREDENTIAL ID',
                controller: _credIdCtrl,
              ),
              const SizedBox(height: 14),
              PortfolioFormField(
                label: 'CREDENTIAL URL',
                controller: _credUrlCtrl,
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
