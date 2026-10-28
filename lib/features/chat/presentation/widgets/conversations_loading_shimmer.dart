import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_widgets.dart';

class ConversationsLoadingShimmer extends StatelessWidget {
  final int itemCount;

  const ConversationsLoadingShimmer({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ChatTileShimmer(itemCount: itemCount);
  }
}
