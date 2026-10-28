import 'package:flutter/material.dart';
import 'package:connecthub/core/utils/app_theme.dart';

/// Displayed inside ChatbotView when no messages exist yet.
/// Shows the chat-bot illustration as the header and suggestion cards below.
class ChatbotLandingView extends StatelessWidget {
  final ValueChanged<String> onSelectSuggestion;

  static const List<Map<String, String>> suggestions = [
    {
      'icon': '✨',
      'title': 'Polish My Bio',
      'prompt':
          'Help me rewrite my profile bio to sound like a high-impact senior engineer.',
    },
    {
      'icon': '💡',
      'title': 'Viral Post Hooks',
      'prompt':
          'Give me 3 compelling, concise post ideas about building scalable applications.',
    },
    {
      'icon': '🎯',
      'title': 'Project Critique',
      'prompt':
          'How should I articulate my flagship portfolio project to impress recruiters?',
    },
    {
      'icon': '✉️',
      'title': 'Founder Outreach',
      'prompt':
          'Draft a warm, professional connection message to a startup founder.',
    },
  ];

  const ChatbotLandingView({
    super.key,
    required this.onSelectSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Illustration header using chat-bot.png
          SizedBox(
            height: 200,
            child: Image.asset(
              'assets/img/chat-bot.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'ConnectHub Intelligence',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your personal copilot for career growth, post curation, and networking.',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'SUGGESTIONS',
              style: AppTextStyles.caption.copyWith(
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                fontSize: 10.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Suggestion Cards
          ...suggestions.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => onSelectSuggestion(item['prompt']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.glassBorder,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          item['icon']!,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['prompt']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
