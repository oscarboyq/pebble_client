import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/widgets/reveal_on_scroll.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/widgets/quick_view_sheet.dart';

enum HotThisWeekTab {
  bestSellers,
  newArrivals,
}

/// 1:1 Pixel-Perfect Implementation of Shopify Pebble "Hot This Week"
/// Interactive Product Tabs Carousel with genuine assets, hover dual-image flip,
/// badges, quick view icon, "Choose Options +" floating pill, and responsive controls.
class HotThisWeekSection extends StatefulWidget {
  final List<ProductModel> bestSellers;
  final List<ProductModel> newArrivals;

  const HotThisWeekSection({
    super.key,
    required this.bestSellers,
    required this.newArrivals,
  });

  @override
  State<HotThisWeekSection> createState() => _HotThisWeekSectionState();
}

class _HotThisWeekSectionState extends State<HotThisWeekSection> {
  HotThisWeekTab _activeTab = HotThisWeekTab.bestSellers;
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollProgressNotifier =
      ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _canScrollPrevNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _canScrollNextNotifier = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _scrollProgressNotifier.dispose();
    _canScrollPrevNotifier.dispose();
    _canScrollNextNotifier.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxExtent = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (maxExtent > 0) {
      final progress = (current / maxExtent).clamp(0.0, 1.0);
      final canPrev = current > 5.0;
      final canNext = current < maxExtent - 5.0;

      if ((progress - _scrollProgressNotifier.value).abs() > 0.003) {
        _scrollProgressNotifier.value = progress;
      }
      if (_canScrollPrevNotifier.value != canPrev) {
        _canScrollPrevNotifier.value = canPrev;
      }
      if (_canScrollNextNotifier.value != canNext) {
        _canScrollNextNotifier.value = canNext;
      }
    } else {
      if (_scrollProgressNotifier.value != 0.0) {
        _scrollProgressNotifier.value = 0.0;
      }
      if (_canScrollPrevNotifier.value) {
        _canScrollPrevNotifier.value = false;
      }
      if (_canScrollNextNotifier.value) {
        _canScrollNextNotifier.value = false;
      }
    }
  }

  void _scrollToDelta(double delta) {
    if (!_scrollController.hasClients) return;
    final target = (_scrollController.position.pixels + delta).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _switchTab(HotThisWeekTab tab) {
    if (_activeTab == tab) return;
    setState(() {
      _activeTab = tab;
    });
    _scrollProgressNotifier.value = 0.0;
    _canScrollPrevNotifier.value = false;
    _canScrollNextNotifier.value = true;
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentProducts = _activeTab == HotThisWeekTab.bestSellers
        ? widget.bestSellers
        : widget.newArrivals;

    if (currentProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return RevealOnScroll(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final isWide = availableWidth >= 900;
          final horizontalPadding = isWide ? 48.0 : 20.0;
          final contentWidth = availableWidth - horizontalPadding * 2;

          // Responsive items per view:
          // Desktop: 4 full cards + peek of 5th card (~4.35)
          // Tablet/Laptop: ~3.3 to 2.5 cards
          // Mobile: ~1.35 cards
          final double cardsPerView;
          if (availableWidth >= 1400) {
            cardsPerView = 4.35;
          } else if (availableWidth >= 1100) {
            cardsPerView = 3.4;
          } else if (availableWidth >= 760) {
            cardsPerView = 2.4;
          } else {
            cardsPerView = 1.35;
          }

          final separatorWidth = isWide ? 12.0 : 10.0;
          final cardWidth = (contentWidth - (cardsPerView.floor()) * separatorWidth) /
              cardsPerView;
          // 3:4 aspect ratio for image card:
          final imageHeight = cardWidth * 1.333;
          // Card info container height (title, price, swatches):
          const cardInfoHeight = 84.0;
          final cardTotalHeight = imageHeight + cardInfoHeight;
          final scrollStep = (cardWidth + separatorWidth) * 2;

          // Progress bar track parameters:
          final trackWidth = isWide ? 180.0 : 130.0;
          const trackHeight = 2.5;
          final double visibleProportion;
          if (_scrollController.hasClients &&
              _scrollController.position.maxScrollExtent > 0) {
            final viewport = _scrollController.position.viewportDimension;
            final totalWidth =
                _scrollController.position.maxScrollExtent + viewport;
            visibleProportion = (viewport / totalWidth).clamp(0.25, 0.6);
          } else {
            visibleProportion = (cardsPerView / currentProducts.length).clamp(0.25, 0.6);
          }

          return Container(
            padding: EdgeInsets.symmetric(
              vertical: isWide ? 44.0 : 28.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Section Header: Title & Pill Switcher ───────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 16,
                    runSpacing: 14,
                    children: [
                      // Section Heading
                      Text(
                        'Hot This Week',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: isWide ? 32 : 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: const Color(0xFF111111),
                        ),
                      ),

                      // Pill Switcher Tabs: Best Sellers & New Arrivals
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PillTabButton(
                              label: 'Best Sellers',
                              isActive: _activeTab == HotThisWeekTab.bestSellers,
                              onTap: () => _switchTab(HotThisWeekTab.bestSellers),
                            ),
                            const SizedBox(width: 4),
                            _PillTabButton(
                              label: 'New Arrivals',
                              isActive: _activeTab == HotThisWeekTab.newArrivals,
                              onTap: () => _switchTab(HotThisWeekTab.newArrivals),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isWide ? 28 : 20),

                // ── 2. Horizontal Cards Swiper (Virtualized Fixed Extent) ──
                SizedBox(
                  height: cardTotalHeight,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      left: horizontalPadding,
                      right: (horizontalPadding - separatorWidth)
                          .clamp(0.0, double.infinity),
                    ),
                    itemCount: currentProducts.length,
                    itemExtent: cardWidth + separatorWidth,
                    itemBuilder: (context, index) {
                      final product = currentProducts[index];
                      return Padding(
                        padding: EdgeInsets.only(right: separatorWidth),
                        child: SizedBox(
                          width: cardWidth,
                          child: _HotThisWeekProductCard(
                            product: product,
                            cardWidth: cardWidth,
                            imageHeight: imageHeight,
                            isWide: isWide,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: isWide ? 26 : 18),

                // ── 3. Bottom Controls: Progress Bar & Arrow Buttons ────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Progress Bar
                      ValueListenableBuilder<double>(
                        valueListenable: _scrollProgressNotifier,
                        builder: (context, progress, _) {
                          final fillFraction = (visibleProportion +
                                  (1.0 - visibleProportion) * progress)
                              .clamp(visibleProportion, 1.0);
                          final fillWidth = trackWidth * fillFraction;

                          return Stack(
                            children: [
                              // Base Track
                              Container(
                                width: trackWidth,
                                height: trackHeight,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8E8E8),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              // Dynamic Active Fill
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 140),
                                curve: Curves.easeOutCubic,
                                width: fillWidth,
                                height: trackHeight,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111111),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      // Navigation Outline Circular Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: _canScrollPrevNotifier,
                            builder: (context, canPrev, _) => _HotArrowButton(
                              isNext: false,
                              isEnabled: canPrev,
                              onTap: () => _scrollToDelta(-scrollStep),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ValueListenableBuilder<bool>(
                            valueListenable: _canScrollNextNotifier,
                            builder: (context, canNext, _) => _HotArrowButton(
                              isNext: true,
                              isEnabled: canNext,
                              onTap: () => _scrollToDelta(scrollStep),
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
      ),
    );
  }
}

// ── Pill Tab Button ──────────────────────────────────────────────────────────
class _PillTabButton extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PillTabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_PillTabButton> createState() => _PillTabButtonState();
}

class _PillTabButtonState extends State<_PillTabButton> {
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
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color(0xFFEBEBEB)
                : (_hovered ? const Color(0xFFF5F5F5) : Colors.transparent),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 14,
              fontWeight: widget.isActive ? FontWeight.w700 : FontWeight.w500,
              color: widget.isActive
                  ? const Color(0xFF111111)
                  : const Color(0xFF666666),
            ),
          ),
        ),
      ),
    );
  }
}

// ── 1:1 Shopify Pebble Product Card ──────────────────────────────────────────
class _HotThisWeekProductCard extends StatefulWidget {
  final ProductModel product;
  final double cardWidth;
  final double imageHeight;
  final bool isWide;

  const _HotThisWeekProductCard({
    required this.product,
    required this.cardWidth,
    required this.imageHeight,
    required this.isWide,
  });

  @override
  State<_HotThisWeekProductCard> createState() =>
      _HotThisWeekProductCardState();
}

class _HotThisWeekProductCardState extends State<_HotThisWeekProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final primaryImg = product.primaryImageUrl;
    final secondaryImg = product.secondaryImageUrl;
    final hasCompare = product.compareAtPrice != null &&
        product.compareAtPrice!.isNotEmpty &&
        product.compareAtPrice != product.price;

    // Distinct variant colors for swatches
    final colors = product.variants
        .map((v) => v.color.trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          context.go('/products/${product.slug}');
        },
        child: SizedBox(
          width: widget.cardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 1. Image Container (3:4 Ratio with 2-Image Hover Cross-Fade) ─
              Container(
                width: widget.cardWidth,
                height: widget.imageHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Base Primary Image
                      if (primaryImg != null && primaryImg.isNotEmpty)
                        AnimatedScale(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          scale: _hovered ? 1.04 : 1.0,
                          child: Image.network(
                            primaryImg,
                            fit: BoxFit.cover,
                            cacheWidth: 600,
                            gaplessPlayback: true,
                            errorBuilder: (ctx, err, stack) => _placeholder(),
                          ),
                        )
                      else
                        _placeholder(),

                      // Secondary Image (Fades In Smoothly on Hover)
                      if (secondaryImg != null && secondaryImg.isNotEmpty)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          opacity: _hovered ? 1.0 : 0.0,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            scale: _hovered ? 1.04 : 1.0,
                            child: Image.network(
                              secondaryImg,
                              fit: BoxFit.cover,
                              cacheWidth: 600,
                              gaplessPlayback: true,
                              errorBuilder: (ctx, err, stack) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        ),

                      // Top-Left Badge (Sale / Hot / New / Popular)
                      if (product.badge.isNotEmpty)
                        Positioned(
                          top: 10,
                          left: 10,
                          child: _ProductBadge(badge: product.badge),
                        ),

                      // Top-Right Floating Quick View Icon
                      Positioned(
                        top: 10,
                        right: 10,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: (_hovered || !widget.isWide) ? 1.0 : 0.0,
                          child: _FloatingActionButton(
                            icon: Icons.search_rounded,
                            tooltip: 'Quick View',
                            onTap: () => showQuickView(context, product.slug),
                          ),
                        ),
                      ),

                      // Bottom Floating "Choose Options +" Pill Button
                      Positioned(
                        bottom: 12,
                        left: 14,
                        right: 14,
                        child: AnimatedSlide(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          offset: _hovered
                              ? Offset.zero
                              : const Offset(0, 0.25),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 220),
                            opacity: _hovered ? 1.0 : 0.0,
                            child: _ChooseOptionsButton(
                              onTap: () => showQuickView(context, product.slug),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── 2. Product Name ──────────────────────────────────────────
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111111),
                ),
              ),

              const SizedBox(height: 4),

              // ── 3. Price Row ─────────────────────────────────────────────
              Row(
                children: [
                  Text(
                    '\$${product.price}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: hasCompare
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF111111),
                    ),
                  ),
                  if (hasCompare) ...[
                    const SizedBox(width: 8),
                    Text(
                      '\$${product.compareAtPrice}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF888888),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),

              // ── 4. Color Swatches ────────────────────────────────────────
              if (colors.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: colors.take(5).map((colorName) {
                    final color = _resolveColor(colorName);
                    return Container(
                      margin: const EdgeInsets.only(right: 5),
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFCCCCCC),
                          width: 0.8,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF0EFEA),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 32,
        color: Color(0xFFB0AEA6),
      ),
    );
  }

  Color _resolveColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('red')) return const Color(0xFFC0392B);
    if (lower.contains('green')) return const Color(0xFF4C7053);
    if (lower.contains('brown')) return const Color(0xFF8B4513);
    if (lower.contains('navy') && lower.contains('blue')) return const Color(0xFF1F3A60);
    if (lower.contains('navy')) return const Color(0xFF1B2A4A);
    if (lower.contains('blue')) return const Color(0xFF4A90E2);
    if (lower.contains('grey') || lower.contains('gray')) return const Color(0xFF8E8E93);
    if (lower.contains('white')) return const Color(0xFFFFFFFF);
    if (lower.contains('mud')) return const Color(0xFF8B7355);
    if (lower.contains('cream')) return const Color(0xFFFFFDD0);
    if (lower.contains('fade rose') || lower.contains('rose')) return const Color(0xFFE8ADAA);
    if (lower.contains('pink')) return const Color(0xFFFFB6C1);
    if (lower.contains('black')) return const Color(0xFF1E1E1E);
    if (lower.contains('yellow')) return const Color(0xFFF1C40F);
    return const Color(0xFF7F8C8D);
  }
}

// ── Product Badge Tag ────────────────────────────────────────────────────────
class _ProductBadge extends StatelessWidget {
  final String badge;

  const _ProductBadge({required this.badge});

  @override
  Widget build(BuildContext context) {
    final isSale = badge.toLowerCase() == 'sale';
    final isHot = badge.toLowerCase() == 'hot';

    Color bgColor = const Color(0xFF111111);
    Color textColor = Colors.white;

    if (isSale) {
      bgColor = const Color(0xFFD32F2F);
    } else if (isHot) {
      bgColor = const Color(0xFF111111);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        badge,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: textColor,
        ),
      ),
    );
  }
}

// ── Floating Quick View Icon Button ──────────────────────────────────────────
class _FloatingActionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _FloatingActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_FloatingActionButton> createState() => _FloatingActionButtonState();
}

class _FloatingActionButtonState extends State<_FloatingActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          scale: _hovered ? 1.08 : 1.0,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              widget.icon,
              size: 17,
              color: const Color(0xFF111111),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Floating "Choose Options +" Pill Button ──────────────────────────────────
class _ChooseOptionsButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ChooseOptionsButton({required this.onTap});

  @override
  State<_ChooseOptionsButton> createState() => _ChooseOptionsButtonState();
}

class _ChooseOptionsButtonState extends State<_ChooseOptionsButton> {
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
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF111111) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            'Choose Options  +',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
              color: _hovered ? Colors.white : const Color(0xFF111111),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Carousel Outline Arrow Button with Left-to-Right Hover Wipe ──────────────
class _HotArrowButton extends StatefulWidget {
  final bool isNext;
  final bool isEnabled;
  final VoidCallback onTap;

  const _HotArrowButton({
    required this.isNext,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  State<_HotArrowButton> createState() => _HotArrowButtonState();
}

class _HotArrowButtonState extends State<_HotArrowButton> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = widget.isEnabled;

    return MouseRegion(
      cursor: isInteractive ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (isInteractive) setState(() => _hovered = true);
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
          _pressed = false;
        });
      },
      child: GestureDetector(
        onTapDown: (_) {
          if (isInteractive) setState(() => _pressed = true);
        },
        onTapUp: (_) {
          if (isInteractive) setState(() => _pressed = false);
        },
        onTapCancel: () {
          if (isInteractive) setState(() => _pressed = false);
        },
        onTap: isInteractive ? widget.onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isInteractive ? 1.0 : 0.40,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOutCubic,
            scale: _pressed
                ? 0.93
                : (_hovered && isInteractive ? 1.05 : 1.0),
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
                    // Smooth Left-to-Right Fill Wipe
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

                    // Directional Nudge Caret
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      offset: _hovered && isInteractive
                          ? (widget.isNext
                              ? const Offset(0.12, 0)
                              : const Offset(-0.12, 0))
                          : Offset.zero,
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
