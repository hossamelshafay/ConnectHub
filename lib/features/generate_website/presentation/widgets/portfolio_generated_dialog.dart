import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'portfolio_generated_actions.dart';

class PortfolioGeneratedDialog extends StatefulWidget {
  final String publicUrl;
  final String usernameOrName;

  const PortfolioGeneratedDialog({
    super.key,
    required this.publicUrl,
    required this.usernameOrName,
  });

  static Future<void> show(
    BuildContext context, {
    required String publicUrl,
    required String usernameOrName,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => PortfolioGeneratedDialog(
        publicUrl: publicUrl,
        usernameOrName: usernameOrName,
      ),
    );
  }

  @override
  State<PortfolioGeneratedDialog> createState() => _PortfolioGeneratedDialogState();
}

class _PortfolioGeneratedDialogState extends State<PortfolioGeneratedDialog>
    with SingleTickerProviderStateMixin {
  bool _copied = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.publicUrl));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<void> _openWebsite() async {
    final url = widget.publicUrl.trim();
    debugPrint('[PortfolioGeneratedDialog] Opening website: $url');
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) return;
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('[PortfolioGeneratedDialog] launchUrl error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open browser: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _shareWebsite() async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: 'Check out my portfolio website: ${widget.publicUrl}',
          subject: '${widget.usernameOrName} Portfolio',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not share website: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const goldPrimary = Color(0xFFD4AF37);
    const goldLight = Color(0xFFF4D06F);
    const darkSurface = Color(0xFF141414);
    const cardBg = Color(0xFF1B1B1B);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: darkSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: goldPrimary.withValues(alpha: 0.45),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top luxury badge with glowing icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearAnimationGradient(
                    colors: [goldLight, goldPrimary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: goldPrimary.withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.public_rounded,
                  color: Color(0xFF090909),
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),

              // Title
              const Text(
                'Website Generated Successfully',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF8F8F8),
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'A high-performance luxury snapshot of your portfolio has been deployed and is permanently accessible to anyone worldwide.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFFA7A7A7),
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),

              // URL Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: goldPrimary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.link_rounded,
                      color: goldLight,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SelectableText(
                        widget.publicUrl,
                        style: const TextStyle(
                          color: Color(0xFFF8F8F8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              PortfolioGeneratedActions(
                onPreview: _openWebsite,
                onCopy: _copyToClipboard,
                onShare: _shareWebsite,
                onClose: () => Navigator.of(context).pop(),
                isCopied: _copied,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LinearAnimationGradient extends LinearGradient {
  const LinearAnimationGradient({
    super.begin = Alignment.topLeft,
    super.end = Alignment.bottomRight,
    required super.colors,
  });
}
