import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/notification/data/repos/notification_repo.dart';
import 'package:connecthub/features/notification/data/repos/notification_repo_imp.dart';
import 'package:connecthub/features/notification/presentation/manager/cubit/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepo _repo;
  StreamSubscription? _subscription;

  NotificationCubit({NotificationRepo? repo})
      : _repo = repo ?? NotificationRepoImp(),
        super(NotificationInitial());

  /// Starts a real-time stream of notifications for [userId].
  /// Safe to call multiple times — cancels the previous subscription first.
  void listenToNotifications(String userId) {
    emit(NotificationLoading());
    _subscription?.cancel();
    _subscription = _repo.getNotificationsStream(userId).listen(
      (notifications) {
        final unreadCount = notifications.where((n) => !n.isRead).length;
        emit(NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ));
      },
      onError: (_) {
        emit(NotificationError('Failed to load notifications.'));
      },
    );
  }

  /// Marks a single notification as read.
  Future<void> markAsRead(String userId, String notificationId) async {
    await _repo.markAsRead(userId, notificationId);
  }

  /// Marks all unread notifications as read.
  Future<void> markAllAsRead(String userId) async {
    await _repo.markAllAsRead(userId);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
