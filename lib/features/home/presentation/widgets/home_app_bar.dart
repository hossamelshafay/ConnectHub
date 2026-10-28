import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/notification/presentation/manager/cubit/notification_cubit.dart';
import 'package:connecthub/features/notification/presentation/manager/cubit/notification_state.dart';
import 'package:connecthub/features/notification/presentation/views/notification_view.dart';
import 'package:connecthub/features/chat/presentation/manager/cubit/conversations_cubit.dart';
import 'package:connecthub/features/chat/presentation/manager/cubit/conversations_state.dart';
import 'package:connecthub/features/chat/presentation/views/conversations_view.dart';
import 'package:connecthub/features/profile/presentation/views/profile_router.dart';
import 'package:connecthub/features/search/presentation/views/search_view.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentUserId;

  const HomeAppBar({
    super.key,
    required this.currentUserId,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: AppIconButton(
            icon: Icons.search_rounded,
            size: 20,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchView()),
              );
            },
          ),
        ),
      ),
      title: Text(
        'ConnectHub',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        // Notifications with badge
        BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            final unread =
                state is NotificationLoaded ? state.unreadCount : 0;
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AppIconButton(
                      icon: Icons.notifications_none_rounded,
                      size: 20,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationView(),
                          ),
                        );
                      },
                    ),
                    if (unread > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 15,
                            minHeight: 15,
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        // Messages with badge
        BlocBuilder<ConversationsCubit, ConversationsState>(
          builder: (context, state) {
            final unread = state is ConversationsLoaded
                ? state.all.fold<int>(
                    0,
                    (sum, c) => sum + c.myUnreadCount(currentUserId),
                  )
                : 0;
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AppIconButton(
                      icon: Icons.chat_bubble_outline_rounded,
                      size: 19,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ConversationsView(),
                          ),
                        );
                      },
                    ),
                    if (unread > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 15,
                            minHeight: 15,
                          ),
                          child: Text(
                            unread > 99 ? '99+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              height: 1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        // User Avatar -> Profile
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileRouter(
                      userId: currentUserId,
                      showBackButton: true,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 1.5,
                  ),
                ),
                child: UserAvatarById(
                  userId: currentUserId,
                  fallbackName:
                      FirebaseAuth.instance.currentUser?.displayName ?? 'Me',
                  size: 34,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
