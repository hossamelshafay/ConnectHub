import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/app_widgets.dart';

class SearchShimmerList extends StatelessWidget {
  final int itemCount;

  const SearchShimmerList({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: itemCount,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder, width: 0.8),
          ),
          child: Row(
            children: const [
              ShimmerBox.circle(size: 48),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 130, height: 14, borderRadius: 6),
                    SizedBox(height: 6),
                    ShimmerBox(width: 180, height: 12, borderRadius: 5),
                  ],
                ),
              ),
              SizedBox(width: 10),
              ShimmerBox(width: 60, height: 28, borderRadius: 14),
            ],
          ),
        ),
      ),
    );
  }
}
