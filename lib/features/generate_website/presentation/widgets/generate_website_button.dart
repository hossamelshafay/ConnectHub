import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import '../cubit/generate_website_cubit.dart';
import '../cubit/generate_website_state.dart';
import 'portfolio_generated_dialog.dart';

/// Luxury Gold Gradient button to generate and publish a permanent public portfolio website.
/// Self-contained with its own Cubit provider so it can be embedded in AppBars or profile screens.
class GenerateWebsiteButton extends StatelessWidget {
  final UserModel user;
  final bool compact;

  const GenerateWebsiteButton({
    super.key,
    required this.user,
    this.compact = true,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GenerateWebsiteCubit(),
      child: _GenerateWebsiteButtonContent(
        user: user,
        compact: compact,
      ),
    );
  }
}

class _GenerateWebsiteButtonContent extends StatefulWidget {
  final UserModel user;
  final bool compact;

  const _GenerateWebsiteButtonContent({
    required this.user,
    required this.compact,
  });

  @override
  State<_GenerateWebsiteButtonContent> createState() =>
      _GenerateWebsiteButtonContentState();
}

class _GenerateWebsiteButtonContentState
    extends State<_GenerateWebsiteButtonContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  static const Color _goldPrimary = Color(0xFFD4AF37);
  static const Color _goldLight = Color(0xFFF4D06F);
  static const Color _darkBg = Color(0xFF090909);

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _onPressed(BuildContext context) {
    final cubit = context.read<GenerateWebsiteCubit>();
    cubit.generateWebsite(
      uid: widget.user.uid,
      cachedUser: widget.user,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GenerateWebsiteCubit, GenerateWebsiteState>(
      listener: (context, state) {
        if (state is GenerateWebsiteSuccess) {
          PortfolioGeneratedDialog.show(
            context,
            publicUrl: state.publicUrl,
            usernameOrName: widget.user.name,
          );
        } else if (state is GenerateWebsiteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Failed to generate website: ${state.message}'),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => _onPressed(context),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is GenerateWebsiteLoading;

        if (widget.compact) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : () => _onPressed(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_goldLight, _goldPrimary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _goldPrimary.withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLoading)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(_darkBg),
                          ),
                        )
                      else
                        const Icon(
                          Icons.public_rounded,
                          size: 15,
                          color: _darkBg,
                        ),
                      const SizedBox(width: 6),
                      Text(
                        isLoading ? 'Generating...' : 'Generate Website',
                        style: const TextStyle(
                          color: _darkBg,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Full width luxury button variant
        return Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_goldLight, _goldPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _goldPrimary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isLoading ? null : () => _onPressed(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(_darkBg),
                    ),
                  )
                else
                  const Icon(
                    Icons.public_rounded,
                    color: _darkBg,
                    size: 20,
                  ),
                const SizedBox(width: 10),
                Text(
                  isLoading
                      ? 'Generating Portfolio Website...'
                      : 'Generate Portfolio Website',
                  style: const TextStyle(
                    color: _darkBg,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
