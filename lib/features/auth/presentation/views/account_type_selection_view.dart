import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/auth/presentation/widgets/auth_step_indicator.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_state.dart';
import 'package:connecthub/features/auth/presentation/views/photo_pick_view.dart';
import 'package:connecthub/features/auth/presentation/widgets/account_type_card.dart';
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
            PageRouteBuilder(
              pageBuilder: (_, _, _) => const PhotoPickView(),
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder: (_, anim, _, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.surfaceVariant,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.error, width: 1),
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
          leading: AppIconButton(
            icon: Icons.arrow_back_ios_new,
            size: 18,
            onPressed: () => Navigator.pop(context),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: AuthStepIndicator(currentStep: 2, totalSteps: 3),
            ),
          ],
        ),
        body: DarkGlassBackground(
          child: SafeArea(
            child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Choose your account type',
                              style: AppTextStyles.headline1,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Select how you want to present yourself and collaborate on ConnectHub.',
                              style: AppTextStyles.body2,
                            ),
                            const SizedBox(height: 28),

                            // Personal Account Card
                            AccountTypeCard(
                              title: 'Personal Account',
                              description:
                                  'Connect with peers, share posts, and follow creators.',
                              features: const [
                                'Social feed & discussions',
                                'Direct messaging',
                                'Custom profile',
                              ],
                              icon: Icons.person_outline_rounded,
                              isSelected:
                                  _selectedType == AccountType.personal,
                              onTap: () => setState(
                                  () => _selectedType = AccountType.personal),
                            ),

                            const SizedBox(height: 16),

                            // Professional Account Card
                            AccountTypeCard(
                              title: 'Professional Account',
                              description:
                                  'Elevate your presence with an AI-generated public web portfolio.',
                              features: const [
                                'Everything in Personal',
                                'AI-powered web portfolio site',
                                'Experience, CV & projects showcase',
                              ],
                              icon: Icons.workspace_premium_outlined,
                              badge: 'Pro Portfolio',
                              isSelected:
                                  _selectedType == AccountType.professional,
                              onTap: () => setState(() =>
                                  _selectedType = AccountType.professional),
                            ),

                            const SizedBox(height: 36),

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
                            const SizedBox(height: 32),
                          ],
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
    ),
  );
}
}
