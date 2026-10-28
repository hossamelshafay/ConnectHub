import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/widgets/shimmer_box.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UserAvatar — Universal Apple-style Avatar with Warm Titanium Fallback
// ─────────────────────────────────────────────────────────────────────────────
class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final String? imageUrl;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 44,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl?.trim();
    if (cleanUrl != null && cleanUrl.isNotEmpty) {
      // SizedBox enforces the exact square bounding box.
      // ClipOval then clips whatever is painted inside to a perfect circle.
      // CachedNetworkImage with explicit width+height+BoxFit.cover fills that
      // square completely, cropping the image from the center — no stretching,
      // no letterboxing, no black bars, regardless of the source image ratio.
      // We intentionally skip imageBuilder so that fit/width/height are
      // respected by the underlying OctoImage/RawImage pipeline.
      return SizedBox(
        width: size,
        height: size,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: cleanUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            placeholder: (_, _) => _buildShimmer(),
            errorWidget: (_, _, _) => _buildFallback(),
          ),
        ),
      );
    }
    return _buildFallback();
  }

  Widget _buildShimmer() {
    return ShimmerBox.circle(size: size);
  }

  Widget _buildFallback() {
    final trimmed = name.trim();
    final initial = trimmed.isNotEmpty ? trimmed[0].toUpperCase() : '?';
    final isDark = AppColors.isDark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF262320), Color(0xFF1B1917)]
              : const [Color(0xFFEFECE7), Color(0xFFE4DFD7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark ? const Color(0x22FFFFFF) : const Color(0xFFDDD7CF),
          width: size > 60 ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0x18000000)
                : const Color(0x06000000),
            blurRadius: 6,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontFamily: 'Inter',
            color: isDark ? const Color(0xFF94A3B8) : AppColors.primary,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UserAvatarById — Real-time Firestore stream
// ─────────────────────────────────────────────────────────────────────────────
class UserAvatarById extends StatelessWidget {
  final String userId;
  final String fallbackName;
  final double size;
  final String? fallbackImageUrl;

  const UserAvatarById({
    super.key,
    required this.userId,
    required this.fallbackName,
    this.size = 44,
    this.fallbackImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return UserAvatar(
        name: fallbackName,
        size: size,
        imageUrl: fallbackImageUrl,
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots(),
      builder: (context, snapshot) {
        String? imageUrl = fallbackImageUrl;
        String name = fallbackName;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          final img = data?['profileImage'] as String?;
          if (img != null && img.isNotEmpty) imageUrl = img;
          final n = data?['name'] as String?;
          if (n != null && n.isNotEmpty) name = n;
        }

        return UserAvatar(name: name, size: size, imageUrl: imageUrl);
      },
    );
  }
}
