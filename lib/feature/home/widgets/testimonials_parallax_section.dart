import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';

/// 1:1 Pixel-Perfect Implementation of Shopify Pebble "Testimonials Parallax"
/// Section: "What customers say - Over 500 Happy Reviews"
/// (template--20816638214282__testimonials_parallax_8FqTjk).
///
/// Features:
/// - Soft pastel ice-blue canvas (`color-scheme-9`: `#E1ECF4`)
/// - Desktop: Big Container (~2980px tall) where:
///   - Review cards are positioned on both left and right sides (and center)
///   - Section header ("What customers say / Over 500 Happy Reviews") stays
///     sticky in the center of the viewport, gliding from top to bottom of the container
///   - Center cards (Chloe M., Dylan P.) scroll through the center in front of the text
///   - Staggered rhythm:
///     - Top: Card 1 (Left) & Card 2 (Right) with Sticky Header in center; Card 3 peeking below
///     - Middle: Card 3 scrolls through center; Card 4 (Left) & Card 5 (Right) flank the sticky text; Card 6 peeking below
///     - Bottom: Card 6 scrolls through center; Card 7 (Left) & Card 8 (Right) finish the section
/// - Mobile: Centered static header on top with horizontal swipeable carousel
/// - Card design: 1:1 square photo, quote in double quotes, author name, mini product thumbnail + title
class TestimonialsParallaxSection extends StatefulWidget {
  final TestimonialsParallaxModel testimonialsData;

  const TestimonialsParallaxSection({
    super.key,
    required this.testimonialsData,
  });

  @override
  State<TestimonialsParallaxSection> createState() =>
      _TestimonialsParallaxSectionState();
}

class _TestimonialsParallaxSectionState
    extends State<TestimonialsParallaxSection> {
  ScrollPosition? _scrollPosition;
  final ValueNotifier<double> _stickyHeaderYNotifier =
      ValueNotifier<double>(220.0);
  final ValueNotifier<double> _scrollProgressNotifier =
      ValueNotifier<double>(0.0);
  late final PageController _mobilePageController;
  int _currentMobileIndex = 0;
  double? _cachedSectionContentY;
  double? _lastSectionHeight;

  static const double _desktopContainerHeight = 2980.0;
  static const double _headerHeight = 180.0;

  @override
  void initState() {
    super.initState();
    _mobilePageController = PageController(viewportFraction: 0.86);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedSectionContentY = null;
    _lastSectionHeight = null;
    final newPosition = Scrollable.maybeOf(context)?.position;
    if (newPosition != _scrollPosition) {
      _scrollPosition?.removeListener(_onScroll);
      _scrollPosition = newPosition;
      _scrollPosition?.addListener(_onScroll);
      WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
    }
  }

  @override
  void didUpdateWidget(covariant TestimonialsParallaxSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.testimonialsData != widget.testimonialsData) {
      _cachedSectionContentY = null;
      _lastSectionHeight = null;
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_onScroll);
    _stickyHeaderYNotifier.dispose();
    _scrollProgressNotifier.dispose();
    _mobilePageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;

    // Mobile layout uses horizontal PageView carousel, not vertical parallax
    if (MediaQuery.sizeOf(context).width < 900) return;

    final currentPixels = _scrollPosition?.pixels ?? 0.0;

    // Cache section content coordinate relative to scrollable; lazy-evaluated only once
    if (_cachedSectionContentY == null || _lastSectionHeight == null) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.attached || !renderBox.hasSize) return;
      _lastSectionHeight = renderBox.size.height;
      _cachedSectionContentY =
          currentPixels + renderBox.localToGlobal(Offset.zero).dy;
    }

    final sectionHeight = _lastSectionHeight!;
    final globalOffsetY = _cachedSectionContentY! - currentPixels;
    final viewportHeight = MediaQuery.sizeOf(context).height;

    // Offscreen cull: skip calculations when section is completely outside viewport
    if (globalOffsetY > viewportHeight + 100 || globalOffsetY < -sectionHeight - 100) {
      return;
    }

    // Calculate where the header should sit locally so that its center aligns with viewportHeight / 2
    final desiredY =
        (viewportHeight / 2 - _headerHeight / 2) - globalOffsetY;

    // Clamp between top padding and bottom of container
    const minY = 60.0;
    final maxY = sectionHeight - _headerHeight - 60.0;
    final clampedY = desiredY.clamp(minY, maxY);

    final progress =
        (-globalOffsetY / (sectionHeight - viewportHeight))
            .clamp(-1.0, 2.0);

    if ((clampedY - _stickyHeaderYNotifier.value).abs() > 0.5) {
      _stickyHeaderYNotifier.value = clampedY;
    }
    if ((progress - _scrollProgressNotifier.value).abs() > 0.005) {
      _scrollProgressNotifier.value = progress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;
    final testimonials = widget.testimonialsData.testimonials;

    if (testimonials.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      color: const Color(0xFFE1ECF4), // Shopify color-scheme-9 background
      child: isDesktop
          ? _buildDesktopLayout(testimonials, screenWidth)
          : _buildMobileLayout(testimonials),
    );
  }

  /// Desktop: Big Container with Sticky Center Header and Staggered Flanking Cards
  Widget _buildDesktopLayout(
    List<TestimonialItemModel> testimonials,
    double screenWidth,
  ) {
    // Card width clamped between 280 and 330px
    final cardWidth = (screenWidth * 0.22).clamp(280.0, 330.0);
    // Horizontal margin from screen edge or max container width
    final maxContainerWidth = 1440.0;
    final contentWidth = screenWidth.clamp(900.0, maxContainerWidth);
    final baseSideMargin = (screenWidth - contentWidth) / 2;
    final horizontalMargin = baseSideMargin + 44.0;

    // Map testimonials by order / index
    TestimonialItemModel? itemAt(int index) =>
        index < testimonials.length ? testimonials[index] : null;

    final card1 = itemAt(0); // Left: Tony S.
    final card2 = itemAt(1); // Right: Juniper
    final card3 = itemAt(2); // Center: Chloe M.
    final card4 = itemAt(3); // Left: Amanda B.
    final card5 = itemAt(4); // Right: Brian S.
    final card6 = itemAt(5); // Center: Dylan P.
    final card7 = itemAt(6); // Left: Lena M.
    final card8 = itemAt(7); // Right: Amanda B.

    return SizedBox(
      height: _desktopContainerHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Layer 1 (Back): Sticky Center Header ────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ValueListenableBuilder<double>(
              valueListenable: _stickyHeaderYNotifier,
              builder: (context, stickyY, child) {
                return Transform.translate(
                  offset: Offset(0, stickyY),
                  child: child,
                );
              },
              child: Center(
                child: SizedBox(
                  width: 540,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tag
                      Text(
                        widget.testimonialsData.tag.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Display Heading
                      Text(
                        widget.testimonialsData.heading,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 54,
                          fontWeight: FontWeight.w800,
                          height: 1.10,
                          letterSpacing: -1.0,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Layer 2 (Front): Center Column Cards (Chloe M. & Dylan P.) ──
          if (card3 != null)
            Positioned(
              top: 680.0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<double>(
                valueListenable: _scrollProgressNotifier,
                builder: (context, progress, child) {
                  final centerParallax = (progress * -25.0).clamp(-30.0, 30.0);
                  return Transform.translate(
                    offset: Offset(0, centerParallax),
                    child: child,
                  );
                },
                child: Center(
                  child: SizedBox(
                    width: cardWidth,
                    child: _TestimonialCard(testimonial: card3),
                  ),
                ),
              ),
            ),

          if (card6 != null)
            Positioned(
              top: 1780.0,
              left: 0,
              right: 0,
              child: ValueListenableBuilder<double>(
                valueListenable: _scrollProgressNotifier,
                builder: (context, progress, child) {
                  final centerParallax = (progress * -25.0).clamp(-30.0, 30.0);
                  return Transform.translate(
                    offset: Offset(0, centerParallax),
                    child: child,
                  );
                },
                child: Center(
                  child: SizedBox(
                    width: cardWidth,
                    child: _TestimonialCard(testimonial: card6),
                  ),
                ),
              ),
            ),

          // ── Layer 3 (Front): Left Column Cards (Tony S., Amanda B., Lena M.) ──
          if (card1 != null)
            Positioned(
              top: 40.0,
              left: horizontalMargin,
              child: ValueListenableBuilder<double>(
                valueListenable: _scrollProgressNotifier,
                builder: (context, progress, child) {
                  final leftParallax = (progress * 30.0).clamp(-40.0, 40.0);
                  return Transform.translate(
                    offset: Offset(0, leftParallax),
                    child: child,
                  );
                },
                child: SizedBox(
                  width: cardWidth,
                  child: _TestimonialCard(testimonial: card1),
                ),
              ),
            ),

          if (card4 != null)
            Positioned(
              top: 1120.0,
              left: horizontalMargin,
              child: ValueListenableBuilder<double>(
                valueListenable: _scrollProgressNotifier,
                builder: (context, progress, child) {
                  final leftParallax = (progress * 30.0).clamp(-40.0, 40.0);
                  return Transform.translate(
                    offset: Offset(0, leftParallax),
                    child: child,
                  );
                },
                child: SizedBox(
                  width: cardWidth,
                  child: _TestimonialCard(testimonial: card4),
                ),
              ),
            ),

          if (card7 != null)
            Positioned(
              top: 2220.0,
              left: horizontalMargin,
              child: ValueListenableBuilder<double>(
                valueListenable: _scrollProgressNotifier,
                builder: (context, progress, child) {
                  final leftParallax = (progress * 30.0).clamp(-40.0, 40.0);
                  return Transform.translate(
                    offset: Offset(0, leftParallax),
                    child: child,
                  );
                },
                child: SizedBox(
                  width: cardWidth,
                  child: _TestimonialCard(testimonial: card7),
                ),
              ),
            ),

          // ── Layer 4 (Front): Right Column Cards (Juniper, Brian S., Amanda B.) ──
          if (card2 != null)
            Positioned(
              top: 220.0,
              right: horizontalMargin,
              child: ValueListenableBuilder<double>(
                valueListenable: _scrollProgressNotifier,
                builder: (context, progress, child) {
                  final rightParallax = (progress * 40.0).clamp(-40.0, 40.0);
                  return Transform.translate(
                    offset: Offset(0, rightParallax),
                    child: child,
                  );
                },
                child: SizedBox(
                  width: cardWidth,
                  child: _TestimonialCard(testimonial: card2),
                ),
              ),
            ),

          if (card5 != null)
            Positioned(
              top: 1320.0,
              right: horizontalMargin,
              child: ValueListenableBuilder<double>(
                valueListenable: _scrollProgressNotifier,
                builder: (context, progress, child) {
                  final rightParallax = (progress * 40.0).clamp(-40.0, 40.0);
                  return Transform.translate(
                    offset: Offset(0, rightParallax),
                    child: child,
                  );
                },
                child: SizedBox(
                  width: cardWidth,
                  child: _TestimonialCard(testimonial: card5),
                ),
              ),
            ),

          if (card8 != null)
            Positioned(
              top: 2420.0,
              right: horizontalMargin,
              child: ValueListenableBuilder<double>(
                valueListenable: _scrollProgressNotifier,
                builder: (context, progress, child) {
                  final rightParallax = (progress * 40.0).clamp(-40.0, 40.0);
                  return Transform.translate(
                    offset: Offset(0, rightParallax),
                    child: child,
                  );
                },
                child: SizedBox(
                  width: cardWidth,
                  child: _TestimonialCard(testimonial: card8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Mobile: Static Header on Top with Horizontal Swipeable Carousel
  Widget _buildMobileLayout(List<TestimonialItemModel> testimonials) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header
          Text(
            widget.testimonialsData.tag.toUpperCase(),
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.testimonialsData.heading,
            textAlign: TextAlign.center,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.6,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 36),

          // Horizontal Carousel
          SizedBox(
            height: 520,
            child: PageView.builder(
              controller: _mobilePageController,
              itemCount: testimonials.length,
              onPageChanged: (index) {
                setState(() => _currentMobileIndex = index);
              },
              itemBuilder: (context, index) {
                final item = testimonials[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: _TestimonialCard(testimonial: item),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Dots Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(testimonials.length, (idx) {
              final isActive = idx == _currentMobileIndex;
              return GestureDetector(
                onTap: () {
                  _mobilePageController.animateToPage(
                    idx,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF0F172A).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// A Single Testimonial Card Widget (1:1 with Shopify Pebble Screenshot)
class _TestimonialCard extends StatefulWidget {
  final TestimonialItemModel testimonial;

  const _TestimonialCard({
    required this.testimonial,
  });

  @override
  State<_TestimonialCard> createState() => _TestimonialCardState();
}

class _TestimonialCardState extends State<_TestimonialCard> {
  bool _isCardHovered = false;
  bool _isProductHovered = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.testimonial;
    final product = t.product;

    return MouseRegion(
      onEnter: (_) => setState(() => _isCardHovered = true),
      onExit: (_) => setState(() => _isCardHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isCardHovered
                ? const Color(0xFFCBD5E1)
                : const Color(0xFFF1F5F9),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: _isCardHovered ? 0.09 : 0.05,
              ),
              blurRadius: _isCardHovered ? 20 : 12,
              offset: Offset(0, _isCardHovered ? 8 : 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 1:1 Square Review Photo ──────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: AnimatedScale(
                  scale: _isCardHovered ? 1.03 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: Image.network(
                    t.image,
                    fit: BoxFit.cover,
                    cacheWidth: 600,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFE2E8F0),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Review Quote (in double quotes) ──────────────────
            Text(
              '"${t.quote}"',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),

            // ── Author Name ──────────────────────────────────────
            Text(
              t.author,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),

            // ── Tagged Product Footer (Mini Thumbnail + Title) ───
            if (product != null) ...[
              const SizedBox(height: 12),
              const Divider(
                color: Color(0xFFF1F5F9),
                height: 1,
                thickness: 1,
              ),
              const SizedBox(height: 10),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => _isProductHovered = true),
                onExit: (_) => setState(() => _isProductHovered = false),
                child: GestureDetector(
                  onTap: () => context.go('/products/${product.slug}'),
                  child: Row(
                    children: [
                      // Mini Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          width: 34,
                          height: 34,
                          child: product.primaryImageUrl != null &&
                                  product.primaryImageUrl!.isNotEmpty
                              ? Image.network(
                                  product.primaryImageUrl!,
                                  fit: BoxFit.cover,
                                  cacheWidth: 100,
                                  gaplessPlayback: true,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          Container(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFFE2E8F0),
                                ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Product Title
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isProductHovered
                                ? const Color(0xFF0284C7)
                                : const Color(0xFF334155),
                            decoration: _isProductHovered
                                ? TextDecoration.underline
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
