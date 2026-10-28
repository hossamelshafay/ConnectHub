import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/theme/theme_cubit.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_cubit.dart';
import 'package:connecthub/features/home/presentation/widgets/home_app_bar.dart';
import 'package:connecthub/features/home/presentation/widgets/home_feed_sliver.dart';
import 'package:connecthub/features/home/presentation/widgets/home_post_composer.dart';
import 'package:connecthub/features/post/presentation/views/create_post_view.dart';
import 'package:connecthub/features/notification/presentation/manager/cubit/notification_cubit.dart';
import 'package:connecthub/features/chat/presentation/manager/cubit/conversations_cubit.dart';
import 'package:connecthub/features/chat/data/repos/chat_repo_imp.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_state.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<PostsCubit>().loadPosts();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<NotificationCubit>().listenToNotifications(uid);
      context.read<ConversationsCubit>().listenToConversations(uid);
      ChatRepoImp().setPresence(uid, true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      ChatRepoImp().setPresence(uid, false);
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    switch (state) {
      case AppLifecycleState.resumed:
        ChatRepoImp().setPresence(uid, true);
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        ChatRepoImp().setPresence(uid, false);
        break;
    }
  }

  void _openCreatePost() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const CreatePostView(),
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(opacity: anim, child: child),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.read<PostsCubit>().loadPosts();
          context.read<NotificationCubit>().listenToNotifications(state.user.uid);
          context.read<ConversationsCubit>().listenToConversations(state.user.uid);
          ChatRepoImp().setPresence(state.user.uid, true);
        }
      },
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: HomeAppBar(currentUserId: currentUserId),
            body: DarkGlassBackground(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<PostsCubit>().loadPosts();
                },
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceVariant,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    // ── Inline Post Composer ──────────────────────────────────
                    SliverToBoxAdapter(
                      child: HomePostComposer(
                        currentUserId: currentUserId,
                        onTap: _openCreatePost,
                      ),
                    ),

                    // ── Feed Posts List ───────────────────────────────────────
                    HomeFeedSliver(
                      currentUserId: currentUserId,
                      onOpenCreatePost: _openCreatePost,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
