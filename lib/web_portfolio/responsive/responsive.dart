import 'package:flutter/material.dart';

/// Centralized device classification for the entire Web Portfolio.
enum DeviceType {
  mobile,       // < 600px
  tablet,       // 600px - 900px
  laptop,       // 900px - 1200px
  desktop,      // 1200px - 1600px
  largeDesktop, // > 1600px
}

/// Centralized responsive breakpoint constants and detection methods.
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  static const double mobile       = 600.0;
  static const double tablet       = 900.0;
  static const double laptop       = 1200.0;
  static const double desktop      = 1600.0;

  static const double maxContentWidth = 1240.0;
  static const double navBarHeight    = 76.0;

  /// Returns current DeviceType from BuildContext MediaQuery
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return getDeviceTypeFromWidth(width);
  }

  /// Returns DeviceType from a specific pixel width (e.g. from LayoutBuilder)
  static DeviceType getDeviceTypeFromWidth(double width) {
    if (width < mobile) return DeviceType.mobile;
    if (width < tablet) return DeviceType.tablet;
    if (width < laptop) return DeviceType.laptop;
    if (width < desktop) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobile && width < tablet;
  }

  static bool isLaptop(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tablet && width < laptop;
  }

  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= laptop && width < desktop;
  }

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  /// Returns true for mobile and tablet (< 900px) where compact navigation (drawer) is required.
  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tablet;

  /// Returns true if width is wide enough for full horizontal navbar (> 1100px)
  static bool canFitFullNavbar(double width) => width >= 1100.0;
}

/// Centralized spacing design tokens. Eliminates magic numbers throughout the web portfolio.
class ResponsiveSpacing {
  ResponsiveSpacing._();

  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 16.0;
  static const double lg   = 24.0;
  static const double xl   = 32.0;
  static const double xxl  = 48.0;
  static const double xxxl = 64.0;

  // Responsive Gap Widgets
  static const Widget vXs  = SizedBox(height: xs);
  static const Widget vSm  = SizedBox(height: sm);
  static const Widget vMd  = SizedBox(height: md);
  static const Widget vLg  = SizedBox(height: lg);
  static const Widget vXl  = SizedBox(height: xl);
  static const Widget v2Xl = SizedBox(height: xxl);
  static const Widget v3Xl = SizedBox(height: xxxl);

  static const Widget hXs  = SizedBox(width: xs);
  static const Widget hSm  = SizedBox(width: sm);
  static const Widget hMd  = SizedBox(width: md);
  static const Widget hLg  = SizedBox(width: lg);
  static const Widget hXl  = SizedBox(width: xl);
  static const Widget h2Xl = SizedBox(width: xxl);

  /// Vertical padding for page sections
  static double sectionPadding(BuildContext context) {
    final type = ResponsiveBreakpoints.getDeviceType(context);
    switch (type) {
      case DeviceType.mobile:
        return 36.0;
      case DeviceType.tablet:
        return 48.0;
      case DeviceType.laptop:
        return 64.0;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return 80.0;
    }
  }

  /// Horizontal padding for sections and containers
  static double horizontalPadding(BuildContext context) {
    final type = ResponsiveBreakpoints.getDeviceType(context);
    switch (type) {
      case DeviceType.mobile:
        return 16.0;
      case DeviceType.tablet:
        return 28.0;
      case DeviceType.laptop:
        return 40.0;
      case DeviceType.desktop:
      case DeviceType.largeDesktop:
        return 52.0;
    }
  }
}

/// Helper to declare breakpoint-specific values cleanly without if/else spaghetti.
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? laptop;
  final T? desktop;
  final T? largeDesktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.laptop,
    this.desktop,
    this.largeDesktop,
  });

  T resolve(BuildContext context) {
    final type = ResponsiveBreakpoints.getDeviceType(context);
    switch (type) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.laptop:
        return laptop ?? tablet ?? desktop ?? mobile;
      case DeviceType.desktop:
        return desktop ?? laptop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? laptop ?? tablet ?? mobile;
    }
  }

  T resolveFromWidth(double width) {
    final type = ResponsiveBreakpoints.getDeviceTypeFromWidth(width);
    switch (type) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.laptop:
        return laptop ?? tablet ?? desktop ?? mobile;
      case DeviceType.desktop:
        return desktop ?? laptop ?? tablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? laptop ?? tablet ?? mobile;
    }
  }
}

/// Builder widget that supplies constraints and device type dynamically.
typedef ResponsiveWidgetBuilder = Widget Function(
  BuildContext context,
  DeviceType deviceType,
  BoxConstraints constraints,
);

class ResponsiveBuilder extends StatelessWidget {
  final ResponsiveWidgetBuilder? builder;
  final Widget? mobile;
  final Widget? tablet;
  final Widget? laptop;
  final Widget? desktop;
  final Widget? largeDesktop;

  const ResponsiveBuilder({
    super.key,
    this.builder,
    this.mobile,
    this.tablet,
    this.laptop,
    this.desktop,
    this.largeDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        final deviceType = ResponsiveBreakpoints.getDeviceTypeFromWidth(effectiveWidth);

        if (builder != null) {
          return builder!(context, deviceType, constraints);
        }

        switch (deviceType) {
          case DeviceType.mobile:
            return mobile ?? tablet ?? laptop ?? desktop ?? const SizedBox.shrink();
          case DeviceType.tablet:
            return tablet ?? mobile ?? laptop ?? desktop ?? const SizedBox.shrink();
          case DeviceType.laptop:
            return laptop ?? desktop ?? tablet ?? mobile ?? const SizedBox.shrink();
          case DeviceType.desktop:
            return desktop ?? laptop ?? tablet ?? mobile ?? const SizedBox.shrink();
          case DeviceType.largeDesktop:
            return largeDesktop ?? desktop ?? laptop ?? tablet ?? mobile ?? const SizedBox.shrink();
        }
      },
    );
  }
}

/// Adaptive container that centers children within maxContentWidth and applies responsive margins.
class ResponsiveContentContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveContentContainer({
    super.key,
    required this.child,
    this.maxWidth = ResponsiveBreakpoints.maxContentWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = ResponsiveSpacing.horizontalPadding(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: hPad),
          child: child,
        ),
      ),
    );
  }
}

/// Dynamic grid layout that automatically adjusts column count based on maxCrossAxisExtent.
/// Guarantees zero RenderFlex overflows across any display width.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double maxCrossAxisExtent;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.maxCrossAxisExtent = 380.0,
    this.mainAxisSpacing = 20.0,
    this.crossAxisSpacing = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        if (availableWidth <= 0) return const SizedBox.shrink();

        // Calculate columns: at least 1 column, up to however many fit
        int columns = (availableWidth / maxCrossAxisExtent).floor();
        if (columns < 1) columns = 1;

        // On very narrow screens (< 600), always 1 column
        if (availableWidth < ResponsiveBreakpoints.mobile) {
          columns = 1;
        }

        if (columns == 1) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) SizedBox(height: mainAxisSpacing),
              ],
            ],
          );
        }

        // Distribute children across rows
        final rows = <Widget>[];
        for (int i = 0; i < children.length; i += columns) {
          final rowChildren = <Widget>[];
          for (int c = 0; c < columns; c++) {
            if (i + c < children.length) {
              rowChildren.add(
                Expanded(
                  child: children[i + c],
                ),
              );
            } else {
              rowChildren.add(const Expanded(child: SizedBox.shrink()));
            }

            if (c < columns - 1) {
              rowChildren.add(SizedBox(width: crossAxisSpacing));
            }
          }

          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rowChildren,
            ),
          );

          if (i + columns < children.length) {
            rows.add(SizedBox(height: mainAxisSpacing));
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}

/// Provides safe typographic scaling that prevents text overflow on ultra-small screens.
class ResponsiveTextScale {
  ResponsiveTextScale._();

  static double fontMultiplier(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 360) return 0.88;
    if (width < 400) return 0.94;
    if (width < 768) return 1.0;
    if (width < 1200) return 1.04;
    return 1.08;
  }
}
