import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/search/presentation/manager/cubit/search_cubit.dart';
import 'package:connecthub/features/search/presentation/manager/cubit/search_state.dart';
import 'package:connecthub/features/search/presentation/widgets/search_post_results.dart';
import 'package:connecthub/features/search/presentation/widgets/search_shimmer_list.dart';
import 'package:connecthub/features/search/presentation/widgets/search_tab_pill.dart';
import 'package:connecthub/features/search/presentation/widgets/search_user_results.dart';

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
            body: DarkGlassBackground(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header & Search Input
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      child: Row(
                        children: [
                          if (Navigator.canPop(context)) ...[
                            AppIconButton(
                              icon: Icons.arrow_back_ios_new,
                              size: 16,
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.glassBorder, width: 0.8),
                              ),
                              child: TextField(
                                controller: _controller,
                                autofocus: true,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                                onChanged: (value) =>
                                    context.read<SearchCubit>().search(value),
                                decoration: InputDecoration(
                                  hintText: 'Search people or posts...',
                                  hintStyle: AppTextStyles.body2.copyWith(
                                    color: AppColors.textHint,
                                    fontSize: 13.5,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    color: AppColors.textHint,
                                    size: 19,
                                  ),
                                  suffixIcon: _controller.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.close_rounded,
                                            color: AppColors.textHint,
                                            size: 17,
                                          ),
                                          onPressed: () {
                                            _controller.clear();
                                            context.read<SearchCubit>().clear();
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tab pills
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          SearchTabPill(
                            label: 'People',
                            isSelected: _tabIndex == 0,
                            onTap: () => setState(() => _tabIndex = 0),
                          ),
                          const SizedBox(width: 8),
                          SearchTabPill(
                            label: 'Posts',
                            isSelected: _tabIndex == 1,
                            onTap: () => setState(() => _tabIndex = 1),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Results
                    Expanded(
                      child: BlocBuilder<SearchCubit, SearchState>(
                        builder: (context, state) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _buildBody(context, state),
                          );
                        },
                      ),
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

  Widget _buildBody(BuildContext context, SearchState state) {
    if (state is SearchInitial) {
      return Center(
        key: const ValueKey('initial'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.glass,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.glassBorder),
              ),
              child: Icon(
                Icons.search_rounded,
                color: AppColors.textHint,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Search ConnectHub',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Find people by name or search post content',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      );
    }

    if (state is SearchLoading) {
      if (_tabIndex == 1) {
        return ListView.builder(
          key: const ValueKey('posts_shimmer_loading'),
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: 4,
          itemBuilder: (context, index) => const PostCardShimmer(),
        );
      }
      return const SearchShimmerList(key: ValueKey('loading'));
    }

    if (state is SearchError) {
      return Center(
        key: const ValueKey('error'),
        child: Text(state.message, style: AppTextStyles.body2),
      );
    }

    if (state is SearchLoaded) {
      if (_tabIndex == 0) {
        return SearchUserResults(
          key: const ValueKey('users'),
          users: state.users,
        );
      } else {
        return SearchPostResults(
          key: const ValueKey('posts'),
          posts: state.posts,
        );
      }
    }

    return const SizedBox.shrink(key: ValueKey('empty'));
  }
}
