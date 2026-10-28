import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/theme/theme_cubit.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_cubit.dart';
import 'package:connecthub/features/portfolio/presentation/cubit/portfolio_state.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_editor_cubit.dart';
import 'package:connecthub/features/portfolio_import/presentation/cubit/portfolio_import_state.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_theme.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_background.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_state_views.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/floating_profile_section.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/action_buttons_row.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/stats_card.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/pinned_tabs_bar.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_tab_sections.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/portfolio_top_bar.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/sheets/edit_headline_sheet.dart';
import 'package:connecthub/features/portfolio/presentation/widgets/sheets/edit_contact_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PortfolioView — Entry Point
// ─────────────────────────────────────────────────────────────────────────────
class PortfolioView extends StatelessWidget {
  final String userId;
  final bool isCurrentUser;
  final bool showBackButton;
  final VoidCallback? onSwitchToSocial;

  const PortfolioView({
    super.key,
    required this.userId,
    required this.isCurrentUser,
    this.showBackButton = false,
    this.onSwitchToSocial,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PortfolioCubit()..loadPortfolio(userId)),
        BlocProvider(create: (_) => PortfolioEditorCubit()),
      ],
      child: _PortfolioViewBody(
        userId: userId,
        isCurrentUser: isCurrentUser,
        showBackButton: showBackButton,
        onSwitchToSocial: onSwitchToSocial,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Portfolio View Body (Stateful for pinned tabs navigation)
// ─────────────────────────────────────────────────────────────────────────────
class _PortfolioViewBody extends StatefulWidget {
  final String userId;
  final bool isCurrentUser;
  final bool showBackButton;
  final VoidCallback? onSwitchToSocial;

  const _PortfolioViewBody({
    required this.userId,
    required this.isCurrentUser,
    required this.showBackButton,
    this.onSwitchToSocial,
  });

  @override
  State<_PortfolioViewBody> createState() => _PortfolioViewBodyState();
}

class _PortfolioViewBodyState extends State<_PortfolioViewBody> {
  late final ValueNotifier<int> _selectedTabNotifier;
  static const List<String> _tabs = [
    'Overview',
    'Projects',
    'Experience',
    'Skills',
    'Certificates',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTabNotifier = ValueNotifier<int>(0);
  }

  @override
  void dispose() {
    _selectedTabNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // ── Fixed Background Canvas (Atmospheric Frosted Glass) ──────────
              const PortfolioBackground(),

              // ── Content Shifted Downward (Respects SafeArea + 24px) ─────────
              Positioned.fill(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Column(
                      children: [
                        PortfolioTopBar(
                          showBackButton: widget.showBackButton,
                          isCurrentUser: widget.isCurrentUser,
                          onSwitchToSocial: widget.onSwitchToSocial,
                          onShowSnack: _showSnack,
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: BlocListener<PortfolioEditorCubit, PortfolioEditorState>(
                            listener: (context, editorState) {
                              if (editorState is PortfolioEditorSaved) {
                                _showSnack(editorState.message, isError: false);
                                context.read<PortfolioCubit>().loadPortfolio(widget.userId);
                              } else if (editorState is PortfolioEditorError) {
                                _showSnack('Error: ${editorState.message}', isError: true);
                              }
                            },
                            child: BlocBuilder<PortfolioCubit, PortfolioState>(
                              buildWhen: (previous, current) {
                                if (current is PortfolioUpdating || current is PortfolioUpdateSuccess) return false;
                                return true;
                              },
                              builder: (context, state) {
                                if (state is PortfolioLoading || state is PortfolioInitial) {
                                  return const PortfolioLoadingView();
                                }
                                if (state is PortfolioError) {
                                  return PortfolioErrorView(
                                    message: state.message,
                                    onRetry: () => context.read<PortfolioCubit>().loadPortfolio(widget.userId),
                                  );
                                }
                                if (state is! PortfolioLoaded) return const SizedBox.shrink();

                                final user = state.user;
                                final vis = user.sectionVisibility;

                                return CustomScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  slivers: [
                                    SliverPadding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      sliver: SliverList.list(
                                        children: [
                                          // ── 1. Floating Profile Section ─────────────
                                          FloatingProfileSection(
                                            user: user,
                                            isCurrentUser: widget.isCurrentUser,
                                            onEdit: () => EditHeadlineSheet.show(
                                              context,
                                              uid: widget.userId,
                                              initialHeadline: user.headline,
                                              initialBio: user.about,
                                            ),
                                            onAddContactInfo: () => EditContactSheet.show(
                                              context,
                                              uid: user.uid,
                                              user: user,
                                            ),
                                          ),
                                          const SizedBox(height: 14),

                                          // ── 2. Action Buttons ───────────────────────
                                          ActionButtonsRow(
                                            userId: widget.userId,
                                            user: user,
                                            isCurrentUser: widget.isCurrentUser,
                                            onSwitchToSocial: widget.onSwitchToSocial,
                                          ),
                                          const SizedBox(height: 14),

                                          // ── 3. Statistics Card ──────────────────────
                                          StatsCard(
                                            projectsCount: state.projects.length,
                                            experienceYears: state.experienceYears,
                                            certsCount: state.certificates.length,
                                            skillsCount: user.skills.length,
                                          ),
                                          const SizedBox(height: 14),

                                          // ── 4. Pinned Tabs & Dynamic Content ────────
                                          ValueListenableBuilder<int>(
                                            valueListenable: _selectedTabNotifier,
                                            builder: (context, selectedIndex, _) {
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  PinnedTabsBar(
                                                    tabs: _tabs,
                                                    selectedIndex: selectedIndex,
                                                    onTabSelected: (index) {
                                                      _selectedTabNotifier.value = index;
                                                    },
                                                  ),
                                                  const SizedBox(height: 14),
                                                  PortfolioTabSections(
                                                    selectedTabIndex: selectedIndex,
                                                    state: state,
                                                    user: user,
                                                    vis: vis,
                                                    userId: widget.userId,
                                                    isCurrentUser: widget.isCurrentUser,
                                                  ),
                                                ],
                                              );
                                            },
                                          ),

                                          const SizedBox(height: 48),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? const Color(0xFFEF4444) : kPortfolioAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
