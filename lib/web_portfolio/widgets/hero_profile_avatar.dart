import 'package:flutter/material.dart';
import 'package:connecthub/core/widgets/user_avatar.dart';
import '../theme/web_colors.dart';

/// Circular profile avatar with crisp metallic border and active status dot.
class HeroProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool isDark;

  const HeroProfileAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 280,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = size;

    return Center(
      child: SizedBox(
        width: avatarSize,
        height: avatarSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Ambient soft glow behind avatar
            Container(
              width: avatarSize * 0.9,
              height: avatarSize * 0.9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? WebColors.darkPrimary : WebColors.lightPrimary)
                        .withValues(alpha: 0.15),
                    blurRadius: 36,
                    spreadRadius: 6,
                  ),
                ],
              ),
            ),

            // Profile Picture Container with Crisp Circular Border
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? const Color(0x66FFFFFF)
                      : const Color(0xFFFFFFFF),
                  width: 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: UserAvatar(
                name: name,
                size: avatarSize,
                imageUrl: imageUrl,
              ),
            ),

            // Active Green Status Indicator Dot at bottom right
            Positioned(
              right: avatarSize * 0.05,
              bottom: avatarSize * 0.05,
              child: Container(
                width: (avatarSize * 0.12).clamp(16.0, 22.0),
                height: (avatarSize * 0.12).clamp(16.0, 22.0),
                decoration: BoxDecoration(
                  color: WebColors.emeraldAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? WebColors.darkBackground : Colors.white,
                    width: 2.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: WebColors.emeraldAccent.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
