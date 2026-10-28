import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/features/notification/data/models/notification_model.dart';
import 'package:connecthub/features/notification/presentation/manager/cubit/notification_cubit.dart';
import 'package:connecthub/features/notification/presentation/manager/cubit/notification_state.dart';
import 'package:connecthub/features/notification/presentation/widgets/notification_item.dart';
import 'package:connecthub/features/post/presentation/views/post_details_view.dart';
import 'package:connecthub/core/utils/profile_navigation_helper.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Navigator.canPop(context)
            ? Center(
                child: AppIconButton(
                  icon: Icons.arrow_back_ios_new,
                  size: 18,
                  onPressed: () => Navigator.pop(context),
                ),
              )
            : null,
        title: Text('Notifications', style: AppTextStyles.headline3),
        centerTitle: true,
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              final unread =
                  state is NotificationLoaded ? state.unreadCount : 0;
              if (unread == 0) return const SizedBox.shrink();

              return TextButton(
                onPressed: () {
                  if (currentUserId != null) {
                    context.read<NotificationCubit>().markAllAsRead(currentUserId);
                  }
                },
                child: Text(
                  'Mark all read',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: DarkGlassBackground(
        child: SafeArea(
          child: BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoading) {
                return const NotificationTileShimmer(itemCount: 7);
              }

              if (state is NotificationError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: 12),
                      Text(state.message, style: AppTextStyles.body2),
                    ],
                  ),
                );
              }

              if (state is NotificationLoaded) {
                if (state.notifications.isEmpty) {
                  return Center(
                    child: EmptyStateWidget(
                      icon: Icons.notifications_none_rounded,
                      title: 'No notifications',
                      subtitle:
                          'When someone interacts with your posts or profile, you\'ll see it here.',
                    ),
                  );
                }
                return _NotificationList(
                  notifications: state.notifications,
                  onTap: _handleTap,
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, NotificationModel notification) {
    switch (notification.type) {
      case NotificationType.like:
      case NotificationType.comment:
      case NotificationType.mention:
        if (notification.postId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailsView(postId: notification.postId!),
            ),
          );
        }
        break;
      case NotificationType.follow:
        ProfileNavigationHelper.openUserProfile(
          context,
          userId: notification.senderId,
          userName: notification.senderName,
        );
        break;
    }
  }
}

class _NotificationList extends StatelessWidget {
  final List<NotificationModel> notifications;
  final void Function(BuildContext context, NotificationModel notification) onTap;

  const _NotificationList({
    required this.notifications,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));

    final today = notifications
        .where((n) => n.createdAt.isAfter(todayStart))
        .toList();
    final yesterday = notifications
        .where((n) =>
            n.createdAt.isAfter(yesterdayStart) &&
            !n.createdAt.isAfter(todayStart))
        .toList();
    final earlier = notifications
        .where((n) => !n.createdAt.isAfter(yesterdayStart))
        .toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        if (today.isNotEmpty) ...[
          const SectionHeader(title: 'Today'),
          ...today.map((n) => NotificationItem(
                notification: n,
                onTap: () => onTap(context, n),
              )),
        ],
        if (yesterday.isNotEmpty) ...[
          const SectionHeader(title: 'Yesterday'),
          ...yesterday.map((n) => NotificationItem(
                notification: n,
                onTap: () => onTap(context, n),
              )),
        ],
        if (earlier.isNotEmpty) ...[
          const SectionHeader(title: 'Earlier'),
          ...earlier.map((n) => NotificationItem(
                notification: n,
                onTap: () => onTap(context, n),
              )),
        ],
      ],
    );
  }
}
