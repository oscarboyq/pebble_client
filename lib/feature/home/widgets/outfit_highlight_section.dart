import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:pebble_type/core/routes/app_router.dart';
import '../models/home_model.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// "Outfit For" Interactive Collection Highlight Section
/// Matches Shopify Pebble `collection_highlight_YV6p8F` 1:1.
/// Features:
///  - 2-column layout (50/50 desktop, stacked on mobile).
///  - Left Column: Dynamic Lifestyle Image Card with cross-fade switching,
///    subheading, headline, and "Shop Now >" pill button with hover animation.
///  - Right Column: Pastel Lime `#F1F3C0` Card with "OUTFIT FOR" badge,
///    titles ("Move", "Glow", "Study", "Roam") with 100ms hover debounce,
///    vector wavy underline, and popping circular thumbnail badge.
///  - Bottom collection description cross-fades smoothly on tab change.
/// ─────────────────────────────────────────────────────────────────────────────
class OutfitHighlightSection extends StatefulWidget {
  final List<OutfitHighlightModel> items;

  const OutfitHighlightSection({
    super.key,
    required this.items,
  });

  @override
  State<OutfitHighlightSection> createState() => _OutfitHighlightSectionState();
}

class _OutfitHighlightSectionState extends State<OutfitHighlightSection> {
  int _activeIndex = 0;
  Timer? _hoverDebounceTimer;

  // Fallback items if backend list is empty
  static final List<OutfitHighlightModel> _defaultItems = [
    OutfitHighlightModel(
      id: 1,
      title: 'Move',
      subheading: 'Move collection',
      heading: 'Made to Move,\nBuilt for Comfort',
      description:
          'The feeling of getting home from work to find the sun still shining.',
      thumbnailImage:
          'http://127.0.0.1:8000/media/highlight_images/move_thumb.jpg',
      lifestyleImage:
          'http://127.0.0.1:8000/media/highlight_images/move_lifestyle.jpg',
      buttonText: 'Shop Now',
      linkUrl: '/collections/shirts',
      order: 0,
    ),
    OutfitHighlightModel(
      id: 2,
      title: 'Glow',
      subheading: 'Glow collection',
      heading: 'Save Up to 30%,\nComfort You Love',
      description:
          'Cozy pieces made for daily comfort, with up to 30% off selected styles for a limited time.',
      thumbnailImage:
          'http://127.0.0.1:8000/media/highlight_images/glow_thumb.jpg',
      lifestyleImage:
          'http://127.0.0.1:8000/media/highlight_images/glow_lifestyle.jpg',
      buttonText: 'Shop Now',
      linkUrl: '/collections/coats-jackets',
      order: 1,
    ),
    OutfitHighlightModel(
      id: 3,
      title: 'Study',
      subheading: 'Study collection',
      heading: 'Clean Styles Made for Focused Days',
      description:
          'Designed for comfort and ease, these pieces support every moment from study.',
      thumbnailImage:
          'http://127.0.0.1:8000/media/highlight_images/study_thumb.jpg',
      lifestyleImage:
          'http://127.0.0.1:8000/media/highlight_images/study_lifestyle.jpg',
      buttonText: 'Shop Now',
      linkUrl: '/collections/accessories',
      order: 2,
    ),
    OutfitHighlightModel(
      id: 4,
      title: 'Roam',
      subheading: 'Roam collection',
      heading: 'Ready to Roam,\nMade for Play',
      description:
          'Soft, easy outfits that keep up with every little adventure, from backyard to big fun.',
      thumbnailImage:
          'http://127.0.0.1:8000/media/highlight_images/roam_thumb.jpg',
      lifestyleImage:
          'http://127.0.0.1:8000/media/highlight_images/roam_lifestyle.jpg',
      buttonText: 'Shop Now',
      linkUrl: '/collections/sweaters',
      order: 3,
    ),
  ];

  List<OutfitHighlightModel> get _effectiveItems =>
      widget.items.isNotEmpty ? widget.items : _defaultItems;

  @override
  void dispose() {
    _hoverDebounceTimer?.cancel();
    super.dispose();
  }

  void _onItemHoverEnter(int index) {
    _hoverDebounceTimer?.cancel();
    // 100ms debounce matching Shopify pebble theme.js
    _hoverDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted && _activeIndex != index) {
        setState(() => _activeIndex = index);
      }
    });
  }

  void _onItemHoverExit() {
    _hoverDebounceTimer?.cancel();
  }

  void _onItemSelect(int index) {
    _hoverDebounceTimer?.cancel();
    if (_activeIndex != index) {
      setState(() => _activeIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _effectiveItems;
    final activeItem = items[_activeIndex.clamp(0, items.length - 1)];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 48),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;

              if (isDesktop) {
                final cardWidth = (constraints.maxWidth - 20) / 2;
                final cardHeight = cardWidth; // 1:1 aspect ratio matching Shopify theme

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Lifestyle Image Card
                    SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _LifestyleImageCard(
                        key: ValueKey('lifestyle_${activeItem.id}'),
                        item: activeItem,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Right Column: Interactive Content Card
                    SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: _ContentCard(
                        items: items,
                        activeIndex: _activeIndex,
                        activeItem: activeItem,
                        onHoverEnter: _onItemHoverEnter,
                        onHoverExit: _onItemHoverExit,
                        onSelect: _onItemSelect,
                      ),
                    ),
                  ],
                );
              } else {
                // Mobile & Tablet: Stacked layout
                return Column(
                  children: [
                    // Lifestyle Image Card
                    AspectRatio(
                      aspectRatio: 1.05,
                      child: _LifestyleImageCard(
                        key: ValueKey('lifestyle_mobile_${activeItem.id}'),
                        item: activeItem,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Interactive Content Card
                    _ContentCard(
                      items: items,
                      activeIndex: _activeIndex,
                      activeItem: activeItem,
                      onHoverEnter: _onItemHoverEnter,
                      onHoverExit: _onItemHoverExit,
                      onSelect: _onItemSelect,
                      isMobile: true,
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Left Column: Lifestyle Image Card with Smooth Cross-Fade
/// ─────────────────────────────────────────────────────────────────────────────
class _LifestyleImageCard extends StatefulWidget {
  final OutfitHighlightModel item;

  const _LifestyleImageCard({
    super.key,
    required this.item,
  });

  @override
  State<_LifestyleImageCard> createState() => _LifestyleImageCardState();
}

class _LifestyleImageCardState extends State<_LifestyleImageCard> {
  bool _btnHovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Lifestyle Image
          if (item.lifestyleImage.isNotEmpty)
            Image.network(
              item.lifestyleImage,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              cacheWidth: 1000,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFE8E5DF),
                child: const Icon(Icons.broken_image, size: 48, color: Colors.black26),
              ),
            )
          else
            Container(color: const Color(0xFFE8E5DF)),

          // High-contrast gradient overlay for readable text
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.25),
                  Colors.black.withValues(alpha: 0.70),
                ],
                stops: const [0.0, 0.45, 0.70, 1.0],
              ),
            ),
          ),

          // Content at bottom-left
          Padding(
            padding: const EdgeInsets.all(36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Subheading (e.g. MOVE COLLECTION)
                if (item.subheading.isNotEmpty)
                  Text(
                    item.subheading.toUpperCase(),
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: Colors.white.withValues(alpha: 0.90),
                    ),
                  ),
                const SizedBox(height: 10),

                // Heading (e.g. Made to Move,\nBuilt for Comfort)
                Text(
                  item.heading,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 22),

                // "Shop Now >" Button with Circular Icon Badge
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _btnHovered = true),
                  onExit: (_) => setState(() => _btnHovered = false),
                  child: GestureDetector(
                    onTap: () {
                      if (item.linkUrl.isNotEmpty) {
                        context.go(item.linkUrl);
                      } else {
                        context.go(AppRoutes.home);
                      }
                    },
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      scale: _btnHovered ? 1.04 : 1.0,
                      child: Container(
                        padding: const EdgeInsets.only(
                          left: 24,
                          top: 8,
                          bottom: 8,
                          right: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: _btnHovered ? 0.30 : 0.15,
                              ),
                              blurRadius: _btnHovered ? 14 : 8,
                              offset: Offset(0, _btnHovered ? 4 : 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.buttonText.isNotEmpty
                                  ? item.buttonText
                                  : 'Shop Now',
                              style: GoogleFonts.bricolageGrotesque(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111111),
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Black Circle Badge with Animated Arrow
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutCubic,
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFF111111),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: AnimatedSlide(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutCubic,
                                  offset: _btnHovered
                                      ? const Offset(0.12, 0)
                                      : Offset.zero,
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Right Column: Interactive Content Card (Pale Lime #F1F3C0)
/// ─────────────────────────────────────────────────────────────────────────────
class _ContentCard extends StatelessWidget {
  final List<OutfitHighlightModel> items;
  final int activeIndex;
  final OutfitHighlightModel activeItem;
  final ValueChanged<int> onHoverEnter;
  final VoidCallback onHoverExit;
  final ValueChanged<int> onSelect;
  final bool isMobile;

  const _ContentCard({
    required this.items,
    required this.activeIndex,
    required this.activeItem,
    required this.onHoverEnter,
    required this.onHoverExit,
    required this.onSelect,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3C0), // Exactly RGB(241, 243, 192) from theme
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 44,
        vertical: isMobile ? 36 : 48,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── 1. Top Subheading: "OUTFIT FOR" ──
          Text(
            'OUTFIT FOR',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.2,
              color: const Color(0xFF111111),
            ),
          ),

          // ── 2. Middle Interactive Titles List ──
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == activeIndex;

              return _TitleTabRow(
                key: ValueKey('tab_${item.id}'),
                item: item,
                index: index,
                isActive: isActive,
                onHoverEnter: () => onHoverEnter(index),
                onHoverExit: onHoverExit,
                onSelect: () => onSelect(index),
                isMobile: isMobile,
              );
            }),
          ),

          // ── 3. Bottom Preview Collection Story ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey('preview_${activeItem.id}'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    activeItem.subheading,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111111),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Text(
                      activeItem.description,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.black.withValues(alpha: 0.65),
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Single Interactive Title Row with Wavy Underline & Scaling Thumbnail Badge
/// ─────────────────────────────────────────────────────────────────────────────
class _TitleTabRow extends StatelessWidget {
  final OutfitHighlightModel item;
  final int index;
  final bool isActive;
  final VoidCallback onHoverEnter;
  final VoidCallback onHoverExit;
  final VoidCallback onSelect;
  final bool isMobile;

  const _TitleTabRow({
    super.key,
    required this.item,
    required this.index,
    required this.isActive,
    required this.onHoverEnter,
    required this.onHoverExit,
    required this.onSelect,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final titleFontSize = isMobile ? 38.0 : 48.0;
    final double underlineWidth = switch (item.title) {
      'Move' => isMobile ? 95.0 : 120.0,
      'Glow' => isMobile ? 90.0 : 115.0,
      'Study' => isMobile ? 105.0 : 135.0,
      'Roam' => isMobile ? 100.0 : 130.0,
      _ => 110.0,
    };

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHoverEnter(),
      onExit: (_) => onHoverExit(),
      child: GestureDetector(
        onTap: onSelect,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Title Word ──
                  Text(
                    item.title,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w800,
                      color: isActive
                          ? const Color(0xFF111111)
                          : const Color(0xFF111111).withValues(alpha: 0.38),
                      letterSpacing: -1.0,
                      height: 1.1,
                    ),
                  ),

                  // ── Animated Circular Thumbnail Next to Word ──
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    width: isActive ? (isMobile ? 42.0 : 50.0) : 0.0,
                    height: isMobile ? 42.0 : 50.0,
                    margin: EdgeInsets.only(
                      left: isActive ? (isMobile ? 8.0 : 12.0) : 0.0,
                    ),
                    child: ClipOval(
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutBack,
                        scale: isActive ? 1.0 : 0.0,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 220),
                          opacity: isActive ? 1.0 : 0.0,
                          child: item.thumbnailImage.isNotEmpty
                              ? Image.network(
                                  item.thumbnailImage,
                                  fit: BoxFit.cover,
                                  cacheWidth: 200,
                                  gaplessPlayback: true,
                                  errorBuilder: (_, __, ___) => const ColoredBox(
                                    color: Color(0xFFFFD4DC),
                                    child: Icon(Icons.checkroom, size: 24, color: Colors.black54),
                                  ),
                                )
                              : const ColoredBox(
                                  color: Color(0xFFFFD4DC),
                                  child: Icon(Icons.checkroom, size: 24, color: Colors.black54),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Vector Wavy Underline under the title ──
              const SizedBox(height: 2),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                opacity: isActive ? 1.0 : 0.0,
                child: SizedBox(
                  width: underlineWidth,
                  height: 6,
                  child: CustomPaint(
                    painter: WavyUnderlinePainter(
                      color: const Color(0xFF111111),
                      strokeWidth: 2.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Vector Wavy Underline Painter
/// Renders a crisp vector sine wave matching the SVG curve from Pebble theme
/// ─────────────────────────────────────────────────────────────────────────────
class WavyUnderlinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const WavyUnderlinePainter({
    required this.color,
    this.strokeWidth = 2.8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    const wavelength = 11.5;
    const amplitude = 3.0;
    final midY = size.height / 2;

    path.moveTo(0, midY);

    for (double x = 0; x < size.width; x += wavelength) {
      final cp1X = x + wavelength / 4;
      final cp1Y = midY - amplitude;
      final cp2X = x + 3 * wavelength / 4;
      final cp2Y = midY + amplitude;
      final endX = (x + wavelength).clamp(0.0, size.width);
      final endY = midY;

      path.cubicTo(cp1X, cp1Y, cp2X, cp2Y, endX, endY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavyUnderlinePainter oldDelegate) =>
      color != oldDelegate.color || strokeWidth != oldDelegate.strokeWidth;
}
