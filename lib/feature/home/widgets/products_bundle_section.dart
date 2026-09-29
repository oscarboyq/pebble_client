import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/services/storage_service.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/core/widgets/reveal_on_scroll.dart';
import 'package:pebble_type/feature/cart/providers/cart_provider.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

/// 1:1 Pixel-Perfect Implementation of Shopify Pebble "Products Bundle"
/// Section: "Bundle & Save - Buy 2 Get 10% Off"
/// (template--20816638214282__products_bundle_mnDxAG).
///
/// Features:
/// - Responsive dual-column layout (Desktop flex row, mobile stacked column)
/// - Left column: Lifestyle image card with interactive hotspot pins (1 & 2)
///   with bidirectional hover/focus highlighting
/// - Right column:
///   - Subheading tag and display headline
///   - 2 bundle product cards side-by-side with hover dual-image flip,
///     price, sale badge, and size variant dropdown selector
///   - Bundle savings summary (Original total, discount, final price)
///   - "Add all to cart" primary black pill button with circular white arrow badge
class ProductsBundleSection extends ConsumerStatefulWidget {
  final ProductsBundleModel bundle;

  const ProductsBundleSection({super.key, required this.bundle});

  @override
  ConsumerState<ProductsBundleSection> createState() =>
      _ProductsBundleSectionState();
}

class _ProductsBundleSectionState extends ConsumerState<ProductsBundleSection> {
  // Highlighted hotspot index: null = neither focused (both 100%), 0 = item 1, 1 = item 2
  int? _hoveredHotspotIndex;

  // Selected size variants for each bundle product (mapped by product id -> size string)
  final Map<int, String> _selectedSizes = {};

  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _initDefaultSizes();
  }

  @override
  void didUpdateWidget(covariant ProductsBundleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initDefaultSizes();
  }

  void _initDefaultSizes() {
    for (final product in widget.bundle.bundleProducts) {
      final sizes = _getSizes(product);
      if (sizes.isNotEmpty && !sizes.contains(_selectedSizes[product.id])) {
        _selectedSizes[product.id] = sizes.first;
      }
    }
  }

  List<String> _getSizes(ProductModel product) {
    final sizes = product.variants
        .where((v) => v.stock > 0 && v.size.isNotEmpty)
        .map((v) => v.size)
        .toSet()
        .toList();
    return sizes;
  }

  ProductVariantModel? _selectedVariant(ProductModel product) {
    final available = product.variants
        .where((variant) => variant.stock > 0)
        .toList();
    if (available.isEmpty) return null;
    final sizes = _getSizes(product);
    if (sizes.isEmpty) return available.first;
    final size = _selectedSizes[product.id] ?? sizes.first;
    for (final variant in available) {
      if (variant.size == size) return variant;
    }
    return null;
  }

  bool get _bundlePurchasable =>
      widget.bundle.bundleProducts.length >= 2 &&
      widget.bundle.bundleProducts.every(
        (product) => _selectedVariant(product) != null,
      );

  double _calculateOriginalTotal() {
    double total = 0.0;
    for (final product in widget.bundle.bundleProducts) {
      final variant = _selectedVariant(product);
      final price =
          double.tryParse(variant?.priceOverride ?? product.price) ?? 0.0;
      total += price;
    }
    return total;
  }

  double _calculateDiscountedTotal() {
    final original = _calculateOriginalTotal();
    final discountFraction = widget.bundle.discountPercentage / 100.0;
    return original * (1.0 - discountFraction);
  }

  double _calculateSavings() {
    return _calculateOriginalTotal() - _calculateDiscountedTotal();
  }

  Future<void> _addAllToCart() async {
    if (_isAddingToCart || !_bundlePurchasable) return;

    final variantIds = [
      for (final product in widget.bundle.bundleProducts)
        _selectedVariant(product)!.id,
    ];

    final token = await StorageService.getAccessToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to add bundle to your cart'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.push(AppRoutes.login);
      }
      return;
    }

    setState(() => _isAddingToCart = true);

    try {
      final cartNotifier = ref.read(cartProvider.notifier);
      final success = await cartNotifier.addBundle(
        bundleId: widget.bundle.id,
        variantIds: variantIds,
      );
      if (!success) {
        throw StateError('Bundle could not be added.');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF111111),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFFF6FD7C),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Both items added. Review the applied offer in your cart.',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (_) {
      ref.invalidate(cartProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Bundle could not be added. Check availability and try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = context.isWide;
    final bundle = widget.bundle;

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
            child: isWide
                ? _buildDesktopLayout(context, bundle)
                : _buildMobileLayout(context, bundle),
          ),
        ),
      ),
    );
  }

  // ── Desktop Side-By-Side Layout ──────────────────────────────────────────
  Widget _buildDesktopLayout(BuildContext context, ProductsBundleModel bundle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left: Lifestyle Lookbook Image with Interactive Hotspots
        Expanded(flex: 1, child: _buildLifestyleBannerWithHotspots(bundle)),
        const SizedBox(width: 56),

        // Right: Header, Product Cards, Savings & CTA
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(bundle, isWide: true),
              const SizedBox(height: 36),
              _buildProductsRow(bundle, isWide: true),
              const SizedBox(height: 32),
              _buildBundlePricingSummary(),
              const SizedBox(height: 20),
              _buildAddAllToCartButton(bundle),
            ],
          ),
        ),
      ],
    );
  }

  // ── Mobile Stacked Layout ────────────────────────────────────────────────
  Widget _buildMobileLayout(BuildContext context, ProductsBundleModel bundle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Mobile Header on Top
        _buildHeader(bundle, isWide: false),
        const SizedBox(height: 28),

        // Lifestyle Image with Hotspots
        _buildLifestyleBannerWithHotspots(bundle),
        const SizedBox(height: 28),

        // Bundle Products
        _buildProductsRow(bundle, isWide: false),
        const SizedBox(height: 24),

        // Pricing Summary & CTA
        _buildBundlePricingSummary(),
        const SizedBox(height: 16),
        _buildAddAllToCartButton(bundle),
      ],
    );
  }

  // ── Header Block ─────────────────────────────────────────────────────────
  Widget _buildHeader(ProductsBundleModel bundle, {required bool isWide}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          bundle.tag.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          bundle.heading,
          textAlign: TextAlign.center,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: isWide ? 42 : 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.15,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ── Lifestyle Image with Hotspots ────────────────────────────────────────
  Widget _buildLifestyleBannerWithHotspots(ProductsBundleModel bundle) {
    final bannerUrl = bundle.bannerImage;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 0.882, // ~1660 / 1882
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Lifestyle Photo
            Container(
              color: const Color(0xFFF0F0F0),
              child: bannerUrl.isNotEmpty
                  ? Image.network(
                      bannerUrl,
                      fit: BoxFit.cover,
                      cacheWidth: 1200,
                      gaplessPlayback: true,
                      errorBuilder: (ctx, err, stack) => const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Color(0xFFB0B0B0),
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Color(0xFFB0B0B0),
                      ),
                    ),
            ),

            // Hotspot 1
            _buildHotspotPin(
              index: 0,
              label: '1',
              xPercent: bundle.hotspot1X,
              yPercent: bundle.hotspot1Y,
            ),

            // Hotspot 2
            _buildHotspotPin(
              index: 1,
              label: '2',
              xPercent: bundle.hotspot2X,
              yPercent: bundle.hotspot2Y,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotspotPin({
    required int index,
    required String label,
    required double xPercent,
    required double yPercent,
  }) {
    final isSelected = _hoveredHotspotIndex == index;

    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final xPos = (xPercent / 100.0) * constraints.maxWidth - 16;
          final yPos = (yPercent / 100.0) * constraints.maxHeight - 16;

          return Stack(
            children: [
              Positioned(
                left: xPos,
                top: yPos,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoveredHotspotIndex = index),
                  onExit: (_) => setState(() => _hoveredHotspotIndex = null),
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_hoveredHotspotIndex == index) {
                          _hoveredHotspotIndex = null;
                        } else {
                          _hoveredHotspotIndex = index;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: isSelected ? 36 : 30,
                      height: isSelected ? 36 : 30,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF111111),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isSelected ? 0.28 : 0.16,
                            ),
                            blurRadius: isSelected ? 12 : 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: isSelected ? 14 : 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Products Row ─────────────────────────────────────────────────────────
  Widget _buildProductsRow(ProductsBundleModel bundle, {required bool isWide}) {
    final products = bundle.bundleProducts;
    if (products.isEmpty) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(products.length.clamp(0, 2), (index) {
        final product = products[index];
        final isHighlighted =
            _hoveredHotspotIndex == null || _hoveredHotspotIndex == index;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 8.0 : 6.0),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              opacity: isHighlighted ? 1.0 : 0.45,
              child: _buildBundleProductCard(
                context,
                product: product,
                stepNumber: index + 1,
                index: index,
                isWide: isWide,
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Single Bundle Product Card ───────────────────────────────────────────
  Widget _buildBundleProductCard(
    BuildContext context, {
    required ProductModel product,
    required int stepNumber,
    required int index,
    required bool isWide,
  }) {
    final primaryImg = product.primaryImageUrl ?? '';
    final secondaryImg = product.secondaryImageUrl ?? primaryImg;

    final parsedPrice = double.tryParse(product.price);
    final displayPrice = parsedPrice != null
        ? '\$${parsedPrice.toStringAsFixed(2)}'
        : '\$${product.price}';

    final comparePriceNum = product.compareAtPrice != null
        ? double.tryParse(product.compareAtPrice!)
        : null;
    final displayComparePrice =
        comparePriceNum != null &&
            parsedPrice != null &&
            comparePriceNum > parsedPrice
        ? '\$${comparePriceNum.toStringAsFixed(2)}'
        : null;

    final availableSizes = _getSizes(product);
    final currentSize =
        _selectedSizes[product.id] ??
        (availableSizes.isNotEmpty ? availableSizes.first : '');

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredHotspotIndex = index),
      onExit: (_) => setState(() => _hoveredHotspotIndex = null),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hoveredHotspotIndex == index
                ? Colors.black
                : const Color(0xFFEEEEEE),
            width: _hoveredHotspotIndex == index ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Stack
            Stack(
              children: [
                // 3:4 Aspect Ratio Product Image
                AspectRatio(
                  aspectRatio: 0.75,
                  child: Container(
                    color: const Color(0xFFF7F7F7),
                    child: primaryImg.isNotEmpty
                        ? Image.network(
                            primaryImg,
                            fit: BoxFit.cover,
                            cacheWidth: 600,
                            gaplessPlayback: true,
                            errorBuilder: (ctx, err, stack) => const Center(
                              child: Icon(
                                Icons.image_outlined,
                                size: 36,
                                color: Color(0xFFB0B0B0),
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 36,
                              color: Color(0xFFB0B0B0),
                            ),
                          ),
                  ),
                ),

                // Secondary Image on hover
                if (secondaryImg.isNotEmpty && secondaryImg != primaryImg)
                  Positioned.fill(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      opacity: _hoveredHotspotIndex == index ? 1.0 : 0.0,
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

                // Top-Left Circular Step Number Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$stepNumber',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Top-Right Sale Badge if present
                if (product.badge.isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD32F2F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.badge,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Card Body: Title, Price, Size Selector Dropdown
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  InkWell(
                    onTap: () {
                      if (product.slug.isNotEmpty) {
                        context.go('/products/${product.slug}');
                      }
                    },
                    child: Text(
                      product.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                  const SizedBox(height: 10),

                  // Size Variant Dropdown
                  Container(
                    height: 34,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: availableSizes.isEmpty
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              product.totalStock > 0
                                  ? 'One size'
                                  : 'Unavailable',
                            ),
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: availableSizes.contains(currentSize)
                                  ? currentSize
                                  : availableSizes.firstOrNull,
                              isDense: true,
                              isExpanded: true,
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                size: 18,
                              ),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              items: availableSizes.map((size) {
                                return DropdownMenuItem<String>(
                                  value: size,
                                  child: Text(
                                    size.contains('/') ? size : 'Size: $size',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newSize) {
                                if (newSize != null) {
                                  setState(() {
                                    _selectedSizes[product.id] = newSize;
                                  });
                                }
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pricing Summary ──────────────────────────────────────────────────────
  Widget _buildBundlePricingSummary() {
    if (!_bundlePurchasable) {
      return const Text(
        'Bundle pricing is available when both products are in stock.',
      );
    }
    final original = _calculateOriginalTotal();
    final discounted = _calculateDiscountedTotal();
    final savings = _calculateSavings();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Discounted Final Total
            Text(
              '\$${discounted.toStringAsFixed(2)}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 10),

            // Original Strikethrough Total
            Text(
              '\$${original.toStringAsFixed(2)}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Color(0xFF888888),
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 12),

            // Green Savings Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Text(
                'Save ${widget.bundle.discountPercentage}% (\$${savings.toStringAsFixed(2)})',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Estimated savings. Your cart shows the final applied offer.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  // ── "Add All to Cart" Button ─────────────────────────────────────────────
  Widget _buildAddAllToCartButton(ProductsBundleModel bundle) {
    final canAdd = _bundlePurchasable && !_isAddingToCart;
    return InkWell(
      onTap: canAdd ? _addAllToCart : null,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
        decoration: BoxDecoration(
          color: _bundlePurchasable ? Colors.black : Colors.black38,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isAddingToCart)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else ...[
              Text(
                _bundlePurchasable ? bundle.buttonText : 'Bundle unavailable',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.black,
                  size: 16,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
