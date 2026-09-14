import 'package:connecthub/features/notification/data/models/notification_model.dart';

abstract class NotificationRepo {
  /// Writes a notification to users/{receiverId}/notifications/{id}.
  Future<void> createNotification(NotificationModel notification);

  /// Real-time stream of notifications for [userId], ordered by createdAt desc.
  Stream<List<NotificationModel>> getNotificationsStream(String userId);

  /// Marks a single notification as read.
  Future<void> markAsRead(String userId, String notificationId);

  /// Marks all unread notifications as read via a batch write.
  Future<void> markAllAsRead(String userId);

  /// Deletes a notification document (optional helper).
  Future<void> deleteNotification(String userId, String notificationId);

  /// Real-time stream of the unread notification count for [userId].
  Stream<int> getUnreadCountStream(String userId);
}
