import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/widgets/reveal_on_scroll.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';

/// 1:1 Implementation of Shopify Pebble Flex Carousel Section
/// (template--20816638214282__flex_carousel_8kBgwA).
///
/// Features:
/// - Centered display headline "Dress your explorer in comfort" in Bricolage Grotesque
/// - Asymmetrical rhythmic card widths on desktop (30%, 39%, 21%, 39%, 30%, 21%)
/// - Responsive mobile layout (72% peek card width, square 1:1 photos)
/// - Frosted glass translucent pill badge on top-left of each photo
/// - Smooth image scale zoom on hover (1.04)
/// - Editorial heading + narrative subtext below each card photo
/// - Bottom controls: animated horizontal progress bar and circular < > arrow navigation buttons
class FlexCarouselSection extends StatefulWidget {
  final FlexCarouselModel carouselData;

  const FlexCarouselSection({super.key, required this.carouselData});

  @override
  State<FlexCarouselSection> createState() => _FlexCarouselSectionState();
}

class _FlexCarouselSectionState extends State<FlexCarouselSection> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollProgressNotifier = ValueNotifier<double>(
    0.0,
  );
  final ValueNotifier<bool> _canScrollLeftNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _canScrollRightNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollProgressNotifier.dispose();
    _canScrollLeftNotifier.dispose();
    _canScrollRightNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!mounted || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (!position.hasContentDimensions || !position.hasPixels) return;
    final maxScroll = position.maxScrollExtent;
    final current = position.pixels;

    final canLeft = current > 5.0;
    final canRight = current < (maxScroll - 5.0);
    final progress = maxScroll > 0
        ? (current / maxScroll).clamp(0.0, 1.0)
        : 1.0;

    if (_canScrollLeftNotifier.value != canLeft) {
      _canScrollLeftNotifier.value = canLeft;
    }
    if (_canScrollRightNotifier.value != canRight) {
      _canScrollRightNotifier.value = canRight;
    }
    if ((progress - _scrollProgressNotifier.value).abs() > 0.003) {
      _scrollProgressNotifier.value = progress;
    }
  }

  void _scrollDelta(double delta) {
    if (!mounted || !_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (!position.hasContentDimensions || !position.hasPixels) return;
    final target = (position.pixels + delta).clamp(
      0.0,
      position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.carouselData.cards;
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 72.0 : 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Centered Display Headline ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: RevealOnScroll(
              child: Text(
                widget.carouselData.heading,
                textAlign: TextAlign.center,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: isDesktop ? 44.0 : 28.0,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.8,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
          ),
          SizedBox(height: isDesktop ? 48.0 : 28.0),

          // ── Scrollable Horizontal Cards Carousel (Fixed-Constraint Virtualization) ──
          ScrollConfiguration(
            behavior: const MaterialScrollBehavior().copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 48.0 : 20.0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    ConstrainedBox(
                      constraints: BoxConstraints.tightFor(
                        width: isDesktop
                            ? ((math.min(screenWidth - 96.0, 1360.0) *
                                      (cards[i].widthDesktopPercent / 100.0))
                                  .clamp(280.0, 560.0))
                            : (screenWidth * 0.72),
                      ),
                      child: _FlexCardItem(
                        card: cards[i],
                        isDesktop: isDesktop,
                        screenWidth: screenWidth,
                      ),
                    ),
                    if (i < cards.length - 1)
                      SizedBox(width: isDesktop ? 28.0 : 16.0),
                  ],
                ],
              ),
            ),
          ),

          // ── Bottom Progress Bar & Navigation Controls ────────────
          SizedBox(height: isDesktop ? 40.0 : 24.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48.0 : 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Horizontal Animated Progress Bar
                ValueListenableBuilder<double>(
                  valueListenable: _scrollProgressNotifier,
                  builder: (context, progress, _) => Container(
                    width: isDesktop ? 220.0 : 140.0,
                    height: 3.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: math.max(0.12, progress),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24.0),

                // < Previous Button
                ValueListenableBuilder<bool>(
                  valueListenable: _canScrollLeftNotifier,
                  builder: (context, canLeft, _) => _CarouselArrowButton(
                    icon: Icons.chevron_left_rounded,
                    isEnabled: canLeft,
                    onTap: () => _scrollDelta(isDesktop ? -450.0 : -300.0),
                  ),
                ),
                const SizedBox(width: 10.0),

                // > Next Button
                ValueListenableBuilder<bool>(
                  valueListenable: _canScrollRightNotifier,
                  builder: (context, canRight, _) => _CarouselArrowButton(
                    icon: Icons.chevron_right_rounded,
                    isEnabled: canRight,
                    onTap: () => _scrollDelta(isDesktop ? 450.0 : 300.0),
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

/// Single card in the Flex Carousel with frosted glass badge and hover scale
class _FlexCardItem extends StatefulWidget {
  final FlexCarouselCardModel card;
  final bool isDesktop;
  final double screenWidth;

  const _FlexCardItem({
    required this.card,
    required this.isDesktop,
    required this.screenWidth,
  });

  @override
  State<_FlexCardItem> createState() => _FlexCardItemState();
}

class _FlexCardItemState extends State<_FlexCardItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final double cardWidth;
    final double aspectRatio;

    if (widget.isDesktop) {
      // Container width available for 3-card desktop grouping
      final baseWidth = math.min(widget.screenWidth - 96.0, 1360.0);
      final percentFactor = widget.card.widthDesktopPercent / 100.0;
      cardWidth = (baseWidth * percentFactor).clamp(280.0, 560.0);
      aspectRatio = 1.375; // reference desktop photo ratio
    } else {
      cardWidth = widget.screenWidth * 0.72;
      aspectRatio = 1.0; // reference mobile square photo
    }

    return SizedBox(
      width: cardWidth,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: () {
            final link = widget.card.link.trim();
            if (link.isNotEmpty) {
              context.go(link);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Card Image Container ──
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: AspectRatio(
                  aspectRatio: aspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Photo with smooth hover zoom
                      AnimatedScale(
                        scale: _isHovered ? 1.04 : 1.0,
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        child: Image.network(
                          widget.card.image,
                          fit: BoxFit.cover,
                          cacheWidth: 800,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: const Color(0xFFF1F5F9),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    size: 36,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                        ),
                      ),

                      // Frosted glass appearance without GPU raster readbacks
                      if (widget.card.badge.isNotEmpty)
                        Positioned(
                          top: 16.0,
                          left: 16.0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14.0,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.38),
                              borderRadius: BorderRadius.circular(24.0),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              widget.card.badge,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18.0),

              // ── Editorial Headline ──
              Text(
                widget.card.heading,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: widget.isDesktop ? 20.0 : 17.0,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  letterSpacing: -0.3,
                  color: const Color(0xFF0F172A),
                ),
              ),

              if (widget.card.subtext.isNotEmpty) ...[
                const SizedBox(height: 6.0),
                // ── Narrative Subtext ──
                Text(
                  widget.card.subtext,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.0,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Circular arrow navigation button with hover wipe interaction
class _CarouselArrowButton extends StatefulWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;

  const _CarouselArrowButton({
    required this.icon,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  State<_CarouselArrowButton> createState() => _CarouselArrowButtonState();
}

class _CarouselArrowButtonState extends State<_CarouselArrowButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isEnabled;

    return MouseRegion(
      cursor: active ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (active) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (active) setState(() => _isHovered = false);
      },
      child: GestureDetector(
        onTap: active ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: 42.0,
          height: 42.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active && _isHovered
                ? const Color(0xFF0F172A)
                : Colors.transparent,
            border: Border.all(
              color: active
                  ? (_isHovered
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFCBD5E1))
                  : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: 22.0,
              color: active
                  ? (_isHovered ? Colors.white : const Color(0xFF0F172A))
                  : const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
    );
  }
}
