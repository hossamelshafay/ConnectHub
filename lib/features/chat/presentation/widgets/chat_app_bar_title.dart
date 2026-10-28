import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';
import 'package:connecthub/core/utils/profile_navigation_helper.dart';

class ChatAppBarTitle extends StatelessWidget {
  final String peerId;
  final String peerName;
  final String? peerPhoto;
  final Stream<Map<String, dynamic>> presenceStream;

  const ChatAppBarTitle({
    super.key,
    required this.peerId,
    required this.peerName,
    this.peerPhoto,
    required this.presenceStream,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => ProfileNavigationHelper.openUserProfile(
        context,
        userId: peerId,
        userName: peerName,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            UserAvatarById(
              userId: peerId,
              fallbackName: peerName,
              size: 38,
              fallbackImageUrl: peerPhoto,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: StreamBuilder<Map<String, dynamic>>(
                stream: presenceStream,
                builder: (context, snap) {
                  final data = snap.data ?? {};
                  final isOnline = data['isOnline'] as bool? ?? false;
                  final lastSeenTs = data['lastSeen'];
                  String subtitle;
                  if (isOnline) {
                    subtitle = 'Online';
                  } else if (lastSeenTs != null) {
                    final dt = lastSeenTs is Timestamp
                        ? lastSeenTs.toDate()
                        : DateTime.now();
                    subtitle = 'Last seen ${_formatLastSeen(dt)}';
                  } else {
                    subtitle = '';
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        peerName,
                        style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isOnline)
                              Container(
                                width: 7,
                                height: 7,
                                margin: const EdgeInsets.only(right: 4),
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            Text(
                              subtitle,
                              style: AppTextStyles.caption.copyWith(
                                color: isOnline
                                    ? AppColors.success
                                    : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(dt);
  }
}
