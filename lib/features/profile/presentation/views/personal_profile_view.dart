import 'package:flutter/material.dart';
import 'package:connecthub/features/profile/presentation/views/profile_view.dart';

/// Canonical Personal Profile view for friends, family, and everyday social networking.
class PersonalProfileView extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback? onSwitchToPortfolio;

  const PersonalProfileView({
    super.key,
    this.showBackButton = false,
    this.onSwitchToPortfolio,
  });

  @override
  Widget build(BuildContext context) {
    return ProfileView(
      showBackButton: showBackButton,
      onSwitchToPortfolio: onSwitchToPortfolio,
    );
  }
}
