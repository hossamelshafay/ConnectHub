import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/generate_website/presentation/widgets/generate_website_button.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';

void showGenerateWebsiteSheet({
  required BuildContext context,
  required UserModel user,
  required bool isCurrentUser,
  required bool isUpdate,
  required Function(String, {required bool isError}) onShowSnack,
}) {
  final portfolioCubit = context.read<PortfolioCubit>();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: portfolioCubit,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              isUpdate ? 'Update Portfolio Website' : 'Generate Web Portfolio',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              isUpdate
                  ? 'Re-publish your latest portfolio information to your live public link.'
                  : 'Create a permanent, high-performance public glass portfolio website.',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GenerateWebsiteButton(
              user: user,
              isOwner: isCurrentUser,
              compact: false,
              isUpdate: isUpdate,
              onWebsiteGenerated: () {
                Navigator.pop(context);
                portfolioCubit.loadPortfolio(user.uid);
                onShowSnack(
                  isUpdate ? '✨ Website updated to latest version!' : '✨ Website generated successfully!',
                  isError: false,
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
}
