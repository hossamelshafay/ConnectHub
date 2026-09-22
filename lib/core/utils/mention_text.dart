import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';
import 'package:connecthub/core/utils/mention_helper.dart';
import 'package:connecthub/core/utils/profile_navigation_helper.dart';

class MentionText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? mentionStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign textAlign;

  const MentionText({
    super.key,
    required this.text,
    this.style,
    this.mentionStyle,
    this.maxLines,
    this.overflow,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? AppTextStyles.body2;

    final spans = MentionHelper.buildMentionSpans(
      text: text,
      defaultStyle: effectiveStyle,
      mentionStyle: mentionStyle,
      onMentionTap: (username) {
        ProfileNavigationHelper.openProfileByUsername(context, username);
      },
    );

    return RichText(
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      text: TextSpan(
        style: effectiveStyle,
        children: spans,
      ),
    );
  }
}
