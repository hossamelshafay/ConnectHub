import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../theme/web_text_styles.dart';

/// Premium animated circular profile avatar with glowing outer rings,
/// subtle dual-color gradients (Teal & Bronze), and an "Available for work" badge.
class HeroProfileAvatar extends StatefulWidget {
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
  State<HeroProfileAvatar> createState() => _HeroProfileAvatarState();
}

class _HeroProfileAvatarState extends State<HeroProfileAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final avatarSize = widget.size;
    final imageInnerSize = avatarSize - 28;

    return Center(
      child: SizedBox(
        width: avatarSize + 24,
        height: avatarSize + 24,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Subtle ambient gold glow behind avatar
            Container(
              width: avatarSize * 0.85,
              height: avatarSize * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: WebColors.primary.withValues(alpha: 0.20),
                    blurRadius: 60,
                    spreadRadius: 12,
                  ),
                  BoxShadow(
                    color: WebColors.primaryLight.withValues(alpha: 0.10),
                    blurRadius: 40,
                    spreadRadius: 6,
                  ),
                ],
              ),
            ),

            // Animated rotating gold gradient ring
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [
                          WebColors.primaryDark,
                          WebColors.primary,
                          WebColors.primaryLight,
                          Color(0xFFFFF3C4),
                          WebColors.primaryLight,
                          WebColors.primary,
                          WebColors.primaryDark,
                        ],
                        stops: [0.0, 0.15, 0.35, 0.5, 0.65, 0.85, 1.0],
                      ),
                    ),
                  ),
                );
              },
            ),

            // Inner dark gap to create ring effect
            Container(
              width: avatarSize - 6,
              height: avatarSize - 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: WebColors.background,
              ),
            ),

            // Profile Picture Container with Border
            Container(
              width: imageInnerSize,
              height: imageInnerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: WebColors.border,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildImage(imageInnerSize),
              ),
            ),

            // Floating "Available for work" Status Pill at bottom right
            Positioned(
              bottom: 4,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: (widget.isDark ? WebColors.surfaceElevated : Colors.white)
                      .withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: WebColors.border,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: WebColors.emeraldAccent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: WebColors.emeraldAccent,
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Available for work',
                      style: WebTextStyles.bodySmall(isDark: widget.isDark).copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: widget.isDark ? WebColors.textPrimary : WebColors.lightTextPrimary,
                      ),
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

  Widget _buildImage(double size) {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.imageUrl!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        placeholder: (context, url) => Container(
          color: WebColors.surfaceElevated,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: WebColors.primaryLight,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallbackAvatar(size),
      );
    }
    return _buildFallbackAvatar(size);
  }

  Widget _buildFallbackAvatar(double size) {
    final initials = widget.name.isNotEmpty
        ? widget.name
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((part) => part.isNotEmpty ? part[0].toUpperCase() : '')
            .join()
        : 'HS';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            WebColors.surfaceCard,
            WebColors.surfaceElevated,
            WebColors.primary.withValues(alpha: 0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_rounded,
              size: 54,
              color: WebColors.textMuted,
            ),
            const SizedBox(height: 6),
            Text(
              initials,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: WebColors.primary.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
