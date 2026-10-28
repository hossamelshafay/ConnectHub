import 'package:flutter/material.dart';

class PortfolioGeneratedActions extends StatelessWidget {
  final VoidCallback onPreview;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onClose;
  final bool isCopied;

  static const Color goldPrimary = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF4D06F);
  static const Color cardBg = Color(0xFF1B1B1B);

  const PortfolioGeneratedActions({
    super.key,
    required this.onPreview,
    required this.onCopy,
    required this.onShare,
    required this.onClose,
    required this.isCopied,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Preview button (Full-width gold gradient)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 4,
              shadowColor: goldPrimary.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.transparent,
            ).copyWith(
              backgroundBuilder: (context, states, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [goldLight, goldPrimary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: child,
                );
              },
            ),
            onPressed: onPreview,
            icon: const Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: Color(0xFF090909),
            ),
            label: const Text(
              'Preview',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF090909),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Row with Copy Link and Share buttons
        Row(
          children: [
            // Copy Link button
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: goldLight,
                  side: BorderSide(
                    color: isCopied
                        ? const Color(0xFF10B981)
                        : goldPrimary.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: isCopied
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : cardBg,
                ),
                onPressed: onCopy,
                icon: Icon(
                  isCopied ? Icons.check_circle_rounded : Icons.copy_rounded,
                  size: 17,
                  color: isCopied ? const Color(0xFF10B981) : goldLight,
                ),
                label: Text(
                  isCopied ? 'Copied!' : 'Copy Link',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isCopied ? const Color(0xFF10B981) : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Share button
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: goldLight,
                  side: BorderSide(
                    color: goldPrimary.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: cardBg,
                ),
                onPressed: onShare,
                icon: const Icon(
                  Icons.share_rounded,
                  size: 17,
                  color: goldLight,
                ),
                label: const Text(
                  'Share',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Close button
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFA7A7A7),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          ),
          onPressed: onClose,
          child: const Text(
            'Close',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
