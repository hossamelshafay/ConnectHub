import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/widgets/shimmer_box.dart';
import 'package:connecthub/core/widgets/shimmers/app_shimmer.dart';

/// Reusable Chat Message Bubbles Shimmer for chat conversations.
class ChatMessageShimmer extends StatelessWidget {
  final int count;

  const ChatMessageShimmer({
    super.key,
    this.count = 6,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        itemBuilder: (context, index) {
          final isMe = index % 2 == 1;
          final width = (index % 3 == 0) ? 220.0 : ((index % 3 == 1) ? 160.0 : 250.0);
          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primarySoft
                    : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                border: Border.all(color: AppColors.glassBorder, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: width, height: 13, borderRadius: 5),
                  if (index % 3 != 1) ...[
                    const SizedBox(height: 6),
                    ShimmerBox(width: width * 0.65, height: 13, borderRadius: 5),
                  ],
                  const SizedBox(height: 6),
                  const ShimmerBox(width: 40, height: 9, borderRadius: 3),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
