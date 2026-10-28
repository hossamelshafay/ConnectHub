import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';

void showDeleteWebsiteSheet(
  BuildContext context,
  UserModel user,
  Function(String, {required bool isError}) onShowSnack,
) {
  final portfolioCubit = context.read<PortfolioCubit>();
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 24),
          ),
          const SizedBox(height: 16),
          const Text(
            'Delete Portfolio Website?',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your public portfolio link will be disabled and taken down. You can regenerate it anytime.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF94A3B8),
                    side: BorderSide(color: AppColors.glassBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    try {
                      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                        'websiteGenerated': false,
                        'websiteUrl': FieldValue.delete(),
                        'generatedAt': FieldValue.delete(),
                      });
                      final rawUsername = user.username?.trim();
                      final rawSlug = user.profileSlug?.trim();
                      final docId = (rawUsername != null && rawUsername.isNotEmpty)
                          ? rawUsername.toLowerCase()
                          : (rawSlug != null && rawSlug.isNotEmpty)
                              ? rawSlug.toLowerCase()
                              : user.uid;
                      await FirebaseFirestore.instance.collection('public_portfolios').doc(docId).delete();
                      portfolioCubit.loadPortfolio(user.uid);
                      if (context.mounted) {
                        onShowSnack('Website unpublished.', isError: false);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        onShowSnack('Failed to unpublish website: $e', isError: true);
                      }
                    }
                  },
                  child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
