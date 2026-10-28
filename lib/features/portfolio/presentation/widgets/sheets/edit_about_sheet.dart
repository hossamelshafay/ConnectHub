import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/services/portfolio_sync_service.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/sheets/glass_form_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modular Sheet: About Me
// ─────────────────────────────────────────────────────────────────────────────
class EditAboutSheet extends StatefulWidget {
  final String uid;
  final String? initialAbout;
  final PortfolioCubit portfolioCubit;

  const EditAboutSheet({
    super.key,
    required this.uid,
    this.initialAbout,
    required this.portfolioCubit,
  });

  static Future<void> show(
    BuildContext context, {
    required String uid,
    String? initialAbout,
  }) {
    final portfolioCubit = context.read<PortfolioCubit>();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: portfolioCubit,
        child: EditAboutSheet(
          uid: uid,
          initialAbout: initialAbout,
          portfolioCubit: portfolioCubit,
        ),
      ),
    );
  }

  @override
  State<EditAboutSheet> createState() => _EditAboutSheetState();
}

class _EditAboutSheetState extends State<EditAboutSheet> {
  late final TextEditingController _aboutController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _aboutController = TextEditingController(text: widget.initialAbout ?? '');
  }

  @override
  void dispose() {
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
        'about': _aboutController.text.trim(),
      });
      PortfolioSyncService().syncUserPortfolio(widget.uid).ignore();
      widget.portfolioCubit.loadPortfolio(widget.uid);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✨ About Me updated!'),
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
              Icon(Icons.person_outline_rounded, color: kPortfolioAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                'About Me',
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
            'Write a compelling introduction about your expertise, passions, and goals.',
            style: TextStyle(color: kPortfolioTextMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          GlassTextField(
            controller: _aboutController,
            label: 'Professional Summary',
            hint: 'Tell your story...',
            maxLines: 5,
            maxLength: 800,
          ),
          const SizedBox(height: 20),
          SheetActionButtons(
            isLoading: _saving,
            onSave: _save,
          ),
        ],
      ),
    );
  }
}
