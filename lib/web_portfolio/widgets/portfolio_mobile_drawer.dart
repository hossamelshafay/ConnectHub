import 'package:flutter/material.dart';
import '../theme/web_colors.dart';

class PortfolioMobileDrawer extends StatelessWidget {
  final List<String> navTitles;
  final ValueChanged<String> onNavSelected;

  const PortfolioMobileDrawer({
    super.key,
    required this.navTitles,
    required this.onNavSelected,
  });

  IconData _getNavIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'about':
        return Icons.person_outline_rounded;
      case 'skills':
        return Icons.terminal_rounded;
      case 'experience':
        return Icons.work_outline_rounded;
      case 'projects':
        return Icons.dashboard_outlined;
      case 'education':
        return Icons.school_outlined;
      case 'certificates':
        return Icons.verified_outlined;
      case 'contact':
        return Icons.mail_outline_rounded;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: WebColors.surfaceElevated,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ConnectHub',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: WebColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: WebColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: WebColors.border, height: 1),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: navTitles.length,
                  itemBuilder: (context, i) {
                    final title = navTitles[i];
                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      title: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          color: WebColors.textSecondary,
                        ),
                      ),
                      leading: Icon(
                        _getNavIconForTitle(title),
                        size: 18,
                        color: WebColors.textMuted,
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        onNavSelected(title);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
