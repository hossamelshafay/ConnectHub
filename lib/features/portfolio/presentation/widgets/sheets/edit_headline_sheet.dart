import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/services/portfolio_sync_service.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/sheets/glass_form_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modular Sheet: Headline & Role
// ─────────────────────────────────────────────────────────────────────────────
class EditHeadlineSheet extends StatefulWidget {
  final String uid;
  final String? initialHeadline;
  final String? initialBio;
  final PortfolioCubit portfolioCubit;

  const EditHeadlineSheet({
    super.key,
    required this.uid,
    this.initialHeadline,
    this.initialBio,
    required this.portfolioCubit,
  });

  static Future<void> show(
    BuildContext context, {
    required String uid,
    String? initialHeadline,
    String? initialBio,
  }) {
    final portfolioCubit = context.read<PortfolioCubit>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: portfolioCubit,
        child: EditHeadlineSheet(
          uid: uid,
          initialHeadline: initialHeadline,
          initialBio: initialBio,
          portfolioCubit: portfolioCubit,
        ),
      ),
    );
  }

  @override
  State<EditHeadlineSheet> createState() => _EditHeadlineSheetState();
}

class _EditHeadlineSheetState extends State<EditHeadlineSheet> {
  late final TextEditingController _headlineController;
  late final TextEditingController _bioController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _headlineController = TextEditingController(text: widget.initialHeadline ?? '');
    _bioController = TextEditingController(text: widget.initialBio ?? '');
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
        'headline': _headlineController.text.trim(),
        'about': _bioController.text.trim(),
      });
      PortfolioSyncService().syncUserPortfolio(widget.uid).ignore();
      widget.portfolioCubit.loadPortfolio(widget.uid);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✨ Profile header updated!'),
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
              Icon(Icons.badge_outlined, color: kPortfolioAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'Edit Profile Header',
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
            'Your professional headline appears under your name across ConnectHub.',
            style: TextStyle(color: kPortfolioTextMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          GlassTextField(
            controller: _headlineController,
            label: 'Headline / Role',
            hint: 'e.g. Senior Flutter & AI Engineer',
            prefixIcon: Icons.work_outline_rounded,
          ),
          const SizedBox(height: 16),
          GlassTextField(
            controller: _bioController,
            label: 'Short Bio',
            hint: 'A quick 1-2 sentence tagline...',
            prefixIcon: Icons.format_quote_rounded,
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          SheetActionButtons(
            isLoading: _saving,
            onSave: _save,
          ),
        ],
      ),
    );
  }
}
