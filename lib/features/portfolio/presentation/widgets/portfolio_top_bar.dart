import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_state.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/glass_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/sheets/portfolio_actions_sheet.dart';

class PortfolioTopBar extends StatelessWidget {
  final bool showBackButton;
  final bool isCurrentUser;
  final VoidCallback? onSwitchToSocial;
  final Function(String, {required bool isError}) onShowSnack;

  const PortfolioTopBar({
    super.key,
    required this.showBackButton,
    required this.isCurrentUser,
    this.onSwitchToSocial,
    required this.onShowSnack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBackButton)
            CircleGlassButton(
              icon: Icons.arrow_back_ios_new_rounded,
              size: 16,
              onTap: () => Navigator.pop(context),
            )
          else
            const SizedBox(width: 38),
          BlocBuilder<PortfolioCubit, PortfolioState>(
            builder: (context, state) {
              final user = state is PortfolioLoaded ? state.user : null;
              return CircleGlassButton(
                icon: Icons.more_horiz_rounded,
                size: 20,
                onTap: () => PortfolioActionsSheet.showMoreSheet(
                  context: context,
                  user: user,
                  isCurrentUser: isCurrentUser,
                  onSwitchToSocial: onSwitchToSocial,
                  onShowSnack: onShowSnack,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
