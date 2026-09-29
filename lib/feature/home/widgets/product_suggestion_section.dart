import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/core/widgets/reveal_on_scroll.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/widgets/quick_view_sheet.dart';

/// 1:1 Pixel-Perfect Implementation of Shopify Pebble "Product Suggestion"
/// Section: "How you style it - Dress up in 3 steps. Pick - Pair - Play!"
/// (template--20816638214282__product_suggestion_kmXGYN).
///
/// Features:
/// - Centered tag and display heading
/// - 3-step single-open accordion with smooth animated expand/collapse
/// - Circular black step numbers (1, 2, 3)
/// - Feature chip badges with checkmark icons (4-Way Stretch, Eco-Friendly, 100% Cotton, Water Proof, Colorful)
/// - Responsive 4-card desktop grid / 2-card mobile grid
/// - High-fidelity product cards with hover secondary image cross-fade, badges,
///   quick-view floating search button, "Choose Options +" pill button, prices, and swatches.
class ProductSuggestionSection extends StatefulWidget {
  final ProductSuggestionModel suggestion;

  const ProductSuggestionSection({
    super.key,
    required this.suggestion,
  });

  @override
  State<ProductSuggestionSection> createState() => _ProductSuggestionSectionState();
}

class _ProductSuggestionSectionState extends State<ProductSuggestionSection> {
  // Step 1 is open by default (0-indexed: 0)
  int _openStepIndex = 0;

  void _toggleStep(int index) {
    setState(() {
      // In Shopify Pebble theme: data-single-open="true", data-at-least-one-item-open="true"
      _openStepIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = context.isWide;
    final steps = widget.suggestion.steps;

    return RevealOnScroll(
      child: Container(
        width: double.infinity,
        color: AppColors.background,
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? 48.0 : 20.0,
          vertical: isWide ? 72.0 : 44.0,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1380),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Section Header ──────────────────────────────────────────
                // Subheading Tag
                Text(
                  widget.suggestion.tag.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Display Heading
                Text(
                  widget.suggestion.heading,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: isWide ? 42 : 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.15,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: isWide ? 48 : 32),

                // ── 3-Step Accordion Cards ──────────────────────────────────
                Column(
                  children: List.generate(steps.length, (index) {
                    final step = steps[index];
                    final isOpen = _openStepIndex == index;

                    return _buildStepAccordionCard(
                      context,
                      step: step,
                      index: index,
                      isOpen: isOpen,
                      isWide: isWide,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepAccordionCard(
    BuildContext context, {
    required ProductSuggestionStepModel step,
    required int index,
    required bool isOpen,
    required bool isWide,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOpen ? const Color(0xFFE0E0E0) : const Color(0xFFEEEEEE),
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Step Summary Header ──────────────────────────────────────────
          InkWell(
            onTap: () => _toggleStep(index),
            splashColor: Colors.black.withValues(alpha: 0.04),
            highlightColor: Colors.black.withValues(alpha: 0.02),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 36.0 : 16.0,
                vertical: isWide ? 26.0 : 18.0,
              ),
              child: Row(
                children: [
                  // Circular Black Step Number
                  Container(
                    width: isWide ? 30 : 26,
                    height: isWide ? 30 : 26,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${step.stepNumber}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isWide ? 16 : 12),

                  // Step Title
                  Expanded(
                    child: Text(
                      step.title,
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: isWide ? 21 : 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),

                  // Feature Badges (Desktop)
                  if (isWide) ...[
                    _buildFeatureChips(step),
                    const SizedBox(width: 16),
                  ],

                  // Chevron indicator
                  AnimatedRotation(
                    turns: isOpen ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: isWide ? 26 : 22,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Feature Badges (Mobile - shown just below title when open or closed)
          if (!isWide && (step.badge1.isNotEmpty || step.badge2.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: _buildFeatureChips(step),
            ),

          // ── Animated Expand/Collapse Body ───────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            child: isOpen
                ? Padding(
                    padding: EdgeInsets.only(
                      left: isWide ? 36.0 : 16.0,
                      right: isWide ? 36.0 : 16.0,
                      bottom: isWide ? 36.0 : 20.0,
                      top: 4.0,
                    ),
                    child: _buildProductsGrid(context, step.products, isWide),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChips(ProductSuggestionStepModel step) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (step.badge1.isNotEmpty)
          _buildChipBadge(step.badge1),
        if (step.badge1.isNotEmpty && step.badge2.isNotEmpty)
          const SizedBox(width: 8),
        if (step.badge2.isNotEmpty)
          _buildChipBadge(step.badge2),
      ],
    );
  }

  Widget _buildChipBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD6D6D6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check,
            size: 13,
            color: Colors.black,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(
    BuildContext context,
    List<ProductModel> products,
    bool isWide,
  ) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isWide) {
      // Desktop: 4 items in a clean row
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: products.map((product) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: _SuggestionProductCard(
                product: product,
                isWide: isWide,
              ),
            ),
          );
        }).toList(),
      );
    } else {
      // Mobile: 2-column grid
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.58,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, idx) {
          return _SuggestionProductCard(
            product: products[idx],
            isWide: isWide,
          );
        },
      );
    }
  }
}

/// Product card matching Shopify Pebble styling:
/// - 3:4 aspect ratio thumbnail
/// - Smooth dual-image hover cross-fade
/// - Badges (Sale / Hot / New / Popular)
/// - Quick View button (shows quick view sheet)
/// - "Choose Options +" / "Quick Add" pill button
/// - Product title, sale and compare price
/// - Color variant swatches
class _SuggestionProductCard extends StatefulWidget {
  final ProductModel product;
  final bool isWide;

  const _SuggestionProductCard({
    required this.product,
    required this.isWide,
  });

  @override
  State<_SuggestionProductCard> createState() => _SuggestionProductCardState();
}

class _SuggestionProductCardState extends State<_SuggestionProductCard> {
  bool _isHovered = false;
  int _selectedColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final primaryImg = product.primaryImageUrl ?? '';
    final secondaryImg = product.secondaryImageUrl ?? primaryImg;

    final parsedPrice = double.tryParse(product.price);
    final displayPrice = parsedPrice != null
        ? '\$${parsedPrice.toStringAsFixed(2)}'
        : '\$${product.price}';

    final comparePriceNum = product.compareAtPrice != null
        ? double.tryParse(product.compareAtPrice!)
        : null;
    final displayComparePrice = comparePriceNum != null &&
            parsedPrice != null &&
            comparePriceNum > parsedPrice
        ? '\$${comparePriceNum.toStringAsFixed(2)}'
        : null;

    // Unique variant colors
    final colorVariants = product.variants
        .where((v) => v.color.isNotEmpty)
        .map((v) => v.color)
        .toSet()
        .toList();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          if (product.slug.isNotEmpty) {
            context.go('/products/${product.slug}');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: _isHovered ? 0.08 : 0.03,
                ),
                blurRadius: _isHovered ? 14 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Product Thumbnail & Actions ─────────────────────────────
              AspectRatio(
                aspectRatio: 0.75, // 3:4 ratio
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Primary Image with gentle hover zoom
                    Container(
                      color: const Color(0xFFF7F7F7),
                      child: primaryImg.isNotEmpty
                          ? AnimatedScale(
                              duration: const Duration(milliseconds: 320),
                              curve: Curves.easeOutCubic,
                              scale: _isHovered ? 1.04 : 1.0,
                              child: Image.network(
                                primaryImg,
                                fit: BoxFit.cover,
                                cacheWidth: 600,
                                gaplessPlayback: true,
                                errorBuilder: (ctx, err, stack) =>
                                    _placeholder(),
                              ),
                            )
                          : _placeholder(),
                    ),

                    // Secondary Image (Cross-fade on hover)
                    if (secondaryImg.isNotEmpty && secondaryImg != primaryImg)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        opacity: _isHovered ? 1.0 : 0.0,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                          scale: _isHovered ? 1.04 : 1.0,
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
                        top: 8,
                        left: 8,
                        child: _buildBadge(product.badge),
                      ),

                    // Top-Right Floating Quick View Icon
                    Positioned(
                      top: 8,
                      right: 8,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: (_isHovered || !widget.isWide) ? 1.0 : 0.0,
                        child: GestureDetector(
                          onTap: () => showQuickView(context, product.slug),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              size: 18,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bottom Floating "Choose Options +" Pill Button
                    Positioned(
                      bottom: 8,
                      left: 10,
                      right: 10,
                      child: AnimatedSlide(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        offset: _isHovered || !widget.isWide
                            ? Offset.zero
                            : const Offset(0, 0.3),
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _isHovered || !widget.isWide ? 1.0 : 0.0,
                          child: GestureDetector(
                            onTap: () => showQuickView(context, product.slug),
                            child: Container(
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  product.variants.length > 1
                                      ? 'Choose Options +'
                                      : 'Quick Add +',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Product Details (Title, Price, Swatches) ────────────────
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Title
                    Text(
                      product.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Price Row
                    Row(
                      children: [
                        Text(
                          displayPrice,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: displayComparePrice != null
                                ? const Color(0xFFD32F2F)
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (displayComparePrice != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            displayComparePrice,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Color(0xFF999999),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Swatches (if multiple colors available)
                    if (colorVariants.length > 1) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(
                          colorVariants.length.clamp(0, 4),
                          (cIdx) {
                            final isSelected = _selectedColorIndex == cIdx;
                            final colorName = colorVariants[cIdx];
                            final colorVal = _resolveColor(colorName);

                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedColorIndex = cIdx);
                              },
                              child: Container(
                                width: 14,
                                height: 14,
                                margin: const EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                  color: colorVal,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(Icons.image_outlined, size: 36, color: Color(0xFFB0B0B0)),
    );
  }

  Widget _buildBadge(String badge) {
    Color bg = const Color(0xFF111111);
    if (badge.toLowerCase() == 'sale') {
      bg = const Color(0xFFD32F2F);
    } else if (badge.toLowerCase() == 'hot') {
      bg = const Color(0xFFE65100);
    } else if (badge.toLowerCase() == 'popular') {
      bg = const Color(0xFF2E7D32);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        badge,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Color _resolveColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('green') || lower.contains('mint')) {
      return const Color(0xFF4C9A7D);
    }
    if (lower.contains('blue') || lower.contains('navy')) {
      return const Color(0xFF3B5998);
    }
    if (lower.contains('pink') || lower.contains('rose')) {
      return const Color(0xFFE58C96);
    }
    if (lower.contains('beige') || lower.contains('khaki') || lower.contains('straw')) {
      return const Color(0xFFD8C3A5);
    }
    if (lower.contains('red')) {
      return const Color(0xFFD32F2F);
    }
    if (lower.contains('brown')) {
      return const Color(0xFF8D6E63);
    }
    return const Color(0xFF757575);
  }
}
