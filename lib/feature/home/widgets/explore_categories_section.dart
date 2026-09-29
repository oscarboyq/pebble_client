import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/widgets/pebble_image.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

class ExploreCategoriesSection extends StatefulWidget {
  final List<CategoryModel> categories;

  const ExploreCategoriesSection({super.key, required this.categories});

  @override
  State<ExploreCategoriesSection> createState() =>
      _ExploreCategoriesSectionState();
}

class _ExploreCategoriesSectionState extends State<ExploreCategoriesSection> {
  final ScrollController _scrollController = ScrollController();
  String _selectedGender = 'boys'; // 'boys' or 'girls'
  final ValueNotifier<double> _scrollProgressNotifier = ValueNotifier<double>(
    0.0,
  );
  final ValueNotifier<bool> _canScrollLeftNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _canScrollRightNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollState());
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
    _updateScrollState();
  }

  void _updateScrollState() {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final offset = _scrollController.offset;

    if (maxExtent > 0) {
      final progress = (offset / maxExtent).clamp(0.0, 1.0);
      final canLeft = offset > 4.0;
      final canRight = offset < maxExtent - 4.0;

      if ((progress - _scrollProgressNotifier.value).abs() > 0.003) {
        _scrollProgressNotifier.value = progress;
      }
      if (_canScrollLeftNotifier.value != canLeft) {
        _canScrollLeftNotifier.value = canLeft;
      }
      if (_canScrollRightNotifier.value != canRight) {
        _canScrollRightNotifier.value = canRight;
      }
    } else {
      if (_scrollProgressNotifier.value != 0.0) {
        _scrollProgressNotifier.value = 0.0;
      }
      if (_canScrollLeftNotifier.value) {
        _canScrollLeftNotifier.value = false;
      }
      if (_canScrollRightNotifier.value) {
        _canScrollRightNotifier.value = false;
      }
    }
  }

  void _scroll(double offset) {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.offset + offset).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  void _switchGender(String gender) {
    if (_selectedGender == gender) return;
    setState(() {
      _selectedGender = gender;
    });
    _scrollProgressNotifier.value = 0.0;
    _canScrollLeftNotifier.value = false;
    _canScrollRightNotifier.value = true;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollState());
  }

  @override
  Widget build(BuildContext context) {
    // Filter categories by selected gender tab
    final filteredCategories = widget.categories
        .where(
          (c) =>
              c.gender.toLowerCase() == _selectedGender ||
              c.gender.toLowerCase() == 'all',
        )
        .toList();

    // If empty for this gender, fall back to all categories
    final displayCategories = filteredCategories.isNotEmpty
        ? filteredCategories
        : widget.categories;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isWide = availableWidth >= 900;
        final horizontalPadding = isWide ? 48.0 : 20.0;
        final contentWidth = availableWidth - horizontalPadding * 2;

        // Exactly ~5.8 to 6 images visible on desktop screen,
        // matching the Shopify Pebble reference where cards 1-6 are in view
        final double cardsPerView;
        if (availableWidth >= 1350) {
          cardsPerView =
              5.85; // 5 full cards + 6th card mostly visible (~6 on screen)
        } else if (availableWidth >= 1050) {
          cardsPerView = 5.2;
        } else if (availableWidth >= 750) {
          cardsPerView = 3.8;
        } else {
          cardsPerView = 2.25;
        }

        final separatorWidth = isWide ? 12.0 : 10.0;
        final cardWidth =
            (contentWidth - (cardsPerView - 1) * separatorWidth) / cardsPerView;
        // Image aspect ratio: 720 x 936 -> 1.30 height multiplier
        final cardHeight = cardWidth / AppDimensions.editorialImageAspectRatio;
        final scrollStep = (cardWidth + separatorWidth) * 2;

        // Progress bar track parameters:
        final trackWidth = isWide ? 180.0 : 130.0;
        const trackHeight = 2.5;

        // Visible proportion of the carousel
        final double visibleProportion;
        if (_scrollController.hasClients &&
            _scrollController.position.maxScrollExtent > 0) {
          final viewport = _scrollController.position.viewportDimension;
          final totalWidth =
              _scrollController.position.maxScrollExtent + viewport;
          visibleProportion = (viewport / totalWidth).clamp(0.25, 0.6);
        } else {
          visibleProportion = displayCategories.length > 5
              ? (cardsPerView / displayCategories.length).clamp(0.25, 0.6)
              : 0.45;
        }

        return Padding(
          padding: EdgeInsets.only(
            top: isWide ? 44 : 28,
            bottom: isWide ? 36 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section Header Row ────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // "Explore Categories" Title
                    Text(
                      'Explore Categories',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: isWide ? 32 : 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        color: const Color(0xFF111111),
                      ),
                    ),

                    // Boy's / Girl's Toggle Pill Tabs
                    Container(
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _GenderTab(
                            label: "Boy's",
                            isActive: _selectedGender == 'boys',
                            onTap: () => _switchGender('boys'),
                          ),
                          const SizedBox(width: 4),
                          _GenderTab(
                            label: "Girl's",
                            isActive: _selectedGender == 'girls',
                            onTap: () => _switchGender('girls'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Horizontal Cards Carousel (Virtualized Fixed Extent) ──
              SizedBox(
                height: cardHeight + 52, // card image + label & count space
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: horizontalPadding,
                    right: (horizontalPadding - separatorWidth).clamp(
                      0.0,
                      double.infinity,
                    ),
                  ),
                  itemCount: displayCategories.length,
                  itemExtent: cardWidth + separatorWidth,
                  itemBuilder: (context, index) {
                    final category = displayCategories[index];
                    return Padding(
                      padding: EdgeInsets.only(right: separatorWidth),
                      child: SizedBox(
                        width: cardWidth,
                        child: _ExploreCategoryCard(
                          category: category,
                          width: cardWidth,
                          height: cardHeight,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ── Bottom Navigation Row: Progress Indicator & Arrows ────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                ).copyWith(top: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ── Left: Horizontal Slide Progress Bar Indicator ───
                    ValueListenableBuilder<double>(
                      valueListenable: _scrollProgressNotifier,
                      builder: (context, progress, _) {
                        final fillFraction =
                            (visibleProportion +
                                    (1.0 - visibleProportion) * progress)
                                .clamp(visibleProportion, 1.0);
                        final fillWidth = trackWidth * fillFraction;

                        return Container(
                          width: trackWidth,
                          height: trackHeight,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E2DC),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          alignment: Alignment.centerLeft,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            width: fillWidth,
                            height: trackHeight,
                            decoration: BoxDecoration(
                              color: const Color(0xFF111111),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      },
                    ),

                    // ── Right: Navigation Arrows (< >) with Hover Animation ─
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Previous Arrow Button <
                        ValueListenableBuilder<bool>(
                          valueListenable: _canScrollLeftNotifier,
                          builder: (context, canLeft, _) =>
                              _CarouselArrowButton(
                                isNext: false,
                                enabled: canLeft,
                                onTap: () => _scroll(-scrollStep),
                              ),
                        ),
                        const SizedBox(width: 8),
                        // Next Arrow Button >
                        ValueListenableBuilder<bool>(
                          valueListenable: _canScrollRightNotifier,
                          builder: (context, canRight, _) =>
                              _CarouselArrowButton(
                                isNext: true,
                                enabled: canRight,
                                onTap: () => _scroll(scrollStep),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Boy's / Girl's Tab Button ─────────────────────────────────────────
class _GenderTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _GenderTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFEBE7DF) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              color: isActive
                  ? const Color(0xFF111111)
                  : const Color(0xFF444444),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Single Category Card with Label, Superscript Count, & Hover Effects ─
class _ExploreCategoryCard extends StatefulWidget {
  final CategoryModel category;
  final double width;
  final double height;

  const _ExploreCategoryCard({
    required this.category,
    required this.width,
    required this.height,
  });

  @override
  State<_ExploreCategoryCard> createState() => _ExploreCategoryCardState();
}

class _ExploreCategoryCardState extends State<_ExploreCategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: () {
          context.go('${AppRoutes.home}?category=${widget.category.slug}');
        },
        child: SizedBox(
          width: widget.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Rounded Image Card Container (media-hover--scale) ───
              AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFF2EFE9),
                  boxShadow: _hovered
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 360),
                    curve: Curves.easeOutCubic,
                    scale: _hovered ? 1.05 : 1.0,
                    child: PebbleImage.card(
                      imageUrl: widget.category.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: _placeholder(),
                      errorWidget: _placeholder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Category Title with Superscript Count & Animated Underline ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Name
                      Flexible(
                        child: Text(
                          widget.category.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: const Color(0xFF111111),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Superscript Collection Count (<sup> count </sup>)
                      Transform.translate(
                        offset: const Offset(0, -3),
                        child: Text(
                          '${widget.category.productCount}',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Animated Underline on Hover (reversed-link text effect)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    height: 1.3,
                    width: _hovered ? widget.width * 0.65 : 0.0,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF2EFE9),
      child: const Center(
        child: Icon(
          Icons.category_outlined,
          color: Color(0xFFB0B0B0),
          size: 32,
        ),
      ),
    );
  }
}

// ── Circular Navigation Arrow Button (< and >) with Exact Pebble Hover Animation ──
class _CarouselArrowButton extends StatefulWidget {
  final bool isNext;
  final bool enabled;
  final VoidCallback onTap;

  const _CarouselArrowButton({
    required this.isNext,
    required this.enabled,
    required this.onTap,
  });

  @override
  State<_CarouselArrowButton> createState() => _CarouselArrowButtonState();
}

class _CarouselArrowButtonState extends State<_CarouselArrowButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.enabled;

    return MouseRegion(
      cursor: isInteractive
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) {
        if (isInteractive) setState(() => _hovered = true);
      },
      onExit: (_) => setState(() {
        _hovered = false;
        _pressed = false;
      }),
      child: InkWell(
        customBorder: const CircleBorder(),
        onHighlightChanged: (pressed) {
          if (isInteractive) setState(() => _pressed = pressed);
        },
        onTap: isInteractive ? widget.onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: isInteractive ? 1.0 : 0.35,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            scale: _pressed ? 0.93 : (_hovered && isInteractive ? 1.05 : 1.0),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: _hovered && isInteractive
                      ? const Color(0xFF111111)
                      : const Color(0xFFE5E2DC),
                  width: 1,
                ),
                boxShadow: _hovered && isInteractive
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: ClipOval(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // ── Smooth Left-to-Right / Circular Fill Wipe ───
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      left: _hovered && isInteractive ? 0 : -38,
                      top: 0,
                      bottom: 0,
                      width: 38,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF111111),
                        ),
                      ),
                    ),

                    // ── Animated Caret Icon with Subtle Directional Nudge ───
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      offset: _hovered && isInteractive
                          ? (widget.isNext
                                ? const Offset(0.12, 0)
                                : const Offset(-0.12, 0))
                          : Offset.zero,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: TextStyle(
                          color: _hovered && isInteractive
                              ? Colors.white
                              : const Color(0xFF111111),
                        ),
                        child: Icon(
                          widget.isNext
                              ? Icons.chevron_right_rounded
                              : Icons.chevron_left_rounded,
                          size: 20,
                          color: _hovered && isInteractive
                              ? Colors.white
                              : const Color(0xFF111111),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
