import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../theme/web_colors.dart';
import '../theme/web_theme.dart';
import '../models/portfolio_view_data.dart';
import '../core/exceptions.dart';
import '../data/datasources/web_portfolio_remote_data_source.dart';
import '../data/repositories/web_portfolio_repository_impl.dart';
import '../domain/usecases/load_portfolio_use_case.dart';
import '../widgets/portfolio_shimmer_loading.dart';
import 'portfolio_state_views.dart';
import '../widgets/web_navigation_bar.dart';
import '../sections/hero_section.dart';
import '../sections/about_section.dart';
import '../sections/skills_section.dart';
import '../sections/experience_section.dart';
import '../sections/projects_section.dart';
import '../sections/education_section.dart';
import '../sections/certificates_section.dart';
import '../sections/contact_section.dart';
import '../sections/footer_section.dart';

/// Presentation state for the Web Portfolio view.
enum _PortfolioStatus {
  loading,
  success,
  notFound,
  offline,
  error,
}

/// The master single-page view assembling all 9 sections of the Web Portfolio.
class WebPortfolioPage extends StatefulWidget {
  final String? identifier;
  final String? username;

  const WebPortfolioPage({
    super.key,
    this.identifier,
    this.username,
  });

  @override
  State<WebPortfolioPage> createState() => _WebPortfolioPageState();
}

class _WebPortfolioPageState extends State<WebPortfolioPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Section Keys for smooth scrolling
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _skillsKey = GlobalKey();
  final GlobalKey _experienceKey = GlobalKey();
  final GlobalKey _projectsKey = GlobalKey();
  final GlobalKey _educationKey = GlobalKey();
  final GlobalKey _certificatesKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  late final List<GlobalKey> _sectionKeys;
  late final LoadPortfolioUseCase _loadPortfolioUseCase;

  PortfolioViewData? _portfolioData;
  _PortfolioStatus _status = _PortfolioStatus.loading;
  String _errorMessage = '';

  // Luxury design is dark-only — always true.
  static const bool _isDark = true;
  int _activeNavIndex = 0;

  String? get _effectiveIdentifier =>
      (widget.identifier != null && widget.identifier!.trim().isNotEmpty)
          ? widget.identifier!.trim()
          : (widget.username != null && widget.username!.trim().isNotEmpty)
              ? widget.username!.trim()
              : null;

  @override
  void initState() {
    super.initState();
    _sectionKeys = [
      _heroKey,
      _aboutKey,
      _skillsKey,
      _experienceKey,
      _projectsKey,
      _educationKey,
      _certificatesKey,
      _contactKey,
    ];

    final remoteDataSource = WebPortfolioRemoteDataSourceImpl();
    final repository = WebPortfolioRepositoryImpl(remoteDataSource: remoteDataSource);
    _loadPortfolioUseCase = LoadPortfolioUseCase(repository);

    _loadPortfolioData(forceRefresh: true);
  }

  Future<void> _loadPortfolioData({bool forceRefresh = true}) async {
    if (!mounted) return;
    setState(() {
      _status = _PortfolioStatus.loading;
      _errorMessage = '';
    });

    try {
      final data = await _loadPortfolioUseCase(_effectiveIdentifier, forceRefresh);
      if (mounted) {
        setState(() {
          _portfolioData = data;
          _status = _PortfolioStatus.success;
        });
      }
    } on PortfolioNotFoundException catch (e) {
      if (mounted) {
        setState(() {
          _status = _PortfolioStatus.notFound;
          _errorMessage = e.message;
        });
      }
    } on PortfolioOfflineException catch (e) {
      if (mounted) {
        setState(() {
          _status = _PortfolioStatus.offline;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = _PortfolioStatus.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _scrollToSection(int index) {
    if (index >= 0 && index < _sectionKeys.length) {
      _scrollToKey(_sectionKeys[index]);
      setState(() {
        _activeNavIndex = index;
      });
    }
  }

  void _scrollToSectionByTitle(String title) {
    switch (title.toLowerCase()) {
      case 'hero':
        _scrollToKey(_heroKey);
        break;
      case 'about':
        _scrollToKey(_aboutKey);
        break;
      case 'skills':
        _scrollToKey(_skillsKey);
        break;
      case 'experience':
        _scrollToKey(_experienceKey);
        break;
      case 'projects':
        _scrollToKey(_projectsKey);
        break;
      case 'education':
        _scrollToKey(_educationKey);
        break;
      case 'certificates':
        _scrollToKey(_certificatesKey);
        break;
      case 'contact':
        _scrollToKey(_contactKey);
        break;
    }
  }

  List<String> _getVisibleNavTitles(PortfolioViewData data) {
    return [
      'About',
      if (data.skills.isNotEmpty) 'Skills',
      if (data.experiences.isNotEmpty) 'Experience',
      if (data.projects.isNotEmpty) 'Projects',
      if (data.educations.isNotEmpty) 'Education',
      if (data.certificates.isNotEmpty) 'Certificates',
      'Contact',
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (_status) {
      case _PortfolioStatus.loading:
        body = const PortfolioShimmerLoading();
        break;
      case _PortfolioStatus.notFound:
        body = PortfolioNotFoundView(
          identifier: _effectiveIdentifier,
          onRetry: () => _loadPortfolioData(forceRefresh: true),
          onHome: () => Navigator.of(context).pushReplacementNamed('/'),
        );
        break;
      case _PortfolioStatus.offline:
        body = PortfolioOfflineView(
          onRetry: () => _loadPortfolioData(forceRefresh: true),
        );
        break;
      case _PortfolioStatus.error:
        body = PortfolioErrorView(
          message: _errorMessage,
          onRetry: () => _loadPortfolioData(forceRefresh: true),
        );
        break;
      case _PortfolioStatus.success:
        body = _buildPortfolioContent(_portfolioData!);
        break;
    }

    return Theme(
      data: WebTheme.darkTheme,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: WebColors.background,
        endDrawer: _status == _PortfolioStatus.success ? _buildMobileDrawer(_portfolioData!) : null,
        body: body,
      ),
    );
  }

  Widget _buildPortfolioContent(PortfolioViewData data) {
    final visibleNavTitles = _getVisibleNavTitles(data);

    return Stack(
      children: [
        // Luxury Subtle Dark Gradient & Fine Noise Background
        const Positioned.fill(
          child: _LuxuryBackground(),
        ),

        // Scrollable Content Containing Available Sections
        SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: WebTheme.navBarHeight), // Space for sticky navbar

              // Section 0: Hero
              Container(
                key: _heroKey,
                child: HeroSection(
                  data: data,
                  isDark: _isDark,
                  onExploreProjects: () => _scrollToKey(
                    data.projects.isNotEmpty ? _projectsKey : _contactKey,
                  ),
                  onContactMe: () => _scrollToKey(_contactKey),
                ),
              ),

              // Section 1: About
              Container(
                key: _aboutKey,
                child: AboutSection(
                  data: data,
                  isDark: _isDark,
                ),
              ),

              // Section 2: Skills (Hidden automatically if empty)
              if (data.skills.isNotEmpty)
                Container(
                  key: _skillsKey,
                  child: SkillsSection(
                    data: data,
                    isDark: _isDark,
                  ),
                ),

              // Section 3: Experience (Hidden automatically if empty)
              if (data.experiences.isNotEmpty)
                Container(
                  key: _experienceKey,
                  child: ExperienceSection(
                    data: data,
                    isDark: _isDark,
                  ),
                ),

              // Section 4: Projects (Hidden automatically if empty)
              if (data.projects.isNotEmpty)
                Container(
                  key: _projectsKey,
                  child: ProjectsSection(
                    data: data,
                    isDark: _isDark,
                  ),
                ),

              // Section 5: Education (Hidden automatically if empty)
              if (data.educations.isNotEmpty)
                Container(
                  key: _educationKey,
                  child: EducationSection(
                    data: data,
                    isDark: _isDark,
                  ),
                ),

              // Section 6: Certificates (Hidden automatically if empty)
              if (data.certificates.isNotEmpty)
                Container(
                  key: _certificatesKey,
                  child: CertificatesSection(
                    data: data,
                    isDark: _isDark,
                  ),
                ),

              // Section 7: Contact
              Container(
                key: _contactKey,
                child: ContactSection(
                  data: data,
                  isDark: _isDark,
                ),
              ),

              // Section 8: Footer
              FooterSection(
                data: data,
                isDark: _isDark,
                onScrollToTop: () => _scrollToKey(_heroKey),
              ),
            ],
          ),
        ),

        // Sticky Top Navigation Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: WebNavigationBar(
            activeIndex: _activeNavIndex,
            visibleNavItems: visibleNavTitles,
            onNavItemClick: (title) => _scrollToSectionByTitle(title),
            onSectionSelected: (index) {
              _scrollToSection(index);
            },
            onToggleTheme: () {}, // dark-only luxury design
            isDark: true,
            onOpenMobileMenu: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMobileDrawer(PortfolioViewData data) {
    final navTitles = _getVisibleNavTitles(data);

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
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                        _scrollToSectionByTitle(title);
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
}

/// A subtle, GPU-optimized luxury background with warm gold ambient radial glows
/// and a fine stochastic micro-grain texture.
class _LuxuryBackground extends StatelessWidget {
  const _LuxuryBackground();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          // Base deep black
          Container(color: WebColors.background),

          // Subtle warm gold ambient glow at the top
          Positioned(
            top: -200,
            left: 0,
            right: 0,
            height: 750,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.1,
                  colors: [
                    WebColors.primary.withValues(alpha: 0.05),
                    WebColors.primaryDark.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),

          // Secondary subtle gold illumination
          Positioned(
            top: 1400,
            right: -150,
            width: 600,
            height: 600,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.85,
                  colors: [
                    WebColors.primaryLight.withValues(alpha: 0.025),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Fine procedural micro-grain
          Positioned.fill(
            child: CustomPaint(
              painter: _LuxuryNoisePainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _LuxuryNoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.015)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    const step = 26.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        final hash = ((x * 12.9898 + y * 78.233) % 1.0);
        if (hash > 0.48) {
          final offsetX = (hash * 19) % step;
          final offsetY = (hash * 37) % step;
          canvas.drawPoints(
            ui.PointMode.points,
            [Offset(x + offsetX, y + offsetY)],
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
