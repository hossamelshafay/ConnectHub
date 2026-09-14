import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_cubit.dart';
import 'package:connecthub/features/home/presentation/widgets/post_card.dart';
import 'package:connecthub/features/post/presentation/views/post_details_view.dart';
import 'package:connecthub/features/search/presentation/manager/cubit/search_cubit.dart';
import 'package:connecthub/features/search/presentation/manager/cubit/search_state.dart';
import 'package:connecthub/features/search/presentation/widgets/user_search_tile.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _controller = TextEditingController();
  int _tabIndex = 0; // 0 = Users, 1 = Posts

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SearchCubit(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Text('Search', style: AppTextStyles.headline2),
                  ),

                  // ── Search field ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BlocBuilder<SearchCubit, SearchState>(
                      builder: (context, state) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: TextField(
                            controller: _controller,
                            style: AppTextStyles.body1,
                            onChanged: (value) =>
                                context.read<SearchCubit>().search(value),
                            decoration: InputDecoration(
                              hintText: 'Search users or posts...',
                              hintStyle: AppTextStyles.body2
                                  .copyWith(color: AppColors.textHint),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.textHint,
                                size: 22,
                              ),
                              suffixIcon: _controller.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: AppColors.textHint,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _controller.clear();
                                        context.read<SearchCubit>().clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              filled: false,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Tab pills ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _TabPill(
                          label: 'Users',
                          isSelected: _tabIndex == 0,
                          onTap: () => setState(() => _tabIndex = 0),
                        ),
                        const SizedBox(width: 10),
                        _TabPill(
                          label: 'Posts',
                          isSelected: _tabIndex == 1,
                          onTap: () => setState(() => _tabIndex = 1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Results ──────────────────────────────────────────────
                  Expanded(
                    child: BlocBuilder<SearchCubit, SearchState>(
                      builder: (context, state) {
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _buildBody(context, state),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, SearchState state) {
    if (state is SearchInitial) {
      return _Placeholder(
        key: const ValueKey('initial'),
        icon: Icons.search_rounded,
        message: 'Start typing to search...',
      );
    }

    if (state is SearchLoading) {
      return _ShimmerList(key: const ValueKey('loading'));
    }

    if (state is SearchError) {
      return _Placeholder(
        key: const ValueKey('error'),
        icon: Icons.error_outline_rounded,
        message: state.message,
      );
    }

    if (state is SearchLoaded) {
      if (_tabIndex == 0) {
        return _UserResults(
          key: const ValueKey('users'),
          users: state.users,
        );
      } else {
        return _PostResults(
          key: const ValueKey('posts'),
          posts: state.posts,
        );
      }
    }

    return const SizedBox.shrink(key: ValueKey('empty'));
  }
}

// ---------------------------------------------------------------------------
// Tab pill
// ---------------------------------------------------------------------------

class _TabPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// User results
// ---------------------------------------------------------------------------

class _UserResults extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  const _UserResults({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return _Placeholder(
        icon: Icons.person_search_rounded,
        message: 'No users found.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: users.length,
      separatorBuilder: (context, index) => const Divider(
        color: AppColors.divider,
        height: 1,
        indent: 78,
      ),
      itemBuilder: (context, index) =>
          UserSearchTile(user: users[index]),
    );
  }
}

// ---------------------------------------------------------------------------
// Post results
// ---------------------------------------------------------------------------

class _PostResults extends StatelessWidget {
  final List posts;

  const _PostResults({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return _Placeholder(
        icon: Icons.article_outlined,
        message: 'No posts found.',
      );
    }

    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? '';

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostCard(
          post: post,
          isOwnPost: post.userId == currentUserId,
          onLike: () =>
              context.read<PostsCubit>().toggleLike(post.id, currentUserId),
          onComment: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PostDetailsView(postId: post.id),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer loading list
// ---------------------------------------------------------------------------

class _ShimmerList extends StatelessWidget {
  const _ShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Row(
        children: [
          ShimmerBox(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                ShimmerBox(width: 120, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Placeholder (initial / empty / error)
// ---------------------------------------------------------------------------

class _Placeholder extends StatelessWidget {
  final IconData icon;
  final String message;

  const _Placeholder({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppColors.textHint.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.body2.copyWith(color: AppColors.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
