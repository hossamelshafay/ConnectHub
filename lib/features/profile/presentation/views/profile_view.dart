import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/theme/theme_cubit.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/auth/presentation/widgets/manage_accounts_bottom_sheet.dart';
import 'package:connecthub/features/home/data/models/post_model.dart';
import 'package:connecthub/features/home/presentation/manager/cubit/posts_cubit.dart';
import 'package:connecthub/features/home/presentation/widgets/post_card.dart';
import 'package:connecthub/features/post/presentation/views/post_details_view.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_cubit.dart';
import 'package:connecthub/features/profile/presentation/manager/cubit/profile_state.dart';
import 'package:connecthub/features/profile/presentation/views/edit_profile_view.dart';
import 'package:connecthub/features/profile/presentation/views/followers_view.dart';
import 'package:connecthub/features/profile/presentation/views/following_view.dart';
import 'package:connecthub/features/profile/presentation/views/liked_posts_view.dart';
import 'package:connecthub/features/profile/presentation/widgets/profile_card.dart';
import 'package:connecthub/features/profile/presentation/widgets/profile_posts_list.dart';
import 'package:connecthub/features/settings/presentation/views/settings_view.dart';

class ProfileView extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback? onSwitchToPortfolio;

  const ProfileView({
    super.key,
    this.showBackButton = false,
    this.onSwitchToPortfolio,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..loadProfile(),
      child: _ProfileViewBody(
        showBackButton: showBackButton,
        onSwitchToPortfolio: onSwitchToPortfolio,
      ),
    );
  }
}

class _ProfileViewBody extends StatefulWidget {
  final bool showBackButton;
  final VoidCallback? onSwitchToPortfolio;

  const _ProfileViewBody({
    this.showBackButton = false,
    this.onSwitchToPortfolio,
  });

  @override
  State<_ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<_ProfileViewBody> {
  int _selectedTab = 0; // 0: Posts, 1: Liked

  void _showMoreMenu(BuildContext context, ProfileCubit cubit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.textHint.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.edit_outlined, color: AppColors.textPrimary),
                title: Text('Edit Profile', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: const EditProfileView(),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.switch_account_outlined, color: AppColors.textPrimary),
                title: Text('Manage Accounts', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  ManageAccountsBottomSheet.show(context);
                },
              ),
              if (widget.onSwitchToPortfolio != null)
                ListTile(
                  leading: Icon(Icons.work_outline_rounded, color: AppColors.primary),
                  title: Text('Switch to Portfolio', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    widget.onSwitchToPortfolio!();
                  },
                ),
              ListTile(
                leading: Icon(Icons.settings_outlined, color: AppColors.textPrimary),
                title: Text('Settings', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsView()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canGoBack = widget.showBackButton || Navigator.canPop(context);

    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: canGoBack
                ? Center(
                    child: AppIconButton(
                      icon: Icons.arrow_back_ios_new,
                      size: 18,
                      onPressed: () => Navigator.pop(context),
                    ),
                  )
                : null,
            title: Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
            actions: [
              const AnimatedThemeToggle(),
              IconButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  size: 22,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => _showMoreMenu(context, context.read<ProfileCubit>()),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: DarkGlassBackground(
            child: SafeArea(
              child: BlocBuilder<ProfileCubit, ProfileState>(
                buildWhen: (previous, current) =>
                    current is ProfileLoaded ||
                    current is ProfileLoading ||
                    current is ProfileError,
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return const ProfileHeaderShimmer(includePosts: true);
                  }

                  if (state is ProfileError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              style: AppTextStyles.body2,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            SecondaryButton(
                              text: 'Try Again',
                              width: 130,
                              onPressed: () =>
                                  context.read<ProfileCubit>().loadProfile(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is ProfileLoaded) {
                    final cubit = context.read<ProfileCubit>();

                    return RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.surfaceVariant,
                      onRefresh: () async {
                        cubit.loadProfile();
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.only(bottom: 32),
                        children: [
                          // ── Redesigned Profile Header Card ───────────
                          ProfileCard(
                            user: state.user,
                            displayName: state.displayName,
                            username: state.username,
                            headline: state.headline,
                            location: state.location,
                            bio: state.bio,
                            socialLinks: state.socialLinks,
                            profileImage: state.profileImage,
                            joinedDate: state.joinedDate,
                            postCount: state.userPosts.length,
                            totalLikes: state.totalLikes,
                            followersCount: state.followersCount,
                            followingCount: state.followingCount,
                            websiteGenerated:
                                (state.userData?['websiteGenerated'] as bool?) ??
                                    false,
                            websiteUrl:
                                state.userData?['websiteUrl'] as String?,
                            selectedTabIndex: _selectedTab,
                            onTabChanged: (idx) {
                              setState(() => _selectedTab = idx);
                            },
                            onEditProfile: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: cubit,
                                    child: const EditProfileView(),
                                  ),
                                ),
                              );
                            },
                            onLikedPosts: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: cubit,
                                    child: const LikedPostsView(),
                                  ),
                                ),
                              );
                            },
                            onFollowersTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: cubit,
                                    child: const FollowersView(),
                                  ),
                                ),
                              );
                            },
                            onFollowingTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: cubit,
                                    child: const FollowingView(),
                                  ),
                                ),
                              );
                            },
                            onSwitchToPortfolio: widget.onSwitchToPortfolio,
                          ),

                          const SizedBox(height: 12),

                          // ── Feed View Based on Selected Tab ──────────
                          if (_selectedTab == 0) ...[
                            // User Posts List
                            ProfilePostsList(
                              posts: state.userPosts,
                              userName: state.displayName,
                              userPhoto: state.profileImage,
                            ),
                          ] else ...[
                            // Liked Posts Stream
                            StreamBuilder<List<PostModel>>(
                              stream: cubit.getLikedPostsStream(state.user.uid),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: Column(
                                      children: [
                                        PostShimmerCard(),
                                        SizedBox(height: 10),
                                        PostShimmerCard(),
                                      ],
                                    ),
                                  );
                                }

                                final posts = snapshot.data ?? [];
                                if (posts.isEmpty) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 24,
                                    ),
                                    child: Center(
                                      child: EmptyStateWidget(
                                        icon: Icons.favorite_border_rounded,
                                        title: 'No liked posts yet',
                                        subtitle:
                                            'Posts you like will appear here.',
                                      ),
                                    ),
                                  );
                                }

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: posts.length,
                                    itemBuilder: (context, index) {
                                      final post = posts[index];
                                      return PostCard(
                                        post: post,
                                        isOwnPost: post.userId == state.user.uid,
                                        onLike: () {
                                          context
                                              .read<PostsCubit>()
                                              .toggleLike(post.id, state.user.uid);
                                        },
                                        onComment: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PostDetailsView(
                                                  postId: post.id),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
