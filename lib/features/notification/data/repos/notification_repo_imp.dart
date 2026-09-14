import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/features/notification/data/models/notification_model.dart';
import 'package:connecthub/features/notification/data/repos/notification_repo.dart';
import 'package:uuid/uuid.dart';

class NotificationRepoImp implements NotificationRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _notificationsRef(String userId) =>
      _firestore.collection('users').doc(userId).collection('notifications');

  @override
  Future<void> createNotification(NotificationModel notification) async {
    // Self-notification guard — should also be enforced at call sites.
    if (notification.senderId == notification.receiverId) return;

    final id = const Uuid().v4();
    await _notificationsRef(notification.receiverId).doc(id).set({
      ...notification.toMap(),
      'id': id,
    });
  }

  @override
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _notificationsRef(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map(NotificationModel.fromDoc).toList());
  }

  @override
  Future<void> markAsRead(String userId, String notificationId) async {
    await _notificationsRef(userId).doc(notificationId).update({
      'isRead': true,
    });
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notificationsRef(userId)
        .where('isRead', isEqualTo: false)
        .get();

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> deleteNotification(
      String userId, String notificationId) async {
    await _notificationsRef(userId).doc(notificationId).delete();
  }

  @override
  Stream<int> getUnreadCountStream(String userId) {
    return _notificationsRef(userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}
