import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

/// A section displaying product cards with a subtle parallax effect
/// as the user scrolls. Each card shows a product image, title,
/// description, and a "Shop Now" call-to-action.

class ScrollingStoryCards extends StatelessWidget {
  final String? title;
  final List<ProductModel> products;

  const ScrollingStoryCards({super.key, this.title, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    final isWide = context.isWide;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional section title + "View all" link
        if (title != null)
          Padding(
            padding: EdgeInsetsGeometry.only(left: isWide ? 0 : 16, bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: isWide ? 26 : 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isWide)
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'View all →',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        // The story cards stack
        ...products.map(
          (product) => Padding(
            padding: EdgeInsetsGeometry.only(bottom: isWide ? 24 : 12),
            child: _StoryCard(product: product, isWide: isWide),
          ),
        ),
      ],
    );
  }
}

/// A single full-width story card that responds to scroll position
/// to create a subtle parallax effect on the background image.

class _StoryCard extends StatefulWidget {
  final ProductModel product;
  final bool isWide;
  const _StoryCard({required this.product, required this.isWide});

  @override
  State<_StoryCard> createState() => __StoryCardState();
}

class __StoryCardState extends State<_StoryCard> {
  // A key to track this widget's position on screen
  final _cardKey = GlobalKey();

  // The current parallax offset (in pixels)
  final ValueNotifier<double> _parallaxOffsetNotifier =
      ValueNotifier<double>(0.0);

  // Whether the card is visible (for the fade-in effect)
  bool _isVisible = false;

  // The scrollable ancestor's position — we listen to this
  ScrollPosition? _scrollPosition;

  double? _cachedCardContentY;
  double? _lastCardHeight;

  @override
  void initState() {
    super.initState();
    // Wait one frame so the widget tree is built, then check position
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateParallax());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedCardContentY = null;
    _lastCardHeight = null;
    // Find the nearest Scrollable widget (the home page ListView)
    // and listen to its scroll position changes
    _scrollPosition?.removeListener(_updateParallax);
    _scrollPosition = Scrollable.maybeOf(context)?.position;
    _scrollPosition?.addListener(_updateParallax);
  }

  @override
  void didUpdateWidget(covariant _StoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product != widget.product || oldWidget.isWide != widget.isWide) {
      _cachedCardContentY = null;
      _lastCardHeight = null;
    }
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_updateParallax);
    _parallaxOffsetNotifier.dispose();
    super.dispose();
  }

  /// Calculates the parallax offset based on this card's position
  /// relative to the viewport.
  void _updateParallax() {
    if (!mounted) return;

    final currentPixels = _scrollPosition?.pixels ?? 0.0;

    // Cache card content coordinate relative to scrollable; lazy-evaluated only once
    if (_cachedCardContentY == null || _lastCardHeight == null) {
      final renderBox =
          _cardKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.attached || !renderBox.hasSize) return;
      _lastCardHeight = renderBox.size.height;
      _cachedCardContentY =
          currentPixels + renderBox.localToGlobal(Offset.zero).dy;
    }

    final cardHeight = _lastCardHeight!;

    // Card's top edge position relative to the viewport via scalar subtraction
    final cardTop = _cachedCardContentY! - currentPixels;
    final viewHeight = MediaQuery.sizeOf(context).height;

    // Track visibility — once the card enters the viewport, keep it visible
    final isOnScreen = cardTop < viewHeight && (cardTop + cardHeight) > 0;

    if (isOnScreen) {
      if (!_isVisible) {
        setState(() {
          _isVisible = true;
        });
      }

      // Calculate where the card's center is relative to the viewport
      final cardCenter = cardTop + (cardHeight / 2);
      final fraction = cardCenter / viewHeight;

      // Map the fraction to a parallax pixel offset (-30 to +30px)
      final offset = (fraction - 0.5) * 60;

      if ((offset - _parallaxOffsetNotifier.value).abs() > 0.5) {
        _parallaxOffsetNotifier.value = offset;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isWide = widget.isWide;
    // Desktop: centered box with max width + rounded corners
    // Mobile: full bleed (edge to edge)
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: 1200),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isWide ? 12 : 0),
          child: SizedBox(
            height: isWide ? 480 : 320,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Parallax Image Layer ─────────────────────
                // This moves up/down based on scroll position
                // The image is taller than the card so it can translate
                // without showing empty edges
                ValueListenableBuilder<double>(
                  valueListenable: _parallaxOffsetNotifier,
                  builder: (context, offset, _) {
                    return _ParallaxImage(
                      imageUrl: product.primaryImageUrl,
                      offset: offset,
                    );
                  },
                ),
                // ── Gradient Overlay ──────────────────────────
                // Darkens the bottom portion so text is readable
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.65),
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
                // ── Text Content Layer ────────────────────────
                // This stays static (no parallax) — positioned at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: _isVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 600),
                    child: Padding(
                      padding: EdgeInsets.all(isWide ? 48 : 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Product badge (e.g., "New", "Sale")
                          if (product.badge.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: Text(
                                product.badge.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),
                          // Product name
                          Text(
                            product.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isWide ? 32 : 22,
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Description (truncated)
                          Text(
                            product.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: isWide ? 15 : 13,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 20),
                          Row(
                            children: [
                              // Price
                              Text(
                                '\$${product.price}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isWide ? 20 : 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (product.compareAtPrice != null) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '\$${product.compareAtPrice}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: isWide ? 14 : 12,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                              const Spacer(),
                              // Shop Now button
                              _ShopNowButton(
                                productSlug: product.slug,
                                isWide: isWide,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

/// The parallax image — it's taller than the parent so it can translate
/// without showing empty space at the edges.
class _ParallaxImage extends StatelessWidget {
  final String? imageUrl;
  final double offset;

  const _ParallaxImage({required this.imageUrl, required this.offset});

  @override
  Widget build(BuildContext context) {
    // The image is 120% the height of the card so it has room to move
    // The extra 20% is split: 10% above, 10% below
    // When offset is +30, the image moves up (looks like you're tilting down)
    // When offset is -30, the image moves down (looks like you're tilting up)
    return ClipRect(
      child: Transform.translate(
        offset: Offset(0, -offset),
        child: SizedBox(
          width: double.infinity,
          // Make the image taller than its container to allow movement
          height: double.infinity * 1.2,
          child: Center(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    cacheWidth: 800,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) => _placeholder(),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _placeholder();
                    },
                  )
                : _placeholder(),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.border.withValues(alpha: 0.3),
    child: const Center(
      child: Icon(
        Icons.image_outlined,
        color: AppColors.textSecondary,
        size: 48,
      ),
    ),
  );
}

/// A "Shop Now" button that appears on the story card.
/// On desktop: filled white button with dark text
/// On mobile: outlined white button (more subtle)
class _ShopNowButton extends StatefulWidget {
  final String productSlug;
  final bool isWide;

  const _ShopNowButton({required this.productSlug, required this.isWide});

  @override
  State<_ShopNowButton> createState() => _ShopNowButtonState();
}

class _ShopNowButtonState extends State<_ShopNowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/products/${widget.productSlug}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isWide ? 24 : 16,
            vertical: widget.isWide ? 12 : 8,
          ),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Shop Now',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: widget.isWide ? 13 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
