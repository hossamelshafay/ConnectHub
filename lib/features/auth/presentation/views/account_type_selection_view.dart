import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_state.dart';
import 'package:connecthub/features/home/presentation/views/home_view.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';

class AccountTypeSelectionView extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const AccountTypeSelectionView({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<AccountTypeSelectionView> createState() =>
      _AccountTypeSelectionViewState();
}

class _AccountTypeSelectionViewState extends State<AccountTypeSelectionView> {
  AccountType _selectedType = AccountType.personal;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeView()),
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              final horizontalPadding = isNarrow ? 16.0 : 24.0;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              Text(
                                'What best describes your account?',
                                style: AppTextStyles.headline1.copyWith(
                                  fontSize: isNarrow ? 22 : 26,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Choose the account type that best fits your goals on ConnectHub.',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: isNarrow ? 13 : 14,
                                ),
                              ),
                              SizedBox(height: isNarrow ? 20 : 32),

                              // ── Personal Account Card ────────────────────────────────────
                              _AccountTypeCard(
                                title: 'Personal Account',
                                description:
                                    'For friends, family and everyday social networking.',
                                icon: Icons.people_outline_rounded,
                                isSelected: _selectedType == AccountType.personal,
                                isNarrow: isNarrow,
                                onTap: () =>
                                    setState(() => _selectedType = AccountType.personal),
                              ),

                              const SizedBox(height: 16),

                              // ── Professional Account Card ────────────────────────────────
                              _AccountTypeCard(
                                title: 'Professional Account',
                                description:
                                    'Create an AI-powered portfolio showcasing your experience, education, projects and achievements.',
                                icon: Icons.work_outline_rounded,
                                badge: 'Portfolio',
                                isSelected: _selectedType == AccountType.professional,
                                isNarrow: isNarrow,
                                onTap: () =>
                                    setState(() => _selectedType = AccountType.professional),
                              ),

                              const Spacer(),
                              const SizedBox(height: 24),

                              BlocBuilder<AuthCubit, AuthState>(
                                builder: (context, state) {
                                  return PrimaryButton(
                                    text: 'Create Account',
                                    isLoading: state is AuthLoading,
                                    onPressed: () {
                                      context.read<AuthCubit>().signUp(
                                            name: widget.name,
                                            email: widget.email,
                                            password: widget.password,
                                            accountType: _selectedType,
                                          );
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? badge;
  final bool isSelected;
  final bool isNarrow;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.title,
    required this.description,
    required this.icon,
    this.badge,
    required this.isSelected,
    this.isNarrow = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isNarrow ? 14 : 20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isNarrow ? 10 : 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textPrimary,
                size: isNarrow ? 20 : 24,
              ),
            ),
            SizedBox(width: isNarrow ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: isNarrow ? 14 : 16,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: isNarrow ? 12 : 14,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: isNarrow ? 18 : 22,
              height: isNarrow ? 18 : 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textHint,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: isNarrow ? 12 : 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
