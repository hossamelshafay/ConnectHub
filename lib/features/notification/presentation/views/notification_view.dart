import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connecthub/core/utils/app_theme.dart';
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
  void initState() {
    super.initState();
    // Mark all as read once the screen is visible.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null && mounted) {
        context.read<NotificationCubit>().markAllAsRead(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Text('Notifications', style: AppTextStyles.headline2),
            ),

            // Content
            Expanded(
              child: BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (state is NotificationError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
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
                      return _EmptyState();
                    }
                    return _NotificationList(
                      notifications: state.notifications,
                      onTap: _handleTap,
                    );
                  }

                  // NotificationInitial
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
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
              builder: (_) =>
                  PostDetailsView(postId: notification.postId!),
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

// ---------------------------------------------------------------------------
// Grouped list
// ---------------------------------------------------------------------------

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
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      children: [
        if (today.isNotEmpty) ...[
          _SectionHeader(label: 'Today'),
          ...today.map((n) => NotificationItem(
                notification: n,
                onTap: () => onTap(context, n),
              )),
        ],
        if (yesterday.isNotEmpty) ...[
          _SectionHeader(label: 'Yesterday'),
          ...yesterday.map((n) => NotificationItem(
                notification: n,
                onTap: () => onTap(context, n),
              )),
        ],
        if (earlier.isNotEmpty) ...[
          _SectionHeader(label: 'Earlier'),
          ...earlier.map((n) => NotificationItem(
                notification: n,
                onTap: () => onTap(context, n),
              )),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(
        label,
        style: AppTextStyles.body2.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textHint,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 72,
            color: AppColors.textHint.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: AppTextStyles.headline3.copyWith(
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When someone likes or comments on\nyour posts, you\'ll see it here.',
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
