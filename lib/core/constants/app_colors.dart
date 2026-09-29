import 'dart:ui';

abstract class AppColors {
  static const primary = Color(0xFF1A1A1A);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFFAFAF9);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF888888);
  static const border = Color(0xFFE2E0DB);
  static const mediaBackground = Color(0xFFF2F3F3);
  static const error = Color(0xFFE24B4A);

  // ── Pebble header & mega menu ─────────────────────────────────
  /// Warm off-white used when header is at top of page (transparent feel)
  static const headerBgTop = Color(0xFFFFFDF7);

  /// Solid white once scrolled
  static const headerBgScrolled = Color(0xFFFFFFFF);

  /// Warm antique/block color for mega menu background
  static const megaMenuBg = Color(0xFFF5F0E8);

  /// Slightly warmer tone for mega menu hover states
  static const megaMenuHover = Color(0xFFEDE6D8);

  /// Warm accent (gold/copper) for decorative elements
  static const accentWarm = Color(0xFFC8A26D);

  /// Lighter warm tone for divider lines in mega menu
  static const warmBorder = Color(0xFFE8E2D6);

  /// Soft pebble icon color
  static const pebbleIcon = Color(0xFFB8A88A);

  // ── Shopify Pebble Theme Palette ──────────────────────────────
  /// Warm terracotta hero background matching Wrapped in Warmth portrait
  static const heroWarmTerracotta = Color(0xFFC99484);

  /// Secondary warm peach hero background
  static const heroWarmPeach = Color(0xFFD2A89B);

  /// Pill button & badge dark background
  static const pillDark = Color(0xFF111111);

  /// Pill button pure white background
  static const pillWhite = Color(0xFFFFFFFF);

  /// Sage green badge/accent
  static const sageGreen = Color(0xFF5BA86D);

  /// Warm ochre badge/accent
  static const warmOchre = Color(0xFFD4A373);
}
