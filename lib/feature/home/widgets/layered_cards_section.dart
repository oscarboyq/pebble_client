import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/widgets/auto_pause_visibility.dart';
import 'package:pebble_type/core/widgets/reveal_on_scroll.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';

/// 1:1 Pixel-Perfect Implementation of Shopify Pebble "Mix Your Style" /
/// "Feel good & enjoy every day" Layered Stacking Cards Section
/// (`template--20816638214282__scrolling_card_layered_hwEqKR`)
///
/// Features pure scroll-driven deck-of-cards stacking where Card 1 pins at top,
/// Card 2 scrolls up over Card 1 (with Card 0 scaling to 0.94), and Card 3 scrolls
/// up over Card 2 (leaving top edges visible in a stacked deck of cards).
class LayeredCardsSection extends StatefulWidget {
  final List<LayeredScrollingCardModel> cards;

  const LayeredCardsSection({
    super.key,
    required this.cards,
  });

  @override
  State<LayeredCardsSection> createState() => _LayeredCardsSectionState();
}

class _LayeredCardsSectionState extends State<LayeredCardsSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  final GlobalKey _cardsAreaKey = GlobalKey();
  ScrollPosition? _scrollPosition;
  final ValueNotifier<double> _scrollProgressNotifier =
      ValueNotifier<double>(0.0);
  bool _isVisible = true;
  double? _cachedCardsAreaContentY;
  double? _lastCardsAreaHeight;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollState());
  }

  void _onVisibilityChanged(bool isVisible) {
    _isVisible = isVisible;
    if (isVisible) {
      if (!_floatController.isAnimating) {
        _floatController.repeat(reverse: true);
      }
    } else {
      if (_floatController.isAnimating) {
        _floatController.stop();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedCardsAreaContentY = null;
    _lastCardsAreaHeight = null;
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _scrollPosition) {
      _scrollPosition?.removeListener(_updateScrollState);
      _scrollPosition = position;
      _scrollPosition?.addListener(_updateScrollState);
    }
  }

  @override
  void didUpdateWidget(covariant LayeredCardsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cards != widget.cards) {
      _cachedCardsAreaContentY = null;
      _lastCardsAreaHeight = null;
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_updateScrollState);
    _scrollProgressNotifier.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _updateScrollState() {
    if (!mounted || !_isVisible) return;

    final currentPixels = _scrollPosition?.pixels ?? 0.0;

    // Cache cards area content coordinate relative to scrollable; lazy-evaluated only once
    if (_cachedCardsAreaContentY == null || _lastCardsAreaHeight == null) {
      final renderBox =
          _cardsAreaKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.attached || !renderBox.hasSize) return;
      _lastCardsAreaHeight = renderBox.size.height;
      _cachedCardsAreaContentY =
          currentPixels + renderBox.localToGlobal(Offset.zero).dy;
    }

    final globalOffsetY = _cachedCardsAreaContentY! - currentPixels;
    const stickyTop = 85.0; // Pinned position under docked header
    const scrollPerCard = 380.0;
    final maxScroll = (widget.cards.length - 1) * scrollPerCard;

    final scrolledPast = (stickyTop - globalOffsetY).clamp(0.0, maxScroll);
    final newProgress = (scrolledPast / scrollPerCard).clamp(
      0.0,
      (widget.cards.length - 1).toDouble(),
    );

    if ((newProgress - _scrollProgressNotifier.value).abs() > 0.001) {
      _scrollProgressNotifier.value = newProgress;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) return const SizedBox.shrink();

    return AutoPauseVisibility(
      onVisibilityChanged: _onVisibilityChanged,
      child: RevealOnScroll(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final isWide = availableWidth >= 900;
            final horizontalPadding = isWide ? 48.0 : 20.0;

            // Card dimensions matching 0.8125 aspect ratio (max-width: 44rem)
            final cardWidth = isWide
                ? (availableWidth * 0.40).clamp(420.0, 520.0)
                : (availableWidth - horizontalPadding * 2).clamp(280.0, 480.0);
            final cardHeight = cardWidth / 0.8125;

            const scrollPerCard = 380.0;
            final totalCardScroll = (widget.cards.length - 1) * scrollPerCard;
            final cardsAreaHeight = cardHeight + totalCardScroll + 60.0;

            return Container(
              padding: EdgeInsets.only(
                top: isWide ? 64.0 : 40.0,
                bottom: isWide ? 72.0 : 48.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── 1. Header with Title & Floating Stickers ──────────────
                  _buildHeader(isWide, availableWidth),

                  SizedBox(height: isWide ? 48.0 : 32.0),

                  // ── 2. Deck of Cards Scroll Stacking Area ─────────────────
                  SizedBox(
                    key: _cardsAreaKey,
                    height: cardsAreaHeight,
                    width: availableWidth,
                    child: _buildScrollStackedCards(
                      cardWidth: cardWidth,
                      cardHeight: cardHeight,
                      isWide: isWide,
                      scrollPerCard: scrollPerCard,
                      totalCardScroll: totalCardScroll,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Header with Title and Floating Stickers ────────────────────────────────
  Widget _buildHeader(bool isWide, double availableWidth) {
    final titleColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'MIX YOUR STYLE',
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            color: const Color(0xFF111111),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Feel good & enjoy\nevery day',
          textAlign: TextAlign.center,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: isWide ? 58 : 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.2,
            height: 1.12,
            color: const Color(0xFF111111),
          ),
        ),
      ],
    );

    if (!isWide) {
      return SizedBox(
        width: availableWidth - 24,
        child: titleColumn,
      );
    }

    return SizedBox(
      width: 760,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // ── Center Content: Subtitle & Display Heading (Static, No Rebuilds) ──
          titleColumn,

          // ── Isolated Stickers Repaint Boundary with AnimatedBuilder ──
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _floatController,
                builder: (context, _) {
                  final t = _floatController.value;
                  final floatPlayful = math.sin(t * math.pi) * 5.0;
                  final floatKids = math.sin((t + 0.35) * math.pi) * 6.0;
                  final floatWow = math.sin((t + 0.70) * math.pi) * -5.0;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // ── Sticker 1: "Kids" (Pink Petal Star - Left) ───────────
                      Positioned(
                        left: 20,
                        top: 75 + floatKids,
                        child: Transform.rotate(
                          angle: -22 * (math.pi / 180),
                          child: _buildKidsPetalStarSticker(),
                        ),
                      ),

                      // ── Sticker 2: "Playful" (Neon Lemon Circle - Top Right) ──
                      Positioned(
                        right: 35,
                        top: 5 + floatPlayful,
                        child: Transform.rotate(
                          angle: -18 * (math.pi / 180),
                          child: _buildPlayfulCircleSticker(),
                        ),
                      ),

                      // ── Sticker 3: "Wow" (Sky Blue Capsule - Bottom Right) ───
                      Positioned(
                        right: 55,
                        bottom: -10 + floatWow,
                        child: Transform.rotate(
                          angle: 24 * (math.pi / 180),
                          child: _buildWowCapsuleSticker(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sticker Widget: Kids (Exact Petal Star SVG Path) ───────────────────────
  Widget _buildKidsPetalStarSticker() {
    const svgString = '''
    <svg xmlns="http://www.w3.org/2000/svg" width="108" height="105" viewBox="0 0 114 111" fill="none">
      <path d="M48.7526 5.02796C52.7249 -0.765208 61.2751 -0.765211 65.2474 5.02796L72.143 15.0845C74.1526 18.0153 77.5668 19.6595 81.1112 19.4033L93.273 18.5244C100.279 18.0181 105.61 24.7029 103.557 31.4206L99.9942 43.0819C98.9558 46.4804 99.799 50.1748 102.209 52.7863L110.479 61.7468C115.243 66.9086 113.341 75.2444 106.809 77.828L95.4699 82.3129C92.1654 83.62 89.8027 86.5827 89.2637 90.0953L87.4144 102.148C86.349 109.091 78.6455 112.801 72.5531 109.305L61.977 103.236C58.8947 101.467 55.1053 101.467 52.023 103.236L41.4469 109.305C35.3545 112.801 27.651 109.091 26.5856 102.148L24.7363 90.0953C24.1973 86.5827 21.8347 83.62 18.5301 82.3129L7.1913 77.828C0.659459 75.2444 -1.24315 66.9086 3.52086 61.7468L11.7908 52.7863C14.201 50.1748 15.0442 46.4804 14.0058 43.0819L10.4426 31.4206C8.39002 24.7029 13.721 18.0181 20.727 18.5244L32.8888 19.4033C36.4332 19.6595 39.8473 18.0153 41.857 15.0845L48.7526 5.02796Z" fill="#FFC8C8"/>
    </svg>
    ''';

    return SizedBox(
      width: 104,
      height: 104,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SvgPicture.string(
            svgString,
            width: 104,
            height: 104,
          ),
          Text(
            'Kids',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // ── Sticker Widget: Playful (Neon Lemon Circle) ────────────────────────────
  Widget _buildPlayfulCircleSticker() {
    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xFFF6FD7C),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        'Playful',
        style: GoogleFonts.bricolageGrotesque(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
    );
  }

  // ── Sticker Widget: Wow (Soft Sky Blue Capsule) ────────────────────────────
  Widget _buildWowCapsuleSticker() {
    return Container(
      width: 86,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFBDE6EE),
        borderRadius: BorderRadius.circular(32),
      ),
      alignment: Alignment.center,
      child: Text(
        'Wow',
        style: GoogleFonts.bricolageGrotesque(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
    );
  }

  // ── Scroll-Driven Stacking Cards Deck ──────────────────────────────────────
  Widget _buildScrollStackedCards({
    required double cardWidth,
    required double cardHeight,
    required bool isWide,
    required double scrollPerCard,
    required double totalCardScroll,
  }) {
    return ValueListenableBuilder<double>(
      valueListenable: _scrollProgressNotifier,
      builder: (context, progress, _) {
        const stickySpacing = 22.0; // Distance between card tops in stacked deck

        // Compute relative local scroll inside this section
        final localScroll = progress * scrollPerCard;

        // Build the 3 cards stacked in natural layer order:
        // Card 0 at base, Card 1 in middle, Card 2 in front
        final cardWidgets = <Widget>[];

        for (int i = 0; i < widget.cards.length; i++) {
          final card = widget.cards[i];
          final double cardTop;
          final double cardScale;

          if (i == 0) {
            // Card 0: pins at top (y = localScroll)
            cardTop = localScroll;
            if (progress <= 1.0) {
              // Scale down from 1.0 to 0.94 as Card 1 covers it
              cardScale = 1.0 - 0.06 * progress;
            } else {
              // Scale down from 0.94 to 0.88 as Card 2 covers it
              cardScale = 0.94 - 0.06 * (progress - 1.0).clamp(0.0, 1.0);
            }
          } else if (i == 1) {
            // Card 1: travels up to stickySpacing (22px)
            if (progress <= 1.0) {
              final travel = (cardHeight + 40.0) * (1.0 - progress) +
                  stickySpacing * progress;
              cardTop = localScroll + travel;
              cardScale = 1.0;
            } else {
              cardTop = localScroll + stickySpacing;
              // Scale down from 1.0 to 0.94 as Card 2 covers it
              cardScale = 1.0 - 0.06 * (progress - 1.0).clamp(0.0, 1.0);
            }
          } else {
            // Card 2: travels up to stickySpacing * 2 (44px)
            if (progress <= 1.0) {
              final travel = (cardHeight + 40.0) * (2.0 - progress);
              cardTop = localScroll + travel;
              cardScale = 1.0;
            } else {
              final p2 = (progress - 1.0).clamp(0.0, 1.0);
              final travel = (cardHeight + 40.0) * (1.0 - p2) +
                  (stickySpacing * 2) * p2;
              cardTop = localScroll + travel;
              cardScale = 1.0;
            }
          }

          cardWidgets.add(
            Positioned(
              top: cardTop,
              left: 0,
              right: 0,
              child: Center(
                child: Transform.scale(
                  scale: cardScale,
                  alignment: Alignment.topCenter,
                  child: _SingleLayeredCard(
                    card: card,
                    cardWidth: cardWidth,
                    cardHeight: cardHeight,
                    isWide: isWide,
                  ),
                ),
              ),
            ),
          );
        }

        return Stack(
          clipBehavior: Clip.none,
          children: cardWidgets,
        );
      },
    );
  }
}

// ── Single Layered Card Item ─────────────────────────────────────────────────
class _SingleLayeredCard extends StatefulWidget {
  final LayeredScrollingCardModel card;
  final double cardWidth;
  final double cardHeight;
  final bool isWide;

  const _SingleLayeredCard({
    required this.card,
    required this.cardWidth,
    required this.cardHeight,
    required this.isWide,
  });

  @override
  State<_SingleLayeredCard> createState() => _SingleLayeredCardState();
}

class _SingleLayeredCardState extends State<_SingleLayeredCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final card = widget.card;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          context.go(card.linkUrl);
        },
        child: Container(
          width: widget.cardWidth,
          height: widget.cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── 1. Background Lifestyle Image with Hover Zoom ──────
                AnimatedScale(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutCubic,
                  scale: _hovered ? 1.04 : 1.0,
                  child: Image.network(
                    card.image,
                    fit: BoxFit.cover,
                    cacheWidth: 800,
                    gaplessPlayback: true,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: const Color(0xFFE8E5DD),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Color(0xFFB0AEA6),
                      ),
                    ),
                  ),
                ),

                // ── 2. Subtle Gradient Overlay for Text Readability ───
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.08),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.20),
                          Colors.black.withValues(alpha: 0.70),
                        ],
                        stops: const [0.0, 0.45, 0.70, 1.0],
                      ),
                    ),
                  ),
                ),

                // ── 3. Top-Left Frosted Pill Badge (e.g., "Trendy Picks")
                Positioned(
                  top: 22,
                  left: 22,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.45),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      card.label,
                      style: GoogleFonts.bricolageGrotesque(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

                // ── 4. Bottom Content: Subheading, Heading & Button ────
                Positioned(
                  left: widget.isWide ? 32 : 20,
                  right: widget.isWide ? 32 : 20,
                  bottom: widget.isWide ? 32 : 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Subheading (uppercase bold tracking)
                      Text(
                        card.subheading.toUpperCase(),
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: Colors.white.withValues(alpha: 0.90),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Large Display Heading
                      Text(
                        card.heading,
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: widget.isWide ? 40 : 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          height: 1.12,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // White "Shop Now >" Pill Button
                      _LayeredCardShopButton(
                        text: 'Shop Now',
                        onTap: () => context.go(card.linkUrl),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── White Pill Button with Integrated Circular Chevron & Inversion ───────────
class _LayeredCardShopButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _LayeredCardShopButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_LayeredCardShopButton> createState() => _LayeredCardShopButtonState();
}

class _LayeredCardShopButtonState extends State<_LayeredCardShopButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF111111) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: _hovered ? Colors.white : const Color(0xFF111111),
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hovered ? Colors.white : const Color(0xFF111111),
                ),
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 200),
                  offset: _hovered
                      ? const Offset(0.08, 0)
                      : Offset.zero,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: _hovered
                        ? const Color(0xFF111111)
                        : Colors.white,
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
