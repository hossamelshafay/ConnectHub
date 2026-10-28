import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/theme/theme_cubit.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import 'package:connecthub/features/profile/presentation/views/personal_profile_view.dart';
import 'package:connecthub/features/portfolio/presentation/views/portfolio_view.dart';
import 'package:connecthub/features/profile/presentation/views/user_profile_view.dart';

/// Available profile views for a user.
enum ProfileMode {
  social,
  portfolio,
}

/// Centralized Reusable Profile Router.
///
/// Responsibilities:
/// - Resolves the user's [AccountType] dynamically without duplicate reads.
/// - Defaults to [ProfileMode.social] for all navigation entries.
/// - Enables seamless, stateful animated switching between Social Profile and
///   Professional Portfolio when the user is professional.
/// - Hides the switch entirely when the user is personal.
class ProfileRouter extends StatefulWidget {
  final String userId;
  final String? userName;
  final bool showBackButton;
  final ProfileMode mode;

  const ProfileRouter({
    super.key,
    required this.userId,
    this.userName,
    this.showBackButton = false,
    this.mode = ProfileMode.social,
  });

  @override
  State<ProfileRouter> createState() => _ProfileRouterState();
}

class _ProfileRouterState extends State<ProfileRouter> {
  late ProfileMode _currentMode;
  late Stream<DocumentSnapshot> _userStream;

  @override
  void initState() {
    super.initState();
    _currentMode = widget.mode;
    _initStream();
  }

  void _initStream() {
    _userStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .snapshots();
  }

  @override
  void didUpdateWidget(covariant ProfileRouter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != oldWidget.userId) {
      _initStream();
    }
    if (widget.mode != oldWidget.mode) {
      _currentMode = widget.mode;
    }
  }

  void _switchToPortfolio() {
    setState(() {
      _currentMode = ProfileMode.portfolio;
    });
  }

  void _switchToSocial() {
    setState(() {
      _currentMode = ProfileMode.social;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        if (widget.userId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Invalid user.')),
          );
        }

        final currentUid = FirebaseAuth.instance.currentUser?.uid;
        final isMe = currentUid != null && currentUid == widget.userId;

        return StreamBuilder<DocumentSnapshot>(
          stream: _userStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return Scaffold(
                backgroundColor: AppColors.background,
                appBar: AppBar(
                  backgroundColor: AppColors.background,
                  elevation: 0,
                  leading: widget.showBackButton
                      ? Center(
                          child: AppIconButton(
                            icon: Icons.arrow_back_ios_new,
                            size: 18,
                            onPressed: () => Navigator.pop(context),
                          ),
                        )
                      : null,
                ),
                body: const SafeArea(
                  child: ProfileHeaderShimmer(includePosts: true),
                ),
              );
            }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(
              leading: widget.showBackButton
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
            ),
            body: Center(
              child: Text(
                'User not found.',
                style: AppTextStyles.body2,
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        final accountType =
            AccountType.fromString(data['accountType'] as String?);
        final isProfessional = accountType == AccountType.professional;

        // Visibility Rule: If personal, hide portfolio switch entirely.
        final canSwitch = isProfessional;

        final name = (data['name'] as String?)?.trim();
        final effectiveName = (name != null && name.isNotEmpty)
            ? name
            : (widget.userName ?? 'User');

        // Determine active child widget
        final Widget activeWidget;
        if (_currentMode == ProfileMode.portfolio && canSwitch) {
          activeWidget = KeyedSubtree(
            key: const ValueKey('portfolio_view'),
            child: PortfolioView(
              userId: widget.userId,
              isCurrentUser: isMe,
              showBackButton: widget.showBackButton,
              onSwitchToSocial: _switchToSocial,
            ),
          );
        } else {
          // Social Profile view
          final VoidCallback? onSwitch = canSwitch ? _switchToPortfolio : null;
          final Widget socialChild = isMe
              ? PersonalProfileView(
                  showBackButton: widget.showBackButton,
                  onSwitchToPortfolio: onSwitch,
                )
              : UserProfileView(
                  userId: widget.userId,
                  userName: effectiveName,
                  onSwitchToPortfolio: onSwitch,
                );

          activeWidget = KeyedSubtree(
            key: const ValueKey('social_view'),
            child: socialChild,
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: activeWidget,
        );
      },
    );
      },
    );
  }
}
