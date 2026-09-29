import 'package:flutter/widgets.dart';

abstract class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 960;
  static const double desktop = 1280;
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  bool get isMobile => screenWidth < Breakpoints.mobile;
  bool get isTablet =>
      screenWidth >= Breakpoints.mobile && screenWidth < Breakpoints.desktop;
  bool get isDesktop => screenWidth >= Breakpoints.desktop;

  /// True when we should show the web header (tablet + desktop)
  bool get isWide => screenWidth >= Breakpoints.mobile;
}

class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext) mobile;
  final Widget Function(BuildContext)? tablet;
  final Widget Function(BuildContext)? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (width >= Breakpoints.desktop && desktop != null) {
          return desktop!(context);
        }
        if (width >= Breakpoints.mobile && tablet != null) {
          return tablet!(context);
        }
        return mobile(context);
      },
    );
  }
}

extension ResponsiveValue on BuildContext {
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop && desktop != null) return desktop;
    if (isWide && tablet != null) return tablet;
    return mobile;
  }
}
