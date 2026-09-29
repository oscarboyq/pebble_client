import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/core/widgets/pebble_image.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/widgets/quick_view_sheet.dart';
import 'package:pebble_type/feature/products/widgets/product_color_swatch.dart';

/// Shopify Pebble-styled Product Card:
/// – Aspect-ratio portrait presentation with clean border & subtle hover elevation
/// – Dual-image crossfade & subtle scale on desktop hover (primary -> secondary image)
/// – Floating "+ Quick Add" rounded pill button sliding up on hover
/// – Live variant color swatches row beneath image with active ring & tooltip
/// – Terracotta "Sale" / discount % badge & dark "Sold out" badge
/// – Responsive wishlist heart button
class ProductCard extends ConsumerStatefulWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _hovered = false;
  int _selectedColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isWide = context.isWide;

    final colors = VariantEngine(widget.product.variants).allColors;
    final hasSecondary = widget.product.secondaryCardImageUrl != null;
    final primaryImg = widget.product.primaryCardImageUrl;
    final secondaryImg = widget.product.secondaryCardImageUrl;
    final isSoldOut = widget.product.totalStock <= 0;

    // Card container without box border (matching reference screenshot)
    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Image Area (Portrait / Flex) ──────────────────────────
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Base background
                Container(color: AppColors.mediaBackground),

                // 1. Primary image (scales on hover)
                AnimatedScale(
                  scale: (_hovered && isWide) ? 1.04 : 1.0,
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutCubic,
                  child: PebbleImage.card(
                    imageUrl: primaryImg,
                    fit: BoxFit.cover,
                    placeholder: _imagePlaceholder(),
                    errorWidget: _imagePlaceholder(),
                  ),
                ),

                // Load the second image only when a desktop shopper hovers.
                if (hasSecondary && _hovered && isWide)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: AppDimensions.motionStandard,
                    curve: Curves.easeInOut,
                    builder: (context, opacity, child) =>
                        Opacity(opacity: opacity, child: child),
                    child: PebbleImage.card(
                      imageUrl: secondaryImg,
                      fit: BoxFit.cover,
                      placeholder: const SizedBox.shrink(),
                      errorWidget: const SizedBox.shrink(),
                    ),
                  ),

                // 3. Badges (Top-Left)
                Positioned(top: 10, left: 10, child: _buildBadges(isSoldOut)),

                // 4. Quick View Magnifier search button (Top-Right on desktop hover)
                if (isWide)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _hovered ? 1.0 : 0.0,
                      child: _QuickSearchButton(
                        onTap: () =>
                            showQuickView(context, widget.product.slug),
                      ),
                    ),
                  ),

                // 5. Desktop: Floating "Choose Options (+)" Pill Button
                if (isWide)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    bottom: _hovered ? 12 : -56,
                    left: 20,
                    right: 20,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _hovered ? 1.0 : 0.0,
                      child: _QuickAddPill(
                        label: widget.product.variants.length > 1
                            ? 'Choose Options'
                            : 'Quick Add',
                        onTap: () =>
                            showQuickView(context, widget.product.slug),
                      ),
                    ),
                  ),

                // 6. Mobile: Quick View icon button in corner
                if (!isWide)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: IconButton(
                      tooltip: 'Quick view ${widget.product.name}',
                      onPressed: () =>
                          showQuickView(context, widget.product.slug),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface.withValues(
                          alpha: 0.92,
                        ),
                      ),
                      icon: const Icon(
                        Icons.search_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // ── Info Area ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 2, right: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Product Name
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F1F1F),
                  height: 1.25,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Price & Compare Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '\$${widget.product.price}',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F1F1F),
                    ),
                  ),
                  if (widget.product.compareAtPricesAsDouble != null &&
                      widget.product.compareAtPricesAsDouble! >
                          widget.product.priceAsDouble) ...[
                    const SizedBox(width: 6),
                    Text(
                      '\$${widget.product.compareAtPrice}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),

              // Variant Color Swatches (if 2 or more colors)
              if (colors.length > 1) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (
                      int i = 0;
                      i < (colors.length > 5 ? 5 : colors.length);
                      i++
                    ) ...[
                      _ColorSwatchDot(
                        colorName: colors[i],
                        isSelected: _selectedColorIndex == i,
                        onTap: () => setState(() => _selectedColorIndex = i),
                      ),
                      const SizedBox(width: 4),
                    ],
                    if (colors.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
                        child: Text(
                          '+${colors.length - 5}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );

    if (!isWide) {
      return InkWell(onTap: widget.onTap, child: card);
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(onTap: widget.onTap, child: card),
    );
  }

  Widget _buildBadges(bool isSoldOut) {
    if (isSoldOut) {
      return const _PebbleBadge(
        label: 'Sold out',
        backgroundColor: Color(0xFF262626),
        textColor: Colors.white,
      );
    }

    final badges = <Widget>[];

    if (widget.product.isOnSale) {
      final compare = widget.product.compareAtPricesAsDouble;
      final price = widget.product.priceAsDouble;
      String label = 'Sale';
      if (compare != null && compare > price) {
        final pct = (((compare - price) / compare) * 100).round();
        if (pct > 0) label = '-$pct%';
      }
      badges.add(
        _PebbleBadge(
          label: label,
          backgroundColor: const Color(0xFFC96E56),
          textColor: Colors.white,
        ),
      );
    }

    if (widget.product.badge.isNotEmpty) {
      final parts = widget.product.badge.split(RegExp(r'[,;/]'));
      for (final rawPart in parts) {
        final part = rawPart.trim();
        if (part.isEmpty) continue;
        final lower = part.toLowerCase();
        Color bg = const Color(0xFF262626);
        if (lower.contains('new')) {
          bg = const Color(0xFF4D7C59);
        } else if (lower.contains('pop') || lower.contains('best')) {
          bg = const Color(0xFF5E73AC);
        } else if (lower.contains('sale')) {
          bg = const Color(0xFFC96E56);
        }
        badges.add(
          _PebbleBadge(
            label: part,
            backgroundColor: bg,
            textColor: Colors.white,
          ),
        );
      }
    }

    if (badges.isEmpty) return const SizedBox.shrink();
    if (badges.length == 1) return badges.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < badges.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          badges[i],
        ],
      ],
    );
  }

  Widget _imagePlaceholder() => Container(
    color: const Color(0xFFF7F7F6),
    child: const Center(
      child: Icon(Icons.image_outlined, color: Color(0xFFD6D6D4), size: 36),
    ),
  );
}

// ── Floating Quick Add Pill Button ────────────────────────────────────────
class _QuickAddPill extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAddPill({required this.label, required this.onTap});

  @override
  State<_QuickAddPill> createState() => _QuickAddPillState();
}

class _QuickAddPillState extends State<_QuickAddPill> {
  bool _btnHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _btnHovered = true),
      onExit: (_) => setState(() => _btnHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: AppDimensions.motionFast,
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: _btnHovered ? const Color(0xFFF7F7F7) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: _btnHovered ? 0.18 : 0.10,
                ),
                blurRadius: _btnHovered ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1A1A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 13, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Circular Quick Search / View Button (Top-Right on Hover) ───────────────
class _QuickSearchButton extends StatefulWidget {
  final VoidCallback onTap;
  const _QuickSearchButton({required this.onTap});

  @override
  State<_QuickSearchButton> createState() => _QuickSearchButtonState();
}

class _QuickSearchButtonState extends State<_QuickSearchButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF1A1A1A) : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.search_rounded,
            size: 17,
            color: _hovered ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }
}

// ── Variant Color Swatch (Horizontal Bar matching Pebble) ──────────────────
class _ColorSwatchDot extends StatelessWidget {
  final String colorName;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatchDot({
    required this.colorName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: colorName,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: isSelected ? const EdgeInsets.all(1) : EdgeInsets.zero,
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: AppColors.textPrimary, width: 1.0)
                : null,
          ),
          child: ProductColorSwatch(name: colorName, width: 14, height: 7),
        ),
      ),
    );
  }
}

// ── Pebble Badge ──────────────────────────────────────────────────────────
class _PebbleBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _PebbleBadge({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.3,
          height: 1.1,
        ),
      ),
    );
  }
}
