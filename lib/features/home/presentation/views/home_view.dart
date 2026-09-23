import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_cubit.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_state.dart';
import 'package:connecthub/features/home/presentation/widgets/post_card.dart';
import 'package:connecthub/features/post/presentation/views/create_post_view.dart';
import 'package:connecthub/features/post/presentation/views/post_details_view.dart';
import 'package:connecthub/features/chatbot/presentation/views/chatbot_view.dart';
import 'package:connecthub/features/notification/presentation/manager/cubit/notification_cubit.dart';
import 'package:connecthub/features/notification/presentation/manager/cubit/notification_state.dart';
import 'package:connecthub/features/notification/presentation/views/notification_view.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_cubit.dart';
import 'package:connecthub/features/auth/presentation/manager/cubit/auth_state.dart';
import 'package:connecthub/features/profile/presentation/views/profile_view.dart';
import 'package:connecthub/features/search/presentation/views/search_view.dart';
import 'package:connecthub/features/post/presentation/views/edit_post_view.dart';
import 'package:connecthub/features/post/presentation/widgets/delete_post_dialog.dart';
import 'package:connecthub/features/post/presentation/manager/cubit/post_action_cubit.dart';
import 'package:connecthub/features/chat/presentation/manager/cubit/conversations_cubit.dart';
import 'package:connecthub/features/chat/presentation/manager/cubit/conversations_state.dart';
import 'package:connecthub/features/chat/presentation/views/conversations_view.dart';
import 'package:connecthub/features/chat/data/repos/chat_repo_imp.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  int _currentIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _FeedPage(),
      const SearchView(),
      const ConversationsView(),
      const NotificationView(),
      const ProfileView(),
    ];

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.read<PostsCubit>().loadPosts();
          context.read<NotificationCubit>().listenToNotifications(state.user.uid);
          context.read<ConversationsCubit>().listenToConversations(state.user.uid);
          ChatRepoImp().setPresence(state.user.uid, true);
        }
      },
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: KeyedSubtree(
            key: ValueKey(_currentIndex),
            child: pages[_currentIndex],
          ),
        ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostView()),
                );
              },
              backgroundColor: AppColors.primary,
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Feed',
                  isSelected: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.search_rounded,
                  label: 'Search',
                  isSelected: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                _MessagesNavItem(
                  isSelected: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _NotificationNavItem(
                  isSelected: _currentIndex == 3,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: _currentIndex == 4,
                  onTap: () => setState(() => _currentIndex = 4),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.primary : AppColors.textHint,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Notification nav item with an animated badge for unread count.
class _NotificationNavItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _NotificationNavItem({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                final unread = state is NotificationLoaded
                    ? state.unreadCount
                    : 0;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_rounded,
                      size: 24,
                      color:
                          isSelected ? AppColors.primary : AppColors.textHint,
                    ),
                    if (unread > 0)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                'Alerts',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Messages nav item with an animated badge for unread message count.
class _MessagesNavItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _MessagesNavItem({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            BlocBuilder<ConversationsCubit, ConversationsState>(
              builder: (context, state) {
                final unread = state is ConversationsLoaded
                    ? state.all.fold<int>(
                        0,
                        (sum, c) => sum + c.myUnreadCount(
                          FirebaseAuth.instance.currentUser?.uid ?? '',
                        ),
                      )
                    : 0;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.chat_bubble_rounded,
                      size: 24,
                      color:
                          isSelected ? AppColors.primary : AppColors.textHint,
                    ),
                    if (unread > 0)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                'Messages',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FeedPage extends StatelessWidget {
  const _FeedPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.hub_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Text('ConnectHub', style: AppTextStyles.headline2),
                const Spacer(),
                // AI Assistant shortcut
                Tooltip(
                  message: 'AI Assistant',
                  child: Hero(
                    tag: 'ai_chat_fab',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Scaffold(
                              backgroundColor: AppColors.background,
                              body: const ChatbotView(),
                            ),
                          ),
                        ),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C4DFF), Color(0xFFE040FB)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<PostsCubit, PostsState>(
              builder: (context, state) {
                if (state is PostsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }
                if (state is PostsError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppColors.textHint),
                        const SizedBox(height: 12),
                        Text(state.message, style: AppTextStyles.body2),
                      ],
                    ),
                  );
                }
                if (state is PostsLoaded) {
                  if (state.posts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.article_outlined,
                              size: 64,
                              color: AppColors.textHint.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text('No posts yet',
                              style: AppTextStyles.headline3
                                  .copyWith(color: AppColors.textHint)),
                          const SizedBox(height: 8),
                          Text('Be the first to share something!',
                              style: AppTextStyles.body2),
                        ],
                      ),
                    );
                  }
                  final currentUserId =
                      FirebaseAuth.instance.currentUser?.uid ?? '';
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<PostsCubit>().loadPosts();
                    },
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: state.posts.length,
                      itemBuilder: (context, index) {
                        final post = state.posts[index];
                        final isOwn = post.userId == currentUserId;
                        return PostCard(
                          post: post,
                          isOwnPost: isOwn,
                          onLike: () {
                            context
                                .read<PostsCubit>()
                                .toggleLike(post.id, currentUserId);
                          },
                          onComment: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PostDetailsView(postId: post.id),
                              ),
                            );
                          },
                          onEdit: isOwn
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditPostView(
                                        postId: post.id,
                                        initialTitle: post.title,
                                        initialDescription: post.description,
                                        initialImageUrl: post.imageUrl,
                                        initialDeleteHash: post.deleteHash,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          onDelete: isOwn
                              ? () {
                                  DeletePostDialog.show(
                                    context,
                                    description: post.description,
                                    onConfirm: () async {
                                      final cubit = PostActionCubit();
                                      try {
                                        await cubit.deletePost(
                                          postId: post.id,
                                          deleteHash: post.deleteHash,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                  'Post deleted successfully!'),
                                              backgroundColor:
                                                  AppColors.success,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString()),
                                              backgroundColor: AppColors.error,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  );
                                }
                              : null,
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
