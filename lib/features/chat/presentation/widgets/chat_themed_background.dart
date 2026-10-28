import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/core/theme/theme_cubit.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Reusable themed chat background used across all chats in the application
/// (User ↔ User and User ↔ AI Bot).
/// Automatically switches between `assets/img/light-chat-background.png` and
/// `assets/img/dark-chat-background.png` depending on the current theme.
class ChatThemedBackground extends StatelessWidget {
  final Widget child;

  const ChatThemedBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, _) {
        final isDark = AppColors.isDark;
        final bgAsset = isDark
            ? 'assets/img/dark-chat-background.png'
            : 'assets/img/light-chat-background.png';

        return Stack(
          fit: StackFit.expand,
          children: [
            // Themed chat background image
            Image.asset(
              bgAsset,
              fit: BoxFit.cover,
            ),

            // Subtle overlay so messages, text, and inputs remain crisp & readable
            Container(
              color: AppColors.background.withValues(alpha: isDark ? 0.45 : 0.30),
            ),

            // Foreground chat contents
            child,
          ],
        );
      },
    );
  }
}
