import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/services/portfolio_sync_service.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/sheets/glass_form_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modular Sheet: Contact & Social Links
// ─────────────────────────────────────────────────────────────────────────────
class EditContactSheet extends StatefulWidget {
  final String uid;
  final UserModel user;
  final PortfolioCubit portfolioCubit;

  const EditContactSheet({
    super.key,
    required this.uid,
    required this.user,
    required this.portfolioCubit,
  });

  static Future<void> show(
    BuildContext context, {
    required String uid,
    required UserModel user,
  }) {
    final portfolioCubit = context.read<PortfolioCubit>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: portfolioCubit,
        child: EditContactSheet(
          uid: uid,
          user: user,
          portfolioCubit: portfolioCubit,
        ),
      ),
    );
  }

  @override
  State<EditContactSheet> createState() => _EditContactSheetState();
}

class _EditContactSheetState extends State<EditContactSheet> {
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  late final TextEditingController _githubController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _websiteController;
  late final TextEditingController _cvLinkController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final links = widget.user.socialLinks;
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _locationController = TextEditingController(text: widget.user.location ?? '');
    _githubController = TextEditingController(
      text: widget.user.githubUsername ?? links.github ?? '',
    );
    _linkedinController = TextEditingController(text: links.linkedin ?? '');
    _websiteController = TextEditingController(text: links.website ?? links.portfolio ?? '');
    _cvLinkController = TextEditingController(text: widget.user.cvLink ?? widget.user.resumeUrl ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _locationController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _websiteController.dispose();
    _cvLinkController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final phone = _phoneController.text.trim();
      final loc = _locationController.text.trim();
      final gh = _githubController.text.trim().replaceAll('@', '');
      final li = _linkedinController.text.trim();
      final web = _websiteController.text.trim();
      final cvLink = _cvLinkController.text.trim();

      final currentLinks = widget.user.socialLinks.toMap();
      currentLinks['phone'] = phone;
      currentLinks['github'] = gh;
      currentLinks['linkedin'] = li;
      currentLinks['website'] = web;
      currentLinks['location'] = loc;

      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
        'phone': phone,
        'location': loc,
        'githubUsername': gh,
        'cvLink': cvLink,
        'resumeUrl': cvLink,
        'socialLinks': currentLinks,
      });

      PortfolioSyncService().syncUserPortfolio(widget.uid).ignore();
      widget.portfolioCubit.loadPortfolio(widget.uid);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✨ Contact & links updated!'),
            backgroundColor: kPortfolioAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Icon(Icons.alternate_email_rounded, color: kPortfolioAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Contact & Links',
                style: TextStyle(
                  color: kPortfolioTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Keep your professional links and contact channels up to date.',
            style: TextStyle(color: kPortfolioTextMuted, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  GlassTextField(
                    controller: _locationController,
                    label: 'Location / City',
                    hint: 'e.g. San Francisco, CA / Cairo, Egypt',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 14),
                  GlassTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: 'e.g. +1 (555) 000-0000',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  GlassTextField(
                    controller: _githubController,
                    label: 'GitHub Username or Link',
                    hint: 'e.g. torvalds or https://github.com/...',
                    prefixIcon: Icons.code_rounded,
                  ),
                  const SizedBox(height: 14),
                  GlassTextField(
                    controller: _linkedinController,
                    label: 'LinkedIn Profile',
                    hint: 'e.g. https://linkedin.com/in/...',
                    prefixIcon: Icons.business_center_outlined,
                  ),
                  const SizedBox(height: 14),
                  GlassTextField(
                    controller: _websiteController,
                    label: 'Custom Website / Portfolio URL',
                    hint: 'e.g. https://yourdomain.com',
                    prefixIcon: Icons.language_rounded,
                  ),
                  const SizedBox(height: 14),
                  GlassTextField(
                    controller: _cvLinkController,
                    label: 'CV Link',
                    hint: 'e.g. Google Drive / Dropbox / OneDrive link',
                    prefixIcon: Icons.description_outlined,
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SheetActionButtons(
            isLoading: _saving,
            onSave: _save,
          ),
        ],
      ),
    );
  }
}
