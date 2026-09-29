import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/core/widgets/auto_pause_visibility.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/widgets/quick_view_sheet.dart';

/// Style & Comfort statement with inline icons followed by
/// the infinite horizontal auto-scrolling Lookbook cards marquee.
/// Recreates Shopify reference `highlight_text_with_image_zV4HWH`
/// and `custom_section_jEHjk8` (`color-scheme-7`).
class StyleComfortLookbookSection extends StatefulWidget {
  final List<LookbookCardModel> cards;

  const StyleComfortLookbookSection({super.key, required this.cards});

  @override
  State<StyleComfortLookbookSection> createState() =>
      _StyleComfortLookbookSectionState();
}

class _StyleComfortLookbookSectionState
    extends State<StyleComfortLookbookSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _marqueeController;
  final ScrollController _scrollController = ScrollController();
  bool _isMarqueeHovered = false;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    // 60s slow continuous linear scroll matching reference data-duration="60.0"
    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _marqueeController.addListener(_onMarqueeTick);
  }

  void _onMarqueeTick() {
    if (!_isMarqueeHovered &&
        _isVisible &&
        _scrollController.hasClients &&
        _scrollController.position.hasContentDimensions) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll > 0) {
        final target = _marqueeController.value * maxScroll;
        _scrollController.jumpTo(target);
      }
    }
  }

  @override
  void dispose() {
    _marqueeController.removeListener(_onMarqueeTick);
    _marqueeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(bool isVisible) {
    _isVisible = isVisible;
    _syncMarqueeState();
  }

  void _onPointerEnter(PointerEvent e) {
    _isMarqueeHovered = true;
    _syncMarqueeState();
  }

  void _onPointerExit(PointerEvent e) {
    _isMarqueeHovered = false;
    _syncMarqueeState();
  }

  void _syncMarqueeState() {
    if (_isVisible && !_isMarqueeHovered) {
      if (!_marqueeController.isAnimating) {
        _marqueeController.repeat();
      }
    } else {
      if (_marqueeController.isAnimating) {
        _marqueeController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = context.isWide;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive padding matching clamp(4.8rem, 7.558vw, 10.0rem)
    final vPadding = (screenWidth * 0.06).clamp(48.0, 96.0);

    return AutoPauseVisibility(
      onVisibilityChanged: _onVisibilityChanged,
      child: Container(
        width: double.infinity,
        color: const Color(
          0xFFF0EBFF,
        ), // Exact color-scheme-7 RGB(240, 235, 255)
        padding: EdgeInsets.symmetric(vertical: vPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── 1. Subheading ─────────────────────────────────────────────
            Text(
              'STYLE & COMFORT',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111111),
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 18),

            // ── 2. Display Headline with Inline Icons ─────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 820),
                child: _buildHeadlineWithInlineIcons(isWide),
              ),
            ),

            const SizedBox(height: 52),

            // ── 3. Infinite Scrolling Lookbook Cards Marquee ──────────────
            if (widget.cards.isNotEmpty)
              _buildLookbookMarquee(context, isWide, screenWidth),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadlineWithInlineIcons(bool isWide) {
    final iconSize = isWide ? 48.0 : 38.0;
    final headlineFontSize = isWide ? 46.0 : 28.0;

    return Text.rich(
      TextSpan(
        style: GoogleFonts.bricolageGrotesque(
          fontSize: headlineFontSize,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF111111),
          height: 1.18,
          letterSpacing: -0.5,
        ),
        children: [
          const TextSpan(text: 'Everyday '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Image.asset(
                'assets/images/icon_flower.png',
                width: iconSize,
                height: iconSize,
                errorBuilder: (ctx, err, stack) => Image.network(
                  'https://pebble-little.myshopify.com/cdn/shop/files/icon.png',
                  width: iconSize,
                  height: iconSize,
                  cacheWidth: 80,
                  gaplessPlayback: true,
                  errorBuilder: (c, e, s) =>
                      SizedBox(width: iconSize, height: iconSize),
                ),
              ),
            ),
          ),
          const TextSpan(text: ' comfort, with '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Image.asset(
                'assets/images/icon_sparkle.png',
                width: iconSize,
                height: iconSize,
                errorBuilder: (ctx, err, stack) => Image.network(
                  'https://pebble-little.myshopify.com/cdn/shop/files/icon-2.png',
                  width: iconSize,
                  height: iconSize,
                  cacheWidth: 80,
                  gaplessPlayback: true,
                  errorBuilder: (c, e, s) =>
                      SizedBox(width: iconSize, height: iconSize),
                ),
              ),
            ),
          ),
          const TextSpan(text: ' playful style for every little adventure.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLookbookMarquee(
    BuildContext context,
    bool isWide,
    double screenWidth,
  ) {
    // Card width clamp(28.8rem, 22.612vw + 11.457rem, 40.4rem)
    final cardWidth = (screenWidth * 0.24).clamp(280.0, 380.0);
    // Aspect ratio 0.73818 (height = width / 0.73818)
    final cardHeight = cardWidth / 0.73818;

    // Multiply card list to ensure smooth infinite loop
    final displayCards = [...widget.cards, ...widget.cards, ...widget.cards];

    return MouseRegion(
      onEnter: _onPointerEnter,
      onExit: _onPointerExit,
      child: SizedBox(
        height: cardHeight + 10,
        child: RepaintBoundary(
          child: ListView.separated(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: displayCards.length,
            separatorBuilder: (context, index) => const SizedBox(width: 32),
            itemBuilder: (context, index) {
              final card = displayCards[index];
              return _LookbookCardItem(
                card: card,
                width: cardWidth,
                height: cardHeight,
                onTapHotspot: () => _openShopTheLook(context, card, isWide),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openShopTheLook(
    BuildContext context,
    LookbookCardModel card,
    bool isWide,
  ) {
    if (isWide) {
      showDialog(
        context: context,
        builder: (dialogCtx) => _ShopTheLookDesktopDialog(card: card),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetCtx) => _ShopTheLookMobileSheet(card: card),
      );
    }
  }
}

/// Individual Lookbook Card with subtle zoom on hover and floating pill hotspot
class _LookbookCardItem extends StatefulWidget {
  final LookbookCardModel card;
  final double width;
  final double height;
  final VoidCallback onTapHotspot;

  const _LookbookCardItem({
    required this.card,
    required this.width,
    required this.height,
    required this.onTapHotspot,
  });

  @override
  State<_LookbookCardItem> createState() => _LookbookCardItemState();
}

class _LookbookCardItemState extends State<_LookbookCardItem> {
  bool _isCardHovered = false;
  bool _isButtonHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => setState(() => _isCardHovered = true),
      onExit: (e) => setState(() => _isCardHovered = false),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── 1. Outfit Image with subtle hover zoom ────────────
              AnimatedScale(
                scale: _isCardHovered ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                child: Image.network(
                  widget.card.image,
                  fit: BoxFit.cover,
                  cacheWidth: 800,
                  gaplessPlayback: true,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: const Color(0xFFE5DEFB),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE5DEFB),
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.grey,
                      size: 40,
                    ),
                  ),
                ),
              ),

              // ── 2. Interactive Hotspot Pill Badge ──────────────────
              Positioned(
                bottom: 18,
                right: 18,
                child: MouseRegion(
                  onEnter: (e) => setState(() => _isButtonHovered = true),
                  onExit: (e) => setState(() => _isButtonHovered = false),
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: widget.onTapHotspot,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _isButtonHovered
                            ? Colors.black
                            : Colors.white.withValues(alpha: 0.96),
                        borderRadius: BorderRadius.circular(24),
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
                          Icon(
                            Icons.local_offer_outlined,
                            size: 15,
                            color: _isButtonHovered
                                ? Colors.white
                                : Colors.black,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            widget.card.itemCountLabel,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _isButtonHovered
                                  ? Colors.white
                                  : Colors.black,
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

/// Desktop 2-column "Shop The Look" Modal Dialog
class _ShopTheLookDesktopDialog extends ConsumerWidget {
  final LookbookCardModel card;

  const _ShopTheLookDesktopDialog({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780, maxHeight: 560),
        child: Row(
          children: [
            // Left Column: Lookbook Outfit Photo
            SizedBox(
              width: 320,
              height: double.infinity,
              child: Image.network(
                card.image,
                fit: BoxFit.cover,
                cacheWidth: 600,
                gaplessPlayback: true,
                errorBuilder: (ctx, err, stack) => Container(
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(Icons.broken_image_outlined, size: 40),
                ),
              ),
            ),

            // Right Column: Tagged Products List
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Shop The Look',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 16),

                    // Products list
                    Expanded(
                      child: card.taggedProducts.isEmpty
                          ? const Center(
                              child: Text('No tagged items in this look.'),
                            )
                          : ListView.separated(
                              itemCount: card.taggedProducts.length,
                              separatorBuilder: (ctx, idx) => const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(
                                  height: 1,
                                  color: Color(0xFFF0F0F0),
                                ),
                              ),
                              itemBuilder: (context, idx) {
                                final product = card.taggedProducts[idx];
                                return _LookbookProductRow(
                                  product: product,
                                  onQuickAdd: () {
                                    Navigator.pop(context);
                                    showQuickView(context, product.slug);
                                  },
                                );
                              },
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
}

/// Mobile Bottom Sheet "Shop The Look" Drawer
class _ShopTheLookMobileSheet extends ConsumerWidget {
  final LookbookCardModel card;

  const _ShopTheLookMobileSheet({required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop The Look',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 14),

          // Product rows
          if (card.taggedProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text('No tagged items in this look.'),
            )
          else
            ...card.taggedProducts.map((product) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: _LookbookProductRow(
                  product: product,
                  onQuickAdd: () {
                    Navigator.pop(context);
                    showQuickView(context, product.slug);
                  },
                ),
              );
            }),
        ],
      ),
    );
  }
}

/// Reusable horizontal product card for Lookbook dialog / drawer
class _LookbookProductRow extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onQuickAdd;

  const _LookbookProductRow({required this.product, required this.onQuickAdd});

  @override
  Widget build(BuildContext context) {
    final isOnSale = product.isOnSale;

    final parsedPrice = double.tryParse(product.price);
    final displayPrice = parsedPrice != null
        ? '\$${parsedPrice.toStringAsFixed(2)}'
        : '\$${product.price}';

    final parsedCompare = product.compareAtPrice != null
        ? double.tryParse(product.compareAtPrice!)
        : null;
    final displayCompare = parsedCompare != null
        ? '\$${parsedCompare.toStringAsFixed(2)}'
        : (product.compareAtPrice != null
              ? '\$${product.compareAtPrice}'
              : null);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Product Thumbnail (76x96px)
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 76,
            height: 96,
            child:
                product.primaryImageUrl != null &&
                    product.primaryImageUrl!.isNotEmpty
                ? Image.network(
                    product.primaryImageUrl!,
                    fit: BoxFit.cover,
                    cacheWidth: 200,
                    gaplessPlayback: true,
                    errorBuilder: (ctx, err, stack) =>
                        Container(color: const Color(0xFFF5F5F5)),
                  )
                : Container(color: const Color(0xFFF5F5F5)),
          ),
        ),

        const SizedBox(width: 16),

        // Title, Badge, Price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOnSale)
                Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC4301C),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Sale',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              Text(
                product.name,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                children: [
                  Text(
                    displayPrice,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isOnSale
                          ? const Color(0xFFC4301C)
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (isOnSale && displayCompare != null)
                    Text(
                      displayCompare,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Quick Add Button
        ElevatedButton(
          onPressed: onQuickAdd,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Quick Add',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
