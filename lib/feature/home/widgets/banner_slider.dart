import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/widgets/animated_arrow_pill.dart';

class BannerSlider extends StatefulWidget {
  final List<BannerSlideModel> banners;
  final String transition;
  final bool isActive;

  const BannerSlider({
    super.key,
    required this.banners,
    this.transition = 'fade_zoom',
    this.isActive = true,
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animController;
  Timer? _timer;
  int _current = 0;
  bool _isHovered = false;

  // ── Ken Burns & Staggered Animations ──────────────────────────────
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _imageOpacityAnimation;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _subtitleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _ctaSlide;
  late final Animation<double> _ctaOpacity;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // Ken Burns gentle zoom-out from 1.10 down to 1.00
    _scaleAnimation = Tween<double>(begin: 1.10, end: 1.00).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    // Image cross-fade
    _imageOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );

    // Staggered Subtitle entrance
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.18, 0.65, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.18, 0.65, curve: Curves.easeOut),
      ),
    );

    // Staggered Headline entrance
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.30, 0.78, curve: Curves.easeOutCubic),
          ),
        );
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.30, 0.78, curve: Curves.easeOut),
      ),
    );

    // Staggered Pill CTA entrance
    _ctaSlide = Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.44, 0.92, curve: Curves.easeOutCubic),
          ),
        );
    _ctaOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.44, 0.92, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
  }

  void _onHoverChanged(bool hovered) {
    if (_isHovered == hovered) return;
    _isHovered = hovered;
    if (_isHovered) {
      _timer?.cancel();
      _timer = null;
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = null;
    final tickerEnabled = TickerMode.valuesOf(context).enabled;
    if (!widget.isActive ||
        !tickerEnabled ||
        _isHovered ||
        widget.banners.length <= 1) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted ||
          !widget.isActive ||
          !TickerMode.valuesOf(context).enabled ||
          _isHovered ||
          widget.banners.length <= 1) {
        _timer?.cancel();
        _timer = null;
        return;
      }
      _goToSlide((_current + 1) % widget.banners.length);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tickerEnabled = TickerMode.valuesOf(context).enabled;
    if (!tickerEnabled || !widget.isActive) {
      _timer?.cancel();
      _timer = null;
    } else if (_timer == null && !_isHovered && widget.banners.length > 1) {
      _startTimer();
    }
    for (final banner in widget.banners) {
      if (banner.image.isNotEmpty) {
        precacheImage(NetworkImage(banner.image), context, onError: (_, _) {});
      }
    }
  }

  @override
  void didUpdateWidget(covariant BannerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive ||
        oldWidget.banners.length != widget.banners.length) {
      if (widget.isActive && widget.banners.length > 1 && !_isHovered) {
        _startTimer();
      } else {
        _timer?.cancel();
        _timer = null;
      }
    }
  }

  void _goToSlide(int index) {
    if (index == _current) return;
    setState(() => _current = index);

    if (widget.transition == 'slide') {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _animController.forward(from: 0.0);
    }
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Color _parseHex(String hex, Color fallback) {
    try {
      final clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
    } catch (_) {}
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    final isWide = context.isWide;
    final screenHeight = MediaQuery.sizeOf(context).height;
    // The reference leaves only a narrow glimpse of the next section.
    final bannerHeight = isWide
        ? (screenHeight * 0.975).clamp(700.0, 1100.0)
        : (screenHeight * 0.88).clamp(580.0, 850.0);
    final currentBanner = widget.banners[_current];
    final isFadeZoom = widget.transition != 'slide';

    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: SizedBox(
        height: bannerHeight,
        width: double.infinity,
        child: Stack(
          children: [
            // ── Slider Content (Ken Burns Fade-Zoom OR PageView Slide) ─
            if (isFadeZoom)
              _buildFadeZoomSlide(currentBanner, isWide)
            else
              PageView.builder(
                controller: _pageController,
                itemCount: widget.banners.length,
                onPageChanged: (val) {
                  setState(() => _current = val);
                  _startTimer();
                },
                itemBuilder: (context, index) {
                  final banner = widget.banners[index];
                  return _buildSlideContent(
                    banner: banner,
                    isWide: isWide,
                    scale: 1.0,
                    opacity: 1.0,
                    subSlide: Offset.zero,
                    subOpacity: 1.0,
                    titleSlide: Offset.zero,
                    titleOpacity: 1.0,
                    ctaSlide: Offset.zero,
                    ctaOpacity: 1.0,
                  );
                },
              ),

            // ── Bottom-Right Slider Controls (1 / 2  ───  < >) ────────
            if (widget.banners.length > 1)
              Positioned(
                bottom: isWide ? 32 : 20,
                right: isWide ? 48 : 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Counter: e.g. "1 / 2"
                      Text(
                        '${_current + 1} / ${widget.banners.length}',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Progress Track Line
                      SizedBox(
                        width: 72,
                        height: 2,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            AnimatedFractionallySizedBox(
                              duration: const Duration(milliseconds: 300),
                              widthFactor:
                                  (_current + 1) / widget.banners.length,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Previous Arrow <
                      IconButton(
                        tooltip: 'Previous slide',
                        onPressed: () {
                          final prev =
                              (_current - 1 + widget.banners.length) %
                              widget.banners.length;
                          _goToSlide(prev);
                        },
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: const EdgeInsets.all(4),
                        icon: const Icon(
                          Icons.chevron_left_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),

                      // Next Arrow >
                      IconButton(
                        tooltip: 'Next slide',
                        onPressed: () {
                          final next = (_current + 1) % widget.banners.length;
                          _goToSlide(next);
                        },
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        padding: const EdgeInsets.all(4),
                        icon: const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Ken Burns Animated Slide Builder ──────────────────────────────
  Widget _buildFadeZoomSlide(BannerSlideModel banner, bool isWide) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return _buildSlideContent(
          banner: banner,
          isWide: isWide,
          scale: _scaleAnimation.value,
          opacity: _imageOpacityAnimation.value,
          subSlide: _subtitleSlide.value,
          subOpacity: _subtitleOpacity.value,
          titleSlide: _titleSlide.value,
          titleOpacity: _titleOpacity.value,
          ctaSlide: _ctaSlide.value,
          ctaOpacity: _ctaOpacity.value,
        );
      },
    );
  }

  // ── Single Slide Full Canvas Layout ───────────────────────────────
  Widget _buildSlideContent({
    required BannerSlideModel banner,
    required bool isWide,
    required double scale,
    required double opacity,
    required Offset subSlide,
    required double subOpacity,
    required Offset titleSlide,
    required double titleOpacity,
    required Offset ctaSlide,
    required double ctaOpacity,
  }) {
    final bgColor = _parseHex(banner.bgColor, AppColors.heroWarmTerracotta);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      color: bgColor,
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Centered / Full-bleed Portrait with Ken Burns Zoom ────
          if (banner.image.isNotEmpty)
            Positioned.fill(
              child: Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: scale,
                  child: Image.network(
                    banner.image,
                    fit: BoxFit.cover,
                    alignment: isWide
                        ? Alignment.center
                        : Alignment.centerRight,
                    width: double.infinity,
                    height: double.infinity,
                    cacheWidth: 1920,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),

          // ── Staggered Editorial Text & Pill CTA ───────────────────
          Positioned(
            left: isWide
                ? math.max(24, (MediaQuery.sizeOf(context).width - 1296) / 2)
                : 24,
            top: isWide ? MediaQuery.sizeOf(context).height * 0.39 : null,
            bottom: isWide ? null : 48,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isWide ? 520 : MediaQuery.of(context).size.width - 48,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subtitle: "NEW CAMPAIGN" or "LITTLE MOMENTS"
                  if (banner.subtitle.isNotEmpty)
                    FadeTransition(
                      opacity: AlwaysStoppedAnimation(subOpacity),
                      child: SlideTransition(
                        position: AlwaysStoppedAnimation(subSlide),
                        child: Text(
                          banner.subtitle.toUpperCase(),
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: isWide ? 14 : 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  if (banner.subtitle.isNotEmpty) const SizedBox(height: 12),

                  // Headline: "Softness in Comfort" or "Wrapped in Warmth"
                  if (banner.title.isNotEmpty)
                    FadeTransition(
                      opacity: AlwaysStoppedAnimation(titleOpacity),
                      child: SlideTransition(
                        position: AlwaysStoppedAnimation(titleSlide),
                        child: Text(
                          banner.title,
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: isWide ? 56 : 34,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                            letterSpacing: -0.5,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  if (banner.title.isNotEmpty) const SizedBox(height: 24),

                  // Shop action: a trailing arrow segment fills the pill on hover.
                  if (banner.ctaText.isNotEmpty)
                    FadeTransition(
                      opacity: AlwaysStoppedAnimation(ctaOpacity),
                      child: SlideTransition(
                        position: AlwaysStoppedAnimation(ctaSlide),
                        child: AnimatedArrowPill(
                          label: banner.ctaText,
                          onPressed: banner.ctaLink.isNotEmpty
                              ? () => context.go(banner.ctaLink)
                              : null,
                        ),
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
