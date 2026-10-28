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
import '../widgets/web_sidebar_nav.dart';
import '../widgets/portfolio_mobile_drawer.dart';
import '../widgets/currently_learning_card.dart';
import '../sections/hero_section.dart';
import '../sections/about_section.dart';
import '../sections/skills_section.dart';
import '../sections/experience_section.dart';
import '../sections/projects_section.dart';
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

/// The master single-page view assembling the Web Portfolio.
/// Faithfully recreates the Titanium/Beige design mockup.
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
  final GlobalKey _certificatesKey = GlobalKey();
  final GlobalKey _contactKey = GlobalKey();

  late final LoadPortfolioUseCase _loadPortfolioUseCase;

  PortfolioViewData? _portfolioData;
  _PortfolioStatus _status = _PortfolioStatus.loading;
  String _errorMessage = '';

  // Theme state: defaults to false (Warm Titanium / Beige matching mockup)
  bool _isDark = false;
  int _activeNavIndex = 0;
  int _activeSidebarIndex = 0;

  String? get _effectiveIdentifier =>
      (widget.identifier != null && widget.identifier!.trim().isNotEmpty)
          ? widget.identifier!.trim()
          : (widget.username != null && widget.username!.trim().isNotEmpty)
              ? widget.username!.trim()
              : null;

  @override
  void initState() {
    super.initState();

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

  void _scrollToSectionByTitle(String title) {
    switch (title.toLowerCase()) {
      case 'home':
      case 'hero':
      case 'overview':
        _scrollToKey(_heroKey);
        setState(() {
          _activeNavIndex = 0;
          _activeSidebarIndex = 0;
        });
        break;
      case 'about':
        _scrollToKey(_aboutKey);
        setState(() {
          _activeNavIndex = 4;
          _activeSidebarIndex = 6;
        });
        break;
      case 'skills':
        _scrollToKey(_skillsKey);
        setState(() {
          _activeSidebarIndex = 4;
        });
        break;
      case 'experience':
        _scrollToKey(_experienceKey);
        setState(() {
          _activeNavIndex = 2;
          _activeSidebarIndex = 2;
        });
        break;
      case 'projects':
        _scrollToKey(_projectsKey);
        setState(() {
          _activeNavIndex = 1;
          _activeSidebarIndex = 1;
        });
        break;
      case 'certificates':
        _scrollToKey(_certificatesKey);
        setState(() {
          _activeNavIndex = 3;
          _activeSidebarIndex = 3;
        });
        break;
      case 'posts':
        _scrollToKey(_projectsKey);
        setState(() {
          _activeSidebarIndex = 5;
        });
        break;
      case 'contact':
        _scrollToKey(_contactKey);
        break;
    }
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
      data: _isDark ? WebTheme.darkTheme : WebTheme.lightTheme,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: WebColors.getBackground(isDark: _isDark),
        endDrawer: _status == _PortfolioStatus.success ? _buildMobileDrawer(_portfolioData!) : null,
        body: body,
      ),
    );
  }

  Widget _buildPortfolioContent(PortfolioViewData data) {
    return Stack(
      children: [
        // Scrollable Content
        SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Section 0: Hero Section with Wallpaper Background & Fade (extends to top under floating navbar)
              Container(
                key: _heroKey,
                child: HeroSection(
                  data: data,
                  isDark: _isDark,
                  onExploreProjects: () => _scrollToKey(_projectsKey),
                  onContactMe: () => _scrollToKey(_contactKey),
                ),
              ),

              // Section 1: Dashboard Main Body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: WebTheme.maxContentWidth),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 1060;

                        return isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left Sidebar Navigation Card
                                  SizedBox(
                                    width: 236,
                                    child: WebSidebarNav(
                                      activeIndex: _activeSidebarIndex,
                                      onNavSelected: _scrollToSectionByTitle,
                                      onGetInTouch: () => _scrollToKey(_contactKey),
                                      isDark: _isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 24),

                                  // Right Dashboard Content Grid
                                  Expanded(
                                    child: _buildDashboardContent(data, isDesktop: true),
                                  ),
                                ],
                              )
                            : _buildDashboardContent(data, isDesktop: false);
                      },
                    ),
                  ),
                ),
              ),

              // Contact Section
              Container(
                key: _contactKey,
                child: ContactSection(
                  data: data,
                  isDark: _isDark,
                ),
              ),

              // Footer
              FooterSection(
                data: data,
                isDark: _isDark,
                onScrollToTop: () => _scrollToKey(_heroKey),
              ),
            ],
          ),
        ),

        // Sticky Floating Top Navigation Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: WebNavigationBar(
            activeIndex: _activeNavIndex,
            onSectionSelected: (index) {
              if (index == 0) _scrollToKey(_heroKey);
              if (index == 1) _scrollToKey(_projectsKey);
              if (index == 2) _scrollToKey(_experienceKey);
              if (index == 3) _scrollToKey(_certificatesKey);
              if (index == 4) _scrollToKey(_aboutKey);
              if (index == 5) _scrollToKey(_contactKey);
            },
            onNavItemClick: _scrollToSectionByTitle,
            onToggleTheme: () {
              setState(() {
                _isDark = !_isDark;
              });
            },
            isDark: _isDark,
            onOpenMobileMenu: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardContent(PortfolioViewData data, {required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Row 1: About Me & Skills (side-by-side on desktop, stacked on mobile)
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  key: _aboutKey,
                  child: AboutSection(data: data, isDark: _isDark),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  key: _skillsKey,
                  child: SkillsSection(data: data, isDark: _isDark),
                ),
              ),
            ],
          )
        else ...[
          Container(
            key: _aboutKey,
            child: AboutSection(data: data, isDark: _isDark),
          ),
          const SizedBox(height: 20),
          Container(
            key: _skillsKey,
            child: SkillsSection(data: data, isDark: _isDark),
          ),
        ],

        const SizedBox(height: 24),

        // Row 2: Featured Projects
        Container(
          key: _projectsKey,
          child: ProjectsSection(data: data, isDark: _isDark),
        ),

        const SizedBox(height: 24),

        // Row 3: Experience, Certificates, Currently Learning
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  key: _experienceKey,
                  child: ExperienceSection(data: data, isDark: _isDark),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
                child: Container(
                  key: _certificatesKey,
                  child: CertificatesSection(data: data, isDark: _isDark),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 3,
                child: CurrentlyLearningCard(data: data, isDark: _isDark),
              ),
            ],
          )
        else ...[
          Container(
            key: _experienceKey,
            child: ExperienceSection(data: data, isDark: _isDark),
          ),
          const SizedBox(height: 20),
          Container(
            key: _certificatesKey,
            child: CertificatesSection(data: data, isDark: _isDark),
          ),
          const SizedBox(height: 20),
          CurrentlyLearningCard(data: data, isDark: _isDark),
        ],
      ],
    );
  }

  Widget _buildMobileDrawer(PortfolioViewData data) {
    return PortfolioMobileDrawer(
      navTitles: const [
        'Home',
        'About',
        'Skills',
        'Projects',
        'Experience',
        'Certificates',
        'Contact',
      ],
      onNavSelected: _scrollToSectionByTitle,
    );
  }
}
