import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/portfolio/data/models/certificate_model.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_editor_cubit.dart';

class CertificateFormSheet extends StatefulWidget {
  final String uid;
  final CertificateModel? certificate;

  const CertificateFormSheet({
    super.key,
    required this.uid,
    this.certificate,
  });

  static Future<void> show(
    BuildContext context, {
    required String uid,
    CertificateModel? certificate,
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
        child: CertificateFormSheet(uid: uid, certificate: certificate),
      ),
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
    if (widget.certificate != null) {
      await cubit.updateCertificate(uid: widget.uid, certificate: model);
    } else {
      await cubit.addCertificate(uid: widget.uid, certificate: model);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
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
                    color: const Color(0xFF475569),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEditing ? 'Edit Certificate' : 'Add Certificate',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              _buildField(
                label: 'CERTIFICATE TITLE *',
                controller: _titleCtrl,
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'ISSUING ORGANIZATION *',
                controller: _orgCtrl,
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? 'Organization is required'
                    : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'CREDENTIAL ID',
                controller: _credIdCtrl,
              ),
              const SizedBox(height: 14),
              _buildField(
                label: 'CREDENTIAL URL',
                controller: _credUrlCtrl,
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
