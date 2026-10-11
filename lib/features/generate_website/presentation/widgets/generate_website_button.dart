import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connecthub/core/config/portfolio_config.dart';
import 'package:connecthub/features/profile/data/models/user_model.dart';
import '../cubit/generate_website_cubit.dart';
import '../cubit/generate_website_state.dart';

/// Luxury Gold Gradient button to generate and publish or view a permanent public portfolio website.
/// Supports both Owner and Visitor modes:
/// - Owner (websiteGenerated == false): Shows "🌐 Generate Website".
/// - Owner (websiteGenerated == true): Shows "🌐 Open Website".
/// - Visitor (websiteGenerated == false): Shows NOTHING.
/// - Visitor (websiteGenerated == true): Shows "🌐 Website".
class GenerateWebsiteButton extends StatelessWidget {
  final UserModel user;
  final bool isOwner;
  final bool compact;
  final VoidCallback? onWebsiteGenerated;

  const GenerateWebsiteButton({
    super.key,
    required this.user,
    this.isOwner = true,
    this.compact = true,
    this.onWebsiteGenerated,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GenerateWebsiteCubit(),
      child: _GenerateWebsiteButtonContent(
        user: user,
        isOwner: isOwner,
        compact: compact,
        onWebsiteGenerated: onWebsiteGenerated,
      ),
    );
  }
}

class _GenerateWebsiteButtonContent extends StatefulWidget {
  final UserModel user;
  final bool isOwner;
  final bool compact;
  final VoidCallback? onWebsiteGenerated;

  const _GenerateWebsiteButtonContent({
    required this.user,
    required this.isOwner,
    required this.compact,
    this.onWebsiteGenerated,
  });

  @override
  State<_GenerateWebsiteButtonContent> createState() =>
      _GenerateWebsiteButtonContentState();
}

class _GenerateWebsiteButtonContentState
    extends State<_GenerateWebsiteButtonContent> {
  bool? _localWebsiteGenerated;
  String? _localWebsiteUrl;
  bool _portfolioDocExists = false;

  static const Color _goldPrimary = Color(0xFFD4AF37);
  static const Color _goldLight = Color(0xFFF4D06F);
  static const Color _darkBg = Color(0xFF090909);

  @override
  void initState() {
    super.initState();
    _checkPortfolioExistence();
  }

  @override
  void didUpdateWidget(covariant _GenerateWebsiteButtonContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.user.uid != oldWidget.user.uid ||
        widget.user.websiteGenerated != oldWidget.user.websiteGenerated ||
        widget.user.websiteUrl != oldWidget.user.websiteUrl) {
      _checkPortfolioExistence();
    }
  }

  Future<void> _checkPortfolioExistence() async {
    final isGenFlag = _localWebsiteGenerated ?? widget.user.websiteGenerated;
    final url = (_localWebsiteUrl != null && _localWebsiteUrl!.trim().isNotEmpty)
        ? _localWebsiteUrl!.trim()
        : (widget.user.websiteUrl?.trim() ?? '');

    // Must satisfy: websiteGenerated == true AND websiteUrl is non-empty
    if (!isGenFlag || url.isEmpty) {
      if (mounted) {
        setState(() {
          _portfolioDocExists = false;
        });
      }
      return;
    }

    // Must also validate the actual public_portfolios document exists
    try {
      final docIdsToCheck = <String>{};
      final rawUsername = widget.user.username?.trim();
      if (rawUsername != null && rawUsername.isNotEmpty) {
        docIdsToCheck.add(rawUsername.toLowerCase());
      }
      final rawSlug = widget.user.profileSlug?.trim();
      if (rawSlug != null && rawSlug.isNotEmpty) {
        docIdsToCheck.add(rawSlug.toLowerCase());
      }
      if (widget.user.uid.isNotEmpty) {
        docIdsToCheck.add(widget.user.uid);
      }

      bool exists = false;
      for (final docId in docIdsToCheck) {
        final docSnap = await FirebaseFirestore.instance
            .collection('public_portfolios')
            .doc(docId)
            .get();
        if (docSnap.exists) {
          exists = true;
          break;
        }
      }

      if (!exists && widget.user.uid.isNotEmpty) {
        final querySnap = await FirebaseFirestore.instance
            .collection('public_portfolios')
            .where('uid', isEqualTo: widget.user.uid)
            .limit(1)
            .get();
        if (querySnap.docs.isNotEmpty) {
          exists = true;
        }
      }

      if (mounted) {
        setState(() {
          _portfolioDocExists = exists;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _portfolioDocExists = false;
        });
      }
    }
  }

  bool get _isGenerated {
    final isGenFlag = _localWebsiteGenerated ?? widget.user.websiteGenerated;
    final url = (_localWebsiteUrl != null && _localWebsiteUrl!.trim().isNotEmpty)
        ? _localWebsiteUrl!.trim()
        : (widget.user.websiteUrl?.trim() ?? '');
    return isGenFlag && url.isNotEmpty && _portfolioDocExists;
  }

  String get _targetUrl {
    if (_localWebsiteUrl != null && _localWebsiteUrl!.isNotEmpty) {
      return _localWebsiteUrl!;
    }
    if (widget.user.websiteUrl != null &&
        widget.user.websiteUrl!.isNotEmpty) {
      return widget.user.websiteUrl!;
    }
    final rawUsername = widget.user.username?.trim();
    final docId = (rawUsername != null && rawUsername.isNotEmpty)
        ? rawUsername.toLowerCase()
        : widget.user.uid;
    return PortfolioConfig.buildUrl(docId);
  }

  Future<void> _openWebsite(BuildContext context) async {
    final url = _targetUrl;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open website: $url'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  void _onPressed(BuildContext context) {
    if (_isGenerated) {
      _openWebsite(context);
    } else if (widget.isOwner) {
      final cubit = context.read<GenerateWebsiteCubit>();
      cubit.generateWebsite(
        uid: widget.user.uid,
        cachedUser: widget.user,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Visitor Rule: If websiteGenerated == false, show NOTHING
    if (!widget.isOwner && !_isGenerated) {
      return const SizedBox.shrink();
    }

    return BlocConsumer<GenerateWebsiteCubit, GenerateWebsiteState>(
      listener: (context, state) {
        if (state is GenerateWebsiteSuccess) {
          setState(() {
            _localWebsiteGenerated = true;
            _localWebsiteUrl = state.publicUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Portfolio website generated successfully.'),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          widget.onWebsiteGenerated?.call();
        } else if (state is GenerateWebsiteError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        'Failed to generate website: ${state.message}'),
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

        // Determine label according to Owner vs Visitor & generation status
        final String buttonLabel;
        if (isLoading) {
          buttonLabel = 'Generating...';
        } else if (!widget.isOwner) {
          buttonLabel = 'Website';
        } else if (_isGenerated) {
          buttonLabel = 'Open Website';
        } else {
          buttonLabel = 'Generate Website';
        }

        if (widget.compact) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : () => _onPressed(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_darkBg),
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
                        buttonLabel,
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

        // Full width variant
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
                      : buttonLabel,
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
