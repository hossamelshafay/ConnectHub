import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:connecthub/web_portfolio/theme/web_theme.dart';
import 'package:connecthub/web_portfolio/widgets/web_navigation_bar.dart';
import 'package:connecthub/web_portfolio/sections/hero_section.dart';
import 'package:connecthub/web_portfolio/sections/about_section.dart';
import 'package:connecthub/web_portfolio/sections/skills_section.dart';
import 'package:connecthub/web_portfolio/sections/experience_section.dart';
import 'package:connecthub/web_portfolio/sections/projects_section.dart';
import 'package:connecthub/web_portfolio/sections/education_section.dart';
import 'package:connecthub/web_portfolio/sections/certificates_section.dart';
import 'package:connecthub/web_portfolio/sections/contact_section.dart';
import 'package:connecthub/web_portfolio/sections/footer_section.dart';
import 'helpers/portfolio_test_helper.dart';

void main() {
  final testSizes = [
    const Size(320, 568),   // iPhone SE 1st gen / small mobile
    const Size(360, 800),   // Android standard
    const Size(375, 667),   // iPhone 8
    const Size(390, 844),   // iPhone 12/13/14
    const Size(414, 896),   // iPhone XR/11
    const Size(768, 1024),  // iPad Mini portrait
    const Size(820, 1180),  // iPad Air portrait
    const Size(1024, 768),  // iPad landscape / Small laptop
    const Size(1280, 800),  // Standard Laptop
    const Size(1440, 900),  // Desktop
    const Size(1920, 1080), // Full HD Desktop
    const Size(2560, 1440), // 2K / Ultrawide
  ];

  final mockData = PortfolioTestHelper.getTestPortfolio();

  group('WebNavigationBar Zero Overflow Test', () {
    for (final size in testSizes) {
      testWidgets('Navigation bar renders without overflow at ${size.width.toInt()}px', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            theme: WebTheme.darkTheme,
            home: Scaffold(
              body: WebNavigationBar(
                activeIndex: 0,
                onSectionSelected: (_) {},
                onToggleTheme: () {},
                isDark: true,
                onOpenMobileMenu: () {},
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });
    }
  });

  group('All Sections Zero Overflow Test Across Breakpoints', () {
    for (final size in [
      const Size(320, 800),
      const Size(375, 800),
      const Size(768, 1024),
      const Size(1024, 768),
      const Size(1440, 900),
      const Size(1920, 1080),
    ]) {
      testWidgets('Sections render cleanly at ${size.width.toInt()}px', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            theme: WebTheme.darkTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    HeroSection(
                      data: mockData,
                      isDark: true,
                      onExploreProjects: () {},
                      onContactMe: () {},
                    ),
                    AboutSection(data: mockData, isDark: true),
                    SkillsSection(data: mockData, isDark: true),
                    ExperienceSection(data: mockData, isDark: true),
                    ProjectsSection(data: mockData, isDark: true),
                    EducationSection(data: mockData, isDark: true),
                    CertificatesSection(data: mockData, isDark: true),
                    ContactSection(data: mockData, isDark: true),
                    FooterSection(data: mockData, isDark: true, onScrollToTop: () {}),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
        // Unmount widget tree to cancel all internal timers
        await tester.pumpWidget(const SizedBox());
        // Drain any remaining in-flight timers so test framework is satisfied
        await tester.pump(const Duration(seconds: 5));
      });
    }
  });

  group('ExperienceSection Zero Overflow Detailed Widths Test', () {
    final detailedWidths = [320.0, 360.0, 480.0, 600.0, 768.0, 900.0, 1024.0, 1100.0, 1200.0, 1366.0, 1440.0, 1920.0];

    for (final width in detailedWidths) {
      testWidgets('ExperienceSection renders without overflow at ${width.toInt()}px', (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          MaterialApp(
            theme: WebTheme.darkTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: ExperienceSection(data: mockData, isDark: true),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 5));
      });
    }
  });
}
