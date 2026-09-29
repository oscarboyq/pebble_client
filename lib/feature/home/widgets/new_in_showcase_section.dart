import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';

class NewInShowcaseSection extends StatefulWidget {
  final List<ShowcaseCardModel> cards;
  final String ctaLink;
  final String ctaText;
  final bool showCta;

  const NewInShowcaseSection({
    super.key,
    required this.cards,
    this.ctaLink = '/collections/outerwear',
    this.ctaText = 'Shop Now',
    this.showCta = true,
  });

  @override
  State<NewInShowcaseSection> createState() => _NewInShowcaseSectionState();
}

class _NewInShowcaseSectionState extends State<NewInShowcaseSection> {
  ScrollPosition? _scrollPosition;
  final ValueNotifier<double> _scrollProgressNotifier = ValueNotifier<double>(
    0.0,
  );
  final ValueNotifier<double> _stickyOffsetNotifier = ValueNotifier<double>(
    0.0,
  );
  double? _cachedSectionContentY;
  double? _lastSectionHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedSectionContentY = null;
    _lastSectionHeight = null;
    final newPosition = Scrollable.maybeOf(context)?.position;
    if (newPosition != _scrollPosition) {
      _scrollPosition?.removeListener(_handleScroll);
      _scrollPosition = newPosition;
      _scrollPosition?.addListener(_handleScroll);
    }
  }

  @override
  void didUpdateWidget(covariant NewInShowcaseSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cards != widget.cards) {
      _cachedSectionContentY = null;
      _lastSectionHeight = null;
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_handleScroll);
    _scrollProgressNotifier.dispose();
    _stickyOffsetNotifier.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!mounted) return;

    // Mobile/tablet layout does not use the sticky center scroll animation
    if (MediaQuery.sizeOf(context).width < 980) return;

    final currentPixels = _scrollPosition?.pixels ?? 0.0;

    // Cache content coordinate relative to scrollable; lazy-evaluated only once
    if (_cachedSectionContentY == null || _lastSectionHeight == null) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.attached || !renderBox.hasSize) {
        return;
      }
      _lastSectionHeight = renderBox.size.height;
      _cachedSectionContentY =
          currentPixels + renderBox.localToGlobal(Offset.zero).dy;
    }

    final sectionHeight = _lastSectionHeight!;
    final positionInViewport = _cachedSectionContentY! - currentPixels;
    final viewportHeight = MediaQuery.sizeOf(context).height;

    // Offscreen cull: skip calculations when section is out of viewport
    if (positionInViewport > viewportHeight + 100 ||
        positionInViewport < -sectionHeight - 100) {
      return;
    }

    // Start point: when the section reaches ~35% of viewport
    // End point: when the section has scrolled through most of its height
    final startY = viewportHeight * 0.35;
    final totalRange = sectionHeight * 0.65;

    if (totalRange > 0) {
      final progress = ((startY - positionInViewport) / totalRange).clamp(
        0.0,
        1.0,
      );

      // Calculate sticky vertical translation for the center block so it
      // stays pinned in the middle while the cards on both sides scroll past
      const centerBlockHeight = 360.0;
      final maxStickDistance = (sectionHeight - centerBlockHeight - 160.0)
          .clamp(0.0, double.infinity);
      final stickOffset = (startY - positionInViewport).clamp(
        0.0,
        maxStickDistance,
      );

      if ((progress - _scrollProgressNotifier.value).abs() > 0.003) {
        _scrollProgressNotifier.value = progress;
      }
      if ((stickOffset - _stickyOffsetNotifier.value).abs() > 0.5) {
        _stickyOffsetNotifier.value = stickOffset;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isDesktop = availableWidth >= 980;
        final horizontalPadding = isDesktop ? 48.0 : 20.0;

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: isDesktop ? 60.0 : 36.0,
          ),
          child: isDesktop
              ? _buildDesktopZigZagLayout(
                  context,
                  availableWidth - horizontalPadding * 2,
                )
              : _buildMobileTabletLayout(context),
        );
      },
    );
  }

  // ── Desktop 3-Column Zig-Zag Layout (Sticky Center + Scrolling Cards) ──
  Widget _buildDesktopZigZagLayout(BuildContext context, double contentWidth) {
    // Left column cards: 0, 2, 4 (Stripe Shorts, Sneakers Green, Colorblock Backpack)
    final leftCards = <ShowcaseCardModel>[];
    // Right column cards: 1, 3, 5 (Colorblock Jacket, Fleece Hoodie, Campus Spirit E Cap)
    final rightCards = <ShowcaseCardModel>[];

    for (int i = 0; i < widget.cards.length; i++) {
      if (i % 2 == 0) {
        leftCards.add(widget.cards[i]);
      } else {
        rightCards.add(widget.cards[i]);
      }
    }

    final columnGap = 36.0;
    final sideColWidth = (contentWidth - columnGap * 2) / 3.15;
    final centerColWidth = sideColWidth * 1.15;
    final cardHeight = sideColWidth * 1.32;
    final contentHeight = math.max(
      leftCards.length * (cardHeight + 48.0),
      140.0 + rightCards.length * (cardHeight + 48.0),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left Column (Odd cards) ──────────────────────────────────
        SizedBox(
          width: sideColWidth,
          child: Column(
            children: leftCards
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 48.0),
                    child: _ShowcaseCardItem(card: c, width: sideColWidth),
                  ),
                )
                .toList(),
          ),
        ),
        SizedBox(width: columnGap),

        // ── Center Sticky Column (Pinned & Text Transitions on Scroll) ─
        SizedBox(
          width: centerColWidth,
          // The sticky block paints lower as the page scrolls. Its parent must
          // cover that space or Flutter will reject taps outside its bounds.
          height: contentHeight,
          child: ValueListenableBuilder<double>(
            valueListenable: _stickyOffsetNotifier,
            builder: (context, stickyOffset, _) {
              return Transform.translate(
                offset: Offset(0, stickyOffset),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 40.0,
                  ),
                  child: ValueListenableBuilder<double>(
                    valueListenable: _scrollProgressNotifier,
                    builder: (context, progress, _) {
                      return _CenterHeadlineBlock(
                        scrollProgress: progress,
                        ctaLink: widget.ctaLink,
                        ctaText: widget.ctaText,
                        showCta: widget.showCta,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(width: columnGap),

        // ── Right Column (Even cards with 140px Zig-Zag Offset) ───────
        SizedBox(
          width: sideColWidth,
          child: Padding(
            padding: const EdgeInsets.only(top: 140.0), // Pebble zig-zag offset
            child: Column(
              children: rightCards
                  .map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: 48.0),
                      child: _ShowcaseCardItem(card: c, width: sideColWidth),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile / Tablet Responsive Fallback ─────────────────────────────
  Widget _buildMobileTabletLayout(BuildContext context) {
    return Column(
      children: [
        ValueListenableBuilder<double>(
          valueListenable: _scrollProgressNotifier,
          builder: (context, progress, _) {
            return _CenterHeadlineBlock(
              scrollProgress: progress,
              ctaLink: widget.ctaLink,
              ctaText: widget.ctaText,
              showCta: widget.showCta,
            );
          },
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 390,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: widget.cards.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return _ShowcaseCardItem(card: widget.cards[index], width: 260);
            },
          ),
        ),
      ],
    );
  }
}

// ── Center Block: NEW IN + Scroll-Transitioning Headlines + Shop Now > ──
class _CenterHeadlineBlock extends StatefulWidget {
  final double scrollProgress;
  final String ctaLink;
  final String ctaText;
  final bool showCta;

  const _CenterHeadlineBlock({
    required this.scrollProgress,
    required this.ctaLink,
    required this.ctaText,
    required this.showCta,
  });

  @override
  State<_CenterHeadlineBlock> createState() => _CenterHeadlineBlockState();
}

class _CenterHeadlineBlockState extends State<_CenterHeadlineBlock> {
  bool _btnHovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── 1. "NEW IN" Title (Clean uppercase text) ───────────────
        Text(
          'NEW IN',
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: const Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 18),

        // ── 2. Scroll-Driven Clipped Headline Window ────────────────
        // Shows 1 headline at a time; translates vertically as user scrolls
        _ClippedHeadingsWindow(scrollProgress: widget.scrollProgress),
        const SizedBox(height: 18),

        // ── 3. Subtitle Description ─────────────────────────────────
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            'Easy, breathable pieces designed\nfor everyday play, made to feel light, comfy.',
            textAlign: TextAlign.center,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: const Color(0xFF555555),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // ── 4. "Shop Now >" Black Pill Button with Circular Icon ────
        if (widget.showCta)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _btnHovered = true),
            onExit: (_) => setState(() => _btnHovered = false),
            child: InkWell(
              onTap: () => context.go(widget.ctaLink),
              borderRadius: BorderRadius.circular(30),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                scale: _btnHovered ? 1.04 : 1.0,
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.only(left: 24, right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: _btnHovered
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.22),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.ctaText,
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 14),
                      // White circular badge containing black chevron >
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: Color(0xFF111111),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Clipped Window that Translates Headlines on Scroll ────────────────
class _ClippedHeadingsWindow extends StatelessWidget {
  final double scrollProgress;

  const _ClippedHeadingsWindow({required this.scrollProgress});

  @override
  Widget build(BuildContext context) {
    const headlineHeight = 96.0;
    // 3 headlines: Headline 1 -> Headline 2 -> Headline 3
    // Total translation distance = headlineHeight * 2
    final translateY = -scrollProgress * (headlineHeight * 2.0);

    return SizedBox(
      height: headlineHeight,
      child: ClipRect(
        child: OverflowBox(
          minHeight: headlineHeight * 3,
          maxHeight: headlineHeight * 3,
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Headline 1: Soft & playful, this sweet lilac ────
                _HeadlineItem(
                  height: headlineHeight,
                  firstLine: 'Soft & playful,',
                  secondLinePre: 'this ',
                  highlightText: 'sweet lilac',
                  highlightColor: const Color(0xFFDCD3FF), // Lilac purple
                ),

                // ── Headline 2: Bright & airy, this light blue ──────
                _HeadlineItem(
                  height: headlineHeight,
                  firstLine: 'Bright & airy,',
                  secondLinePre: 'this ',
                  highlightText: 'light blue',
                  highlightColor: const Color(0xFFBDE6EE), // Sky blue
                ),

                // ── Headline 3: Warm & joyful, this sweet pink ──────
                _HeadlineItem(
                  height: headlineHeight,
                  firstLine: 'Warm & joyful,',
                  secondLinePre: 'this ',
                  highlightText: 'sweet pink',
                  highlightColor: const Color(0xFFFFD0DC), // Sweet pink
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Single Headline with Colored Highlight Block ──────────────────────
class _HeadlineItem extends StatelessWidget {
  final double height;
  final String firstLine;
  final String secondLinePre;
  final String highlightText;
  final Color highlightColor;

  const _HeadlineItem({
    required this.height,
    required this.firstLine,
    required this.secondLinePre,
    required this.highlightText,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.8,
              color: const Color(0xFF111111),
            ),
            children: [
              TextSpan(text: '$firstLine\n$secondLinePre'),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: highlightColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    highlightText,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                      color: const Color(0xFF111111),
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

// ── Single Showcase Card with Pixel-Perfect "Shop" Pill Button ────────
class _ShowcaseCardItem extends StatefulWidget {
  final ShowcaseCardModel card;
  final double width;

  const _ShowcaseCardItem({required this.card, required this.width});

  @override
  State<_ShowcaseCardItem> createState() => _ShowcaseCardItemState();
}

class _ShowcaseCardItemState extends State<_ShowcaseCardItem> {
  bool _cardHovered = false;
  bool _btnHovered = false;

  @override
  Widget build(BuildContext context) {
    final cardHeight = widget.width * 1.32; // Aspect ratio ~ 0.75

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _cardHovered = true),
      onExit: (_) => setState(() => _cardHovered = false),
      child: GestureDetector(
        onTap: () {
          if (widget.card.productLink.isNotEmpty) {
            context.go(widget.card.productLink);
          } else {
            context.go(AppRoutes.home);
          }
        },
        child: SizedBox(
          width: widget.width,
          height: cardHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Main Lifestyle Image with Smooth Hover Zoom ───────
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 360),
                  curve: Curves.easeOutCubic,
                  scale: _cardHovered ? 1.045 : 1.0,
                  child: widget.card.lifestyleImage.isNotEmpty
                      ? Image.network(
                          widget.card.lifestyleImage,
                          fit: BoxFit.cover,
                          cacheWidth: 600,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: const Color(0xFFEBE7DF),
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              ),
                        )
                      : Container(color: const Color(0xFFEBE7DF)),
                ),
              ),

              // ── Floating Frosted Glassmorphism Product Overlay ────
              Positioned(
                bottom: 14,
                left: 14,
                right: 14,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.38),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Product Thumbnail Square with white backing
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 46,
                              height: 46,
                              color: Colors.white,
                              child: widget.card.thumbnailImage.isNotEmpty
                                  ? Image.network(
                                      widget.card.thumbnailImage,
                                      fit: BoxFit.cover,
                                      cacheWidth: 120,
                                      gaplessPlayback: true,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Product Title and Price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.card.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.bricolageGrotesque(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '\$${widget.card.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.bricolageGrotesque(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Pixel-Perfect White "Shop" Pill Button with Inversion on Hover ──
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            onEnter: (_) => setState(() => _btnHovered = true),
                            onExit: (_) => setState(() => _btnHovered = false),
                            child: GestureDetector(
                              onTap: () {
                                if (widget.card.productLink.isNotEmpty) {
                                  context.go(widget.card.productLink);
                                } else {
                                  context.go(AppRoutes.home);
                                }
                              },
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                                scale: _btnHovered ? 1.05 : 1.0,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _btnHovered
                                        ? const Color(0xFF111111)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: _btnHovered
                                          ? const Color(0xFF111111)
                                          : Colors.white.withValues(alpha: 0.9),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: _btnHovered ? 0.25 : 0.12,
                                        ),
                                        blurRadius: _btnHovered ? 12 : 6,
                                        offset: Offset(0, _btnHovered ? 4 : 2),
                                      ),
                                    ],
                                  ),
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 180),
                                    style: GoogleFonts.bricolageGrotesque(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: _btnHovered
                                          ? Colors.white
                                          : const Color(0xFF111111),
                                      letterSpacing: -0.1,
                                    ),
                                    child: const Text('Shop'),
                                  ),
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
      ),
    );
  }
}
