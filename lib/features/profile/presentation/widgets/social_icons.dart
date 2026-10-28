import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Metadata definition for supported social platforms.
class SocialPlatformMeta {
  final String key;
  final String title;
  final String hint;
  final Widget Function(BuildContext context, {Color? color, double size}) iconBuilder;

  const SocialPlatformMeta({
    required this.key,
    required this.title,
    required this.hint,
    required this.iconBuilder,
  });
}

/// Registry of all supported social platforms and brand icons.
class SocialPlatformRegistry {
  SocialPlatformRegistry._();

  static final List<SocialPlatformMeta> all = [
    SocialPlatformMeta(
      key: 'github',
      title: 'GitHub',
      hint: 'https://github.com/username or @username',
      iconBuilder: (context, {color, size = 18}) => _CustomBrandIcon(
        type: _BrandType.github,
        size: size,
        color: color ?? AppColors.textPrimary,
      ),
    ),
    SocialPlatformMeta(
      key: 'linkedin',
      title: 'LinkedIn',
      hint: 'https://linkedin.com/in/username',
      iconBuilder: (context, {color, size = 18}) => _CustomBrandIcon(
        type: _BrandType.linkedin,
        size: size,
        color: color ?? AppColors.textPrimary,
      ),
    ),
    SocialPlatformMeta(
      key: 'website',
      title: 'Website',
      hint: 'https://yourwebsite.com',
      iconBuilder: (context, {color, size = 18}) => Icon(
        Icons.link_rounded,
        size: size,
        color: color ?? AppColors.textPrimary,
      ),
    ),
    SocialPlatformMeta(
      key: 'instagram',
      title: 'Instagram',
      hint: 'https://instagram.com/username or @username',
      iconBuilder: (context, {color, size = 18}) => _CustomBrandIcon(
        type: _BrandType.instagram,
        size: size,
        color: color ?? AppColors.textPrimary,
      ),
    ),
    SocialPlatformMeta(
      key: 'twitter',
      title: 'X (Twitter)',
      hint: 'https://x.com/username or @username',
      iconBuilder: (context, {color, size = 18}) => _CustomBrandIcon(
        type: _BrandType.twitter,
        size: size,
        color: color ?? AppColors.textPrimary,
      ),
    ),
    SocialPlatformMeta(
      key: 'facebook',
      title: 'Facebook',
      hint: 'https://facebook.com/username',
      iconBuilder: (context, {color, size = 18}) => _CustomBrandIcon(
        type: _BrandType.facebook,
        size: size,
        color: color ?? AppColors.textPrimary,
      ),
    ),
    SocialPlatformMeta(
      key: 'behance',
      title: 'Behance',
      hint: 'https://behance.net/username',
      iconBuilder: (context, {color, size = 18}) => _CustomBrandIcon(
        type: _BrandType.behance,
        size: size,
        color: color ?? AppColors.textPrimary,
      ),
    ),
    SocialPlatformMeta(
      key: 'dribbble',
      title: 'Dribbble',
      hint: 'https://dribbble.com/username',
      iconBuilder: (context, {color, size = 18}) => _CustomBrandIcon(
        type: _BrandType.dribbble,
        size: size,
        color: color ?? AppColors.textPrimary,
      ),
    ),
    SocialPlatformMeta(
      key: 'medium',
      title: 'Medium',
      hint: 'https://medium.com/@username',
      iconBuilder: (context, {color, size = 18}) => _CustomBrandIcon(
        type: _BrandType.medium,
        size: size,
        color: color ?? AppColors.textPrimary,
      ),
    ),
    SocialPlatformMeta(
      key: 'youtube',
      title: 'YouTube',
      hint: 'https://youtube.com/@channel',
      iconBuilder: (context, {color, size = 18}) => _CustomBrandIcon(
        type: _BrandType.youtube,
        size: size,
        color: color ?? AppColors.textPrimary,
      ),
    ),
    SocialPlatformMeta(
      key: 'tiktok',
      title: 'TikTok',
      hint: 'https://tiktok.com/@username',
      iconBuilder: (context, {color, size = 18}) => _CustomBrandIcon(
        type: _BrandType.tiktok,
        size: size,
        color: color ?? AppColors.textPrimary,
      ),
    ),
    SocialPlatformMeta(
      key: 'discord',
      title: 'Discord',
      hint: 'https://discord.gg/invite or username',
      iconBuilder: (context, {color, size = 18}) => _CustomBrandIcon(
        type: _BrandType.discord,
        size: size,
        color: color ?? AppColors.textPrimary,
      ),
    ),
    SocialPlatformMeta(
      key: 'telegram',
      title: 'Telegram',
      hint: 'https://t.me/username or @username',
      iconBuilder: (context, {color, size = 18}) => _CustomBrandIcon(
        type: _BrandType.telegram,
        size: size,
        color: color ?? AppColors.textPrimary,
      ),
    ),
  ];

  static SocialPlatformMeta get(String key) {
    final normalized = key.toLowerCase().trim();
    if (normalized == 'x') {
      return all.firstWhere((p) => p.key == 'twitter');
    }
    return all.firstWhere(
      (p) => p.key == normalized,
      orElse: () => SocialPlatformMeta(
        key: normalized,
        title: key,
        hint: 'https://...',
        iconBuilder: (context, {color, size = 18}) => Icon(
          Icons.link_rounded,
          size: size,
          color: color ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// Convenience class for rendering authentic vector social brand icons.
class SocialIcons {
  SocialIcons._();

  static Widget github({double size = 18, Color? color}) => _CustomBrandIcon(
        type: _BrandType.github,
        size: size,
        color: color ?? AppColors.textPrimary,
      );

  static Widget linkedin({double size = 18, Color? color}) => _CustomBrandIcon(
        type: _BrandType.linkedin,
        size: size,
        color: color ?? AppColors.textPrimary,
      );

  static Widget twitter({double size = 18, Color? color}) => _CustomBrandIcon(
        type: _BrandType.twitter,
        size: size,
        color: color ?? AppColors.textPrimary,
      );

  static Widget instagram({double size = 18, Color? color}) => _CustomBrandIcon(
        type: _BrandType.instagram,
        size: size,
        color: color ?? AppColors.textPrimary,
      );

  static Widget facebook({double size = 18, Color? color}) => _CustomBrandIcon(
        type: _BrandType.facebook,
        size: size,
        color: color ?? AppColors.textPrimary,
      );

  static Widget youtube({double size = 18, Color? color}) => _CustomBrandIcon(
        type: _BrandType.youtube,
        size: size,
        color: color ?? AppColors.textPrimary,
      );

  static Widget telegram({double size = 18, Color? color}) => _CustomBrandIcon(
        type: _BrandType.telegram,
        size: size,
        color: color ?? AppColors.textPrimary,
      );

  static Widget discord({double size = 18, Color? color}) => _CustomBrandIcon(
        type: _BrandType.discord,
        size: size,
        color: color ?? AppColors.textPrimary,
      );
}

enum _BrandType {
  github,
  linkedin,
  instagram,
  twitter,
  facebook,
  behance,
  dribbble,
  medium,
  youtube,
  tiktok,
  discord,
  telegram,
}

class _CustomBrandIcon extends StatelessWidget {
  final _BrandType type;
  final double size;
  final Color color;

  const _CustomBrandIcon({
    required this.type,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    switch (type) {
      case _BrandType.github:
        child = CustomPaint(
          size: Size(size, size),
          painter: _GithubPainter(color),
        );
        break;
      case _BrandType.linkedin:
        child = CustomPaint(
          size: Size(size, size),
          painter: _LinkedinPainter(color),
        );
        break;
      case _BrandType.instagram:
        child = CustomPaint(
          size: Size(size, size),
          painter: _InstagramPainter(color),
        );
        break;
      case _BrandType.twitter:
        child = CustomPaint(
          size: Size(size, size),
          painter: _TwitterXPainter(color),
        );
        break;
      case _BrandType.facebook:
        child = CustomPaint(
          size: Size(size, size),
          painter: _FacebookPainter(color),
        );
        break;
      case _BrandType.youtube:
        child = CustomPaint(
          size: Size(size, size),
          painter: _YoutubePainter(color),
        );
        break;
      case _BrandType.telegram:
        child = CustomPaint(
          size: Size(size, size),
          painter: _TelegramPainter(color),
        );
        break;
      case _BrandType.discord:
        child = CustomPaint(
          size: Size(size, size),
          painter: _DiscordPainter(color),
        );
        break;
      case _BrandType.medium:
        child = Icon(Icons.article_outlined, size: size, color: color);
        break;
      case _BrandType.behance:
        child = CustomPaint(
          size: Size(size, size),
          painter: _BehancePainter(color),
        );
        break;
      case _BrandType.dribbble:
        child = Icon(Icons.sports_basketball_outlined, size: size, color: color);
        break;
      case _BrandType.tiktok:
        child = Icon(Icons.music_note_rounded, size: size, color: color);
        break;
    }

    return SizedBox(
      width: size,
      height: size,
      child: Center(child: child),
    );
  }
}

class _GithubPainter extends CustomPainter {
  final Color color;
  _GithubPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(w * 0.500, h * 0.040);
    path.cubicTo(w * 0.224, h * 0.040, 0, h * 0.264, 0, h * 0.540);
    path.cubicTo(0, h * 0.761, w * 0.143, h * 0.948, w * 0.342, h * 1.014);
    path.cubicTo(w * 0.367, h * 1.019, w * 0.376, h * 1.003, w * 0.376, h * 0.990);
    path.cubicTo(w * 0.376, h * 0.978, w * 0.375, h * 0.938, w * 0.375, h * 0.887);
    path.cubicTo(w * 0.236, h * 0.917, w * 0.207, h * 0.827, w * 0.207, h * 0.827);
    path.cubicTo(w * 0.184, h * 0.769, w * 0.151, h * 0.753, w * 0.151, h * 0.753);
    path.cubicTo(w * 0.106, h * 0.722, w * 0.154, h * 0.723, w * 0.154, h * 0.723);
    path.cubicTo(w * 0.204, h * 0.726, w * 0.230, h * 0.774, w * 0.230, h * 0.774);
    path.cubicTo(w * 0.274, h * 0.849, w * 0.345, h * 0.827, w * 0.373, h * 0.815);
    path.cubicTo(w * 0.377, h * 0.783, w * 0.390, h * 0.761, w * 0.404, h * 0.749);
    path.cubicTo(w * 0.293, h * 0.736, w * 0.177, h * 0.693, w * 0.177, h * 0.501);
    path.cubicTo(w * 0.177, h * 0.446, w * 0.197, h * 0.401, w * 0.229, h * 0.366);
    path.cubicTo(w * 0.224, h * 0.353, w * 0.207, h * 0.299, w * 0.234, h * 0.230);
    path.cubicTo(w * 0.234, h * 0.230, w * 0.276, h * 0.217, w * 0.372, h * 0.282);
    path.cubicTo(w * 0.412, h * 0.271, w * 0.456, h * 0.265, w * 0.500, h * 0.265);
    path.cubicTo(w * 0.544, h * 0.265, w * 0.588, h * 0.271, w * 0.628, h * 0.282);
    path.cubicTo(w * 0.724, h * 0.217, w * 0.766, h * 0.230, w * 0.766, h * 0.230);
    path.cubicTo(w * 0.793, h * 0.299, w * 0.776, h * 0.353, w * 0.771, h * 0.366);
    path.cubicTo(w * 0.803, h * 0.401, w * 0.823, h * 0.446, w * 0.823, h * 0.501);
    path.cubicTo(w * 0.823, h * 0.694, w * 0.706, h * 0.736, w * 0.595, h * 0.748);
    path.cubicTo(w * 0.613, h * 0.763, w * 0.629, h * 0.794, w * 0.629, h * 0.841);
    path.cubicTo(w * 0.629, h * 0.909, w * 0.628, h * 0.964, w * 0.628, h * 0.990);
    path.cubicTo(w * 0.628, h * 1.003, w * 0.637, h * 1.019, w * 0.663, h * 1.014);
    path.cubicTo(w * 0.862, h * 0.948, 1.000, h * 0.761, 1.000, h * 0.540);
    path.cubicTo(1.000, h * 0.264, w * 0.776, h * 0.040, w * 0.500, h * 0.040);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GithubPainter oldDelegate) => oldDelegate.color != color;
}

class _LinkedinPainter extends CustomPainter {
  final Color color;
  _LinkedinPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.22),
    );
    canvas.drawRRect(rrect, Paint()..color = color);

    final bgCol = AppColors.isDark ? const Color(0xFF1B1917) : const Color(0xFFFAF7F2);
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'in',
        style: TextStyle(
          color: bgCol,
          fontSize: size.width * 0.68,
          fontWeight: FontWeight.w800,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset((w - textPainter.width) / 2, (h - textPainter.height) / 2 - 1),
    );
  }

  @override
  bool shouldRepaint(covariant _LinkedinPainter oldDelegate) => oldDelegate.color != color;
}

class _InstagramPainter extends CustomPainter {
  final Color color;
  _InstagramPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.11;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.1,
        size.height * 0.1,
        size.width * 0.8,
        size.height * 0.8,
      ),
      Radius.circular(size.width * 0.24),
    );
    canvas.drawRRect(rrect, strokePaint);

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.23,
      strokePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.28),
      size.width * 0.06,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _InstagramPainter oldDelegate) => oldDelegate.color != color;
}

class _TwitterXPainter extends CustomPainter {
  final Color color;
  _TwitterXPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(w * 0.75, h * 0.10);
    path.lineTo(w * 0.89, h * 0.10);
    path.lineTo(w * 0.58, h * 0.46);
    path.lineTo(w * 0.94, h * 0.90);
    path.lineTo(w * 0.68, h * 0.90);
    path.lineTo(w * 0.48, h * 0.63);
    path.lineTo(w * 0.25, h * 0.90);
    path.lineTo(w * 0.11, h * 0.90);
    path.lineTo(w * 0.44, h * 0.51);
    path.lineTo(w * 0.09, h * 0.10);
    path.lineTo(w * 0.36, h * 0.10);
    path.lineTo(w * 0.53, h * 0.34);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TwitterXPainter oldDelegate) => oldDelegate.color != color;
}

class _FacebookPainter extends CustomPainter {
  final Color color;
  _FacebookPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(w * 0.22),
    );
    canvas.drawRRect(rrect, Paint()..color = color);

    final bgCol = AppColors.isDark ? const Color(0xFF1B1917) : const Color(0xFFFAF7F2);
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'f',
        style: TextStyle(
          color: bgCol,
          fontSize: size.width * 0.74,
          fontWeight: FontWeight.w900,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset((w - textPainter.width) / 2 + 1, (h - textPainter.height) / 2 - 1),
    );
  }

  @override
  bool shouldRepaint(covariant _FacebookPainter oldDelegate) => oldDelegate.color != color;
}

class _YoutubePainter extends CustomPainter {
  final Color color;
  _YoutubePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, h * 0.15, w, h * 0.70),
      Radius.circular(w * 0.24),
    );
    canvas.drawRRect(rrect, Paint()..color = color);

    final bgCol = AppColors.isDark ? const Color(0xFF1B1917) : const Color(0xFFFAF7F2);
    final tri = Path()
      ..moveTo(w * 0.40, h * 0.34)
      ..lineTo(w * 0.66, h * 0.50)
      ..lineTo(w * 0.40, h * 0.66)
      ..close();
    canvas.drawPath(tri, Paint()..color = bgCol);
  }

  @override
  bool shouldRepaint(covariant _YoutubePainter oldDelegate) => oldDelegate.color != color;
}

class _TelegramPainter extends CustomPainter {
  final Color color;
  _TelegramPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(w * 0.88, h * 0.16)
      ..lineTo(w * 0.12, h * 0.46)
      ..cubicTo(w * 0.05, h * 0.49, w * 0.05, h * 0.55, w * 0.12, h * 0.57)
      ..lineTo(w * 0.32, h * 0.64)
      ..lineTo(w * 0.78, h * 0.28)
      ..cubicTo(w * 0.81, h * 0.26, w * 0.82, h * 0.28, w * 0.80, h * 0.30)
      ..lineTo(w * 0.41, h * 0.69)
      ..lineTo(w * 0.41, h * 0.84)
      ..cubicTo(w * 0.41, h * 0.88, w * 0.45, h * 0.89, w * 0.48, h * 0.86)
      ..lineTo(w * 0.58, h * 0.76)
      ..lineTo(w * 0.78, h * 0.91)
      ..cubicTo(w * 0.85, h * 0.96, w * 0.90, h * 0.92, w * 0.91, h * 0.84)
      ..lineTo(w * 0.99, h * 0.22)
      ..cubicTo(w * 1.01, h * 0.14, w * 0.95, h * 0.11, w * 0.88, h * 0.16)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TelegramPainter oldDelegate) => oldDelegate.color != color;
}

class _DiscordPainter extends CustomPainter {
  final Color color;
  _DiscordPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(w * 0.85, h * 0.22)
      ..cubicTo(w * 0.78, h * 0.18, w * 0.70, h * 0.16, w * 0.62, h * 0.15)
      ..cubicTo(w * 0.61, h * 0.17, w * 0.60, h * 0.20, w * 0.59, h * 0.22)
      ..cubicTo(w * 0.50, h * 0.21, w * 0.41, h * 0.21, w * 0.32, h * 0.22)
      ..cubicTo(w * 0.31, h * 0.20, w * 0.30, h * 0.17, w * 0.29, h * 0.15)
      ..cubicTo(w * 0.21, h * 0.16, w * 0.13, h * 0.18, w * 0.06, h * 0.22)
      ..cubicTo(-0.06, h * 0.42, 0.02, h * 0.62, 0.08, h * 0.78)
      ..cubicTo(w * 0.18, h * 0.85, w * 0.27, h * 0.88, w * 0.36, h * 0.88)
      ..cubicTo(w * 0.39, h * 0.85, w * 0.41, h * 0.81, w * 0.43, h * 0.77)
      ..cubicTo(w * 0.39, h * 0.75, w * 0.36, h * 0.73, w * 0.32, h * 0.70)
      ..cubicTo(w * 0.33, h * 0.69, w * 0.34, h * 0.68, w * 0.35, h * 0.67)
      ..cubicTo(w * 0.50, h * 0.74, w * 0.65, h * 0.74, w * 0.80, h * 0.67)
      ..cubicTo(w * 0.81, h * 0.68, w * 0.82, h * 0.69, w * 0.83, h * 0.70)
      ..cubicTo(w * 0.79, h * 0.73, w * 0.76, h * 0.75, w * 0.72, h * 0.77)
      ..cubicTo(w * 0.74, h * 0.81, w * 0.76, h * 0.85, w * 0.79, h * 0.88)
      ..cubicTo(w * 0.88, h * 0.88, w * 0.97, h * 0.85, 1.07, h * 0.78)
      ..cubicTo(1.14, h * 0.60, 1.04, h * 0.41, 0.85, h * 0.22)
      ..close();

    canvas.drawPath(path, paint);

    final eyePaint = Paint()
      ..color = AppColors.isDark ? const Color(0xFF1B1917) : const Color(0xFFFAF7F2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.36, h * 0.50), w * 0.08, eyePaint);
    canvas.drawCircle(Offset(w * 0.64, h * 0.50), w * 0.08, eyePaint);
  }

  @override
  bool shouldRepaint(covariant _DiscordPainter oldDelegate) => oldDelegate.color != color;
}

class _BehancePainter extends CustomPainter {
  final Color color;
  _BehancePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Bē',
        style: TextStyle(
          color: color,
          fontSize: size.width * 0.62,
          fontWeight: FontWeight.w900,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _BehancePainter oldDelegate) => oldDelegate.color != color;
}
