import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/services/content_service.dart';
import 'package:pebble_type/core/services/storage_service.dart';
import 'package:pebble_type/core/theme/app_text_styles.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/core/widgets/footer.dart';
import 'package:pebble_type/feature/cart/providers/cart_provider.dart';
import 'package:pebble_type/feature/content/models/content_models.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/providers/product_providers.dart';
import 'package:pebble_type/feature/products/widgets/product_card.dart';
import 'package:pebble_type/feature/reviews/providers/review_provider.dart';
import 'package:pebble_type/feature/reviews/widgets/review_card.dart';
import 'package:pebble_type/feature/reviews/widgets/star_rating.dart';
import 'package:pebble_type/feature/wishlist/providers/wishlist_provider.dart';
import 'package:video_player/video_player.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final String slug;
  const ProductDetailPage({super.key, required this.slug});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage>
    with SingleTickerProviderStateMixin {
  String? _selectedColor;
  String? _selectedSize;
  Map<String, String> _selectedAttributes = {};
  bool _variantsInitialized = false;
  int _selectedImageIndex = 0;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ProductDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slug != widget.slug) {
      _variantsInitialized = false;
      _selectedColor = null;
      _selectedSize = null;
      _selectedAttributes = {};
      _selectedImageIndex = 0;
    }
  }

  void _initVariants(List<ProductVariantModel> variants) {
    if (!_variantsInitialized && variants.isNotEmpty) {
      final engine = VariantEngine(variants);
      if (engine.usesAttributes) {
        // Initialize attributes from first variant
        _selectedAttributes = Map.from(variants.first.attributes);
      } else {
        _selectedColor = variants.first.color.isNotEmpty
            ? variants.first.color
            : (variants.first.attributes['color'] ??
                  variants.first.attributes['option1'] ??
                  (engine.allColors.isNotEmpty
                      ? engine.allColors.first
                      : null));
        _selectedSize =
            engine.autoSelectedSize(selectedColor: _selectedColor) ??
            (variants.first.size.isNotEmpty
                ? variants.first.size
                : (variants.first.attributes['size'] ??
                      variants.first.attributes['option2'] ??
                      (engine.allSizes.isNotEmpty
                          ? engine.allSizes.first
                          : null)));
      }
      _variantsInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = context.isWide;
    final productAsync = ref.watch(productDetailProvider(widget.slug));
    final isWishlisted =
        ref.watch(wishlistProvider).value?.contains(widget.slug) ?? false;

    if (isWide) {
      // Desktop: no bottom nav bar, no appbar (shell has WebHeader)
      return Scaffold(
        backgroundColor: AppColors.background,
        body: productAsync.when(
          data: (product) {
            _initVariants(product.variants);
            return _buildDesktop(product, isWishlisted);
          },
          error: (err, _) => _errorWidget(err.toString()),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    // Mobile: original AppBar + bottom ATC bar
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: productAsync.when(
        data: (product) {
          _initVariants(product.variants);
          return _buildMobile(product);
        },
        error: (err, _) => _errorWidget(err.toString()),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      bottomNavigationBar: productAsync.value != null
          ? _buildMobileATC(productAsync.value!, isWishlisted)
          : null,
    );
  }

  // ── DESKTOP LAYOUT ────────────────────────────────────────────────
  Widget _buildDesktop(ProductModel product, bool isWishlisted) {
    final images = product.images.isNotEmpty
        ? product.images
        : <ProductImageModel>[];

    return ListView(
      children: [
        // Breadcrumb
        Container(
          color: AppColors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          child: Row(
            children: [
              _BreadcrumbLink('Home', () => context.go(AppRoutes.dashboard)),
              _breadcrumbSep(),
              _BreadcrumbLink('Shop', () => context.go(AppRoutes.home)),
              _breadcrumbSep(),
              _BreadcrumbLink(
                product.category.name,
                () => context.go(AppRoutes.home),
              ),
              _breadcrumbSep(),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),

        // ── Main 2-col section ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: image gallery
              Expanded(
                flex: 5,
                child: _DesktopImageGallery(
                  key: ValueKey(product.slug),
                  images: images,
                  primaryUrl: product.primaryImageUrl,
                  selectedIndex: _selectedImageIndex,
                  onSelect: (i) => setState(() => _selectedImageIndex = i),
                ),
              ),
              const SizedBox(width: 48),

              // Right: product info + sticky ATC
              Expanded(
                flex: 4,
                child: _DesktopProductPanel(
                  product: product,
                  selectedColor: _selectedColor,
                  selectedSize: _selectedSize,
                  selectedAttributes: _selectedAttributes,
                  onAttributeChanged: (attrName, value) {
                    setState(() {
                      _selectedAttributes[attrName] = value;
                    });
                  },
                  onColorChanged: (c) {
                    setState(() {
                      _selectedColor = c;
                      // Auto-reset size if current selection is incompatible
                      final engine = VariantEngine(product.variants);
                      final compatibleSizes = engine.availableSizes(
                        selectedColor: c,
                      );
                      if (_selectedSize != null &&
                          !compatibleSizes.contains(_selectedSize)) {
                        _selectedSize = compatibleSizes.isNotEmpty
                            ? compatibleSizes.first
                            : null;
                      }
                    });
                  },
                  onSizeChanged: (s) {
                    setState(() {
                      _selectedSize = s;
                      // Auto-reset color if current selection is incompatible
                      final engine = VariantEngine(product.variants);
                      final compatibleColors = engine.availableColors(
                        selectedSize: s,
                      );
                      if (_selectedColor != null &&
                          !compatibleColors.contains(_selectedColor)) {
                        _selectedColor = compatibleColors.isNotEmpty
                            ? compatibleColors.first
                            : null;
                      }
                    });
                  },
                  onAddToCart: _addToCart,
                  onToggleWishlist: _toggleWishlist,
                  isWishlisted: isWishlisted,
                ),
              ),
            ],
          ),
        ),

        // ── Tabs: Description / Details / Reviews ───────────────
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            tabs: const [
              Tab(text: 'Description'),
              Tab(text: 'Details'),
              Tab(text: 'Reviews'),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        SizedBox(
          height: 320,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Description
              SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: Text(
                  product.description,
                  style: AppTextStyles.bodyMd.copyWith(height: 1.7),
                ),
              ),
              // Details
              SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: _DetailsTable(product: product),
              ),
              // Reviews
              _ReviewsSection(
                slug: widget.slug,
                productName: product.name,
                isDesktop: true,
              ),
            ],
          ),
        ),

        // ── Trust badges ────────────────────────────────────────
        const _TrustBadgesRow(),

        // ── Recommended ─────────────────────────────────────────
        _RecommendedSection(
          slug: widget.slug,
          intent: 'outfit',
          title: 'Complete the Look',
        ),
        _RecommendedSection(slug: widget.slug),

        // Footer
        const AppFooter(),
      ],
    );
  }

  // ── MOBILE LAYOUT (original) ──────────────────────────────────────
  Widget _buildMobile(ProductModel product) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MobileImageGallery(
            key: ValueKey(product.slug),
            images: product.images,
            primaryUrl: product.primaryImageUrl,
            selectedIndex: _selectedImageIndex,
            onChanged: (index) {
              setState(() => _selectedImageIndex = index);
            },
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      product.category.name.toUpperCase(),
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    if (product.badge.isNotEmpty) ...[
                      const Spacer(),
                      _Badge(label: product.badge),
                    ],
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(product.name, style: AppTextStyles.headlineLg),
                const SizedBox(height: AppDimensions.spacingSm),
                Builder(
                  builder: (context) {
                    final engine = VariantEngine(product.variants);
                    final exact = engine.findExact(
                      color: _selectedColor,
                      size: _selectedSize,
                    );
                    final hasOverride = exact?.priceOverride != null;
                    return Row(
                      children: [
                        Text(
                          hasOverride
                              ? '\$${exact!.priceOverride}'
                              : '\$${product.price}',
                          style: AppTextStyles.bodyLg.copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (hasOverride) ...[
                          const SizedBox(width: AppDimensions.spacingMd),
                          Text(
                            '\$${product.price}',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ] else if (product.compareAtPricesAsDouble != null) ...[
                          const SizedBox(width: AppDimensions.spacingMd),
                          Text(
                            '\$${product.compareAtPrice}',
                            style: AppTextStyles.bodyMd.copyWith(
                              fontSize: 16,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                if (product.variants.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingLg),
                  _VariantSelector(
                    variants: product.variants,
                    selectedColor: _selectedColor,
                    selectedSize: _selectedSize,
                    selectedAttributes: _selectedAttributes,
                    onAttributeChanged: (attrName, value) {
                      setState(() {
                        _selectedAttributes[attrName] = value;
                      });
                    },
                    onColorChanged: (c) {
                      setState(() {
                        _selectedColor = c;
                        final engine = VariantEngine(product.variants);
                        final compatibleSizes = engine.availableSizes(
                          selectedColor: c,
                        );
                        if (_selectedSize != null &&
                            !compatibleSizes.contains(_selectedSize)) {
                          _selectedSize = compatibleSizes.isNotEmpty
                              ? compatibleSizes.first
                              : null;
                        }
                      });
                    },
                    onSizeChanged: (s) {
                      setState(() {
                        _selectedSize = s;
                        final engine = VariantEngine(product.variants);
                        final compatibleColors = engine.availableColors(
                          selectedSize: s,
                        );
                        if (_selectedColor != null &&
                            !compatibleColors.contains(_selectedColor)) {
                          _selectedColor = compatibleColors.isNotEmpty
                              ? compatibleColors.first
                              : null;
                        }
                      });
                    },
                    product: product,
                  ),
                ],
                const SizedBox(height: AppDimensions.spacingXl),
                if (product.hasQuickSpecs) ...[
                  _QuickSpecsStrip(product: product),
                  const SizedBox(height: 20),
                ],
                if (product.hasVideo) ...[
                  _VideoFeedbackRow(product: product),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
          _MobileProductInfoSections(product: product),
          _RecommendedSection(
            slug: widget.slug,
            intent: 'outfit',
            title: 'Complete the Look',
          ),
          _RecommendedSection(slug: widget.slug),
          _ReviewsSection(
            slug: widget.slug,
            productName: product.name,
            isDesktop: false,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Future<void> _addToCart() async {
    final token = await StorageService.getAccessToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to add items to your cart'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.push(AppRoutes.login);
      }
      return;
    }
    int? variantId;
    final product = ref.read(productDetailProvider(widget.slug)).value;
    if (product != null && product.variants.isNotEmpty) {
      final engine = VariantEngine(product.variants);
      if (engine.usesAttributes && _selectedAttributes.isNotEmpty) {
        final match = engine.findExactByAttributes(_selectedAttributes);
        if (match != null) variantId = match.id;
      } else if (_selectedColor != null || _selectedSize != null) {
        final match = engine.findExact(
          color: _selectedColor,
          size: _selectedSize,
        );
        if (match != null) variantId = match.id;
      }
    }
    if (variantId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Select an available size or color before adding to cart.',
            ),
          ),
        );
      }
      return;
    }
    final success = await ref
        .read(cartProvider.notifier)
        .addItem(productSlung: widget.slug, variantId: variantId);
    if (mounted && success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Added to cart!')));
    } else if (mounted) {
      final error = ref.read(cartProvider).error;
      final data = error is DioException ? error.response?.data : null;
      final message = data is Map && data['detail'] is String
          ? data['detail'] as String
          : 'Could not add this item to cart.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _toggleWishlist() async {
    final token = await StorageService.getAccessToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to save items to your wishlist'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.push(AppRoutes.login);
      }
      return;
    }
    await ref.read(wishlistProvider.notifier).toggle(widget.slug);
  }

  Widget _buildMobileATC(ProductModel product, bool isWishlisted) {
    final canPurchase = product.totalStock > 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingMd,
        AppDimensions.spacingMd,
        AppDimensions.spacingLg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            height: AppDimensions.buttonHeight,
            width: AppDimensions.buttonHeight,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: IconButton(
              tooltip: isWishlisted
                  ? 'Remove from wishlist'
                  : 'Add to wishlist',
              icon: Icon(
                isWishlisted ? Icons.favorite : Icons.favorite_border,
                color: isWishlisted ? AppColors.primary : AppColors.textPrimary,
                size: 20,
              ),
              onPressed: _toggleWishlist,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                onPressed: canPurchase ? _addToCart : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
                child: Text(
                  canPurchase
                      ? 'Add to Cart'
                      : product.variants.isEmpty
                      ? 'Unavailable'
                      : 'Sold out',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorWidget(String msg) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(msg, style: const TextStyle(color: AppColors.error)),
        const SizedBox(height: AppDimensions.spacingMd),
        TextButton(
          onPressed: () => ref.invalidate(productDetailProvider(widget.slug)),
          child: const Text('Retry'),
        ),
      ],
    ),
  );

  Widget _BreadcrumbLink(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Text(
      label,
      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
    ),
  );

  Widget _breadcrumbSep() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 6),
    child: Text(
      '›',
      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
    ),
  );
}

class _MobileImageGallery extends StatelessWidget {
  final List<ProductImageModel> images;
  final String? primaryUrl;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  const _MobileImageGallery({
    super.key,
    required this.images,
    required this.primaryUrl,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final urls = images.isNotEmpty
        ? images.map((image) => image.image).toList()
        : <String>[if (primaryUrl != null) primaryUrl!];

    if (urls.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: AppColors.background,
          child: Center(
            child: Icon(
              Icons.image_outlined,
              color: AppColors.border,
              size: 60,
            ),
          ),
        ),
      );
    }
    final safeIndex = selectedIndex.clamp(0, urls.length - 1);

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            itemCount: urls.length,
            onPageChanged: onChanged,
            itemBuilder: (context, index) {
              return AnimatedSwitcher(
                duration: Duration(milliseconds: 220),
                child: Image.network(
                  urls[index],
                  semanticLabel:
                      images.length > index && images[index].altText.isNotEmpty
                      ? images[index].altText
                      : 'Product image ${index + 1}',
                  key: ValueKey(urls[index]),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  cacheWidth: 1000,
                  gaplessPlayback: true,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.background,
                    child: Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColors.border,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (urls.length > 1)
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _GalleryDots(count: urls.length, selectedIndex: safeIndex),
                _ImageCounter(current: safeIndex + 1, total: urls.length),
              ],
            ),
          ),
      ],
    );
  }
}

class _GalleryDots extends StatelessWidget {
  final int count;
  final int selectedIndex;
  const _GalleryDots({required this.count, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (index) {
        final selected = index == selectedIndex;
        return AnimatedContainer(
          duration: Duration(milliseconds: 180),
          margin: EdgeInsets.only(right: 6),
          width: selected ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.textPrimary
                : AppColors.surface.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _ImageCounter extends StatelessWidget {
  final int current;
  final int total;

  const _ImageCounter({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$current / $total',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

Future<void> _showProductVideoOverlay(
  BuildContext context, {
  required String videoUrl,
  required String productName,
}) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close video',
    barrierColor: Colors.black.withValues(alpha: 0.72),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, __, ___) {
      return _ProductVideoOverlay(videoUrl: videoUrl, productName: productName);
    },
    transitionBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.96, end: 1).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      );
    },
  );
}

// ── Desktop image gallery ─────────────────────────────────────────────────────
class _DesktopImageGallery extends StatefulWidget {
  final List<ProductImageModel> images;
  final String? primaryUrl;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _DesktopImageGallery({
    super.key,
    required this.images,
    required this.primaryUrl,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  State<_DesktopImageGallery> createState() => _DesktopImageGalleryState();
}

class _DesktopImageGalleryState extends State<_DesktopImageGallery> {
  bool _zoomed = false;
  Offset _zoomOffset = Offset.zero;

  String? _urlAt(int index) {
    if (widget.images.isNotEmpty && index < widget.images.length) {
      return widget.images[index].image;
    }
    return widget.primaryUrl;
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiple = widget.images.length > 1;
    final selectedUrl = _urlAt(widget.selectedIndex);
    final safeIndex = widget.images.isEmpty
        ? 0
        : widget.selectedIndex.clamp(0, widget.images.length - 1);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasMultiple)
          SizedBox(
            width: 74,
            child: Column(
              children: widget.images.asMap().entries.map((entry) {
                final isSelected = entry.key == safeIndex;
                return InkWell(
                  onTap: () => widget.onSelect(entry.key),
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.surface
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          entry.value.image,
                          semanticLabel: entry.value.altText.isNotEmpty
                              ? entry.value.altText
                              : 'View product image ${entry.key + 1}',
                          fit: BoxFit.cover,
                          cacheWidth: 160,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: AppColors.background,
                                child: Icon(
                                  Icons.image_outlined,
                                  color: AppColors.border,
                                  size: 22,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        if (hasMultiple) const SizedBox(width: 14),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.zoomIn,
                  onEnter: (event) => setState(() => _zoomed = true),
                  onExit: (event) {
                    setState(() {
                      _zoomed = false;
                      _zoomOffset = Offset.zero;
                    });
                  },
                  onHover: (event) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box == null || !box.attached || !box.hasSize) return;
                    final size = box.size;
                    final local = box.globalToLocal(event.position);
                    setState(() {
                      _zoomOffset = Offset(
                        (local.dx / size.width - 0.5) * -34,
                        (local.dy / size.height - 0.5) * -34,
                      );
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 140),
                    curve: Curves.easeOutCubic,
                    height: MediaQuery.of(context).size.height * 0.75,
                    transform: _zoomed
                        ? (Matrix4.identity()
                            ..translateByDouble(
                              _zoomOffset.dx,
                              _zoomOffset.dy,
                              0,
                              1,
                            )
                            ..scaleByDouble(1.28, 1.28, 1.28, 1))
                        : Matrix4.identity(),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeOutCubic,
                      child: selectedUrl != null
                          ? Image.network(
                              selectedUrl,
                              semanticLabel:
                                  widget.images.length > safeIndex &&
                                      widget
                                          .images[safeIndex]
                                          .altText
                                          .isNotEmpty
                                  ? widget.images[safeIndex].altText
                                  : 'Product image ${safeIndex + 1}',
                              key: ValueKey(selectedUrl),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              cacheWidth: 1200,
                              gaplessPlayback: true,
                              errorBuilder: (context, error, stackTrace) =>
                                  _DesktopImageEmpty(),
                            )
                          : _DesktopImageEmpty(),
                    ),
                  ),
                ),
                if (hasMultiple)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: _ImageCounter(
                      current: safeIndex + 1,
                      total: widget.images.length,
                    ),
                  ),

                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.zoom_in_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Hover to zoom',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
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
        ),
      ],
    );
  }
}

class _DesktopImageEmpty extends StatelessWidget {
  const _DesktopImageEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.border, size: 60),
      ),
    );
  }
}

// ── Desktop right panel ──────────────────────────────────────────────────────
class _DesktopProductPanel extends StatelessWidget {
  final ProductModel product;
  final String? selectedColor;
  final String? selectedSize;
  final Map<String, String> selectedAttributes;
  final ValueChanged<String> onColorChanged;
  final ValueChanged<String> onSizeChanged;
  final void Function(String, String)? onAttributeChanged;
  final Future<void> Function() onAddToCart;
  final Future<void> Function()? onToggleWishlist;
  final bool isWishlisted;

  const _DesktopProductPanel({
    required this.product,
    required this.selectedColor,
    required this.selectedSize,
    this.selectedAttributes = const {},
    required this.onColorChanged,
    required this.onSizeChanged,
    this.onAttributeChanged,
    required this.onAddToCart,
    this.onToggleWishlist,
    this.isWishlisted = false,
  });

  @override
  Widget build(BuildContext context) {
    final canPurchase = product.totalStock > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category + badge
        Row(
          children: [
            Text(
              product.category.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            if (product.badge.isNotEmpty) ...[
              const Spacer(),
              _Badge(label: product.badge),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // Name
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.25,
          ),
        ),
        const SizedBox(height: 16),

        // Price is now displayed inside _VariantSelector below
        const SizedBox(height: 24),

        // Variants
        if (product.variants.isNotEmpty) ...[
          _VariantSelector(
            variants: product.variants,
            selectedColor: selectedColor,
            selectedSize: selectedSize,
            selectedAttributes: selectedAttributes,
            onAttributeChanged: (attrName, value) {
              onAttributeChanged?.call(attrName, value);
            },
            onColorChanged: onColorChanged,
            onSizeChanged: onSizeChanged,
            product: product,
          ),
          const SizedBox(height: 28),
        ],

        if (product.hasQuickSpecs) ...[
          _QuickSpecsStrip(product: product),
          const SizedBox(height: 24),
        ],

        // ATC button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: canPurchase ? onAddToCart : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              elevation: 0,
            ),
            child: Text(
              canPurchase
                  ? 'Add to Cart'
                  : product.variants.isEmpty
                  ? 'Unavailable'
                  : 'Sold out',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Secondary: Add to Wishlist
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onToggleWishlist,
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: isWishlisted ? AppColors.primary : AppColors.textPrimary,
            ),
            label: Text(isWishlisted ? 'In Wishlist' : 'Add to Wishlist'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),

        //video row
        if (product.hasVideo) ...[
          SizedBox(height: 24),
          _VideoFeedbackRow(product: product),
        ],
        const SizedBox(height: 28),

        // Mini trust row
        const Divider(color: AppColors.border),
        const SizedBox(height: 12),

        const _PurchaseAssuranceList(),

        const SizedBox(height: 20),
        const Divider(color: AppColors.border),

        // SKU / meta
        const SizedBox(height: 10),
        _MetaRow('SKU', product.sku),
        _MetaRow('Category', product.category.name),
      ],
    );
  }
}

class _VideoFeedbackRow extends StatelessWidget {
  final ProductModel product;
  const _VideoFeedbackRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final videos = <String>[if (product.hasVideo) product.playableVideoUrl];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Video Feedbacks',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 14),
        SizedBox(
          height: 68,
          child: ListView.separated(
            itemCount: videos.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return _VideoFeedbackBubble(
                videoUrl: videos[index],
                productName: product.name,
                thumbnailUrl: product.primaryImageUrl,
              );
            },
            separatorBuilder: (_, _) => SizedBox(width: 12),
          ),
        ),
      ],
    );
  }
}

class _VideoFeedbackBubble extends StatelessWidget {
  final String videoUrl;
  final String productName;
  final String? thumbnailUrl;

  const _VideoFeedbackBubble({
    required this.videoUrl,
    required this.productName,
    required this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Watch video',
      child: GestureDetector(
        onTap: () => _showProductVideoOverlay(
          context,
          videoUrl: videoUrl,
          productName: productName,
        ),
        child: Container(
          width: 62,
          height: 62,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textPrimary, width: 1.4),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipOval(
                child: thumbnailUrl != null
                    ? Image.network(
                        thumbnailUrl!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        cacheWidth: 150,
                        gaplessPlayback: true,
                        errorBuilder: (_, __, ___) => _VideoBubbleFallback(),
                      )
                    : const _VideoBubbleFallback(),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoBubbleFallback extends StatelessWidget {
  const _VideoBubbleFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.background,
      child: const Icon(
        Icons.videocam_outlined,
        size: 24,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _PurchaseAssuranceList extends StatelessWidget {
  const _PurchaseAssuranceList();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        Icons.local_shipping_outlined,
        'Demo checkout',
        'No payment is collected',
      ),
      (
        Icons.inventory_2_outlined,
        'Stock checked',
        'Availability is checked at checkout',
      ),
      (Icons.person_outline, 'Account checkout', 'Sign in to place an order'),
    ];

    return Column(
      children: items.map((item) {
        return Padding(
          padding: EdgeInsets.only(bottom: item == items.last ? 0 : 12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(item.$1, size: 17, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.$2,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.$3,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _QuickSpecsStrip extends StatelessWidget {
  final ProductModel product;
  const _QuickSpecsStrip({required this.product});

  @override
  Widget build(BuildContext context) {
    final specs = <(IconData, String, String)>[
      if (product.material.isNotEmpty)
        (Icons.texture_outlined, 'Material', product.material),
      if (product.formattedWeight.isNotEmpty)
        (Icons.monitor_weight_outlined, 'Weight', product.formattedWeight),
      if (product.manufacturedBy.isNotEmpty)
        (Icons.verified_outlined, 'Made by', product.manufacturedBy),
    ];
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: specs.map((spec) {
          return Padding(
            padding: EdgeInsets.only(bottom: spec == specs.last ? 0 : 12),
            child: Row(
              children: [
                Icon(spec.$1, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                SizedBox(
                  width: 72,
                  child: Text(
                    spec.$2,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    spec.$3,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String key_;
  final String value;
  const _MetaRow(this.key_, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              key_,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ── Details table ─────────────────────────────────────────────────────────────
class _DetailsTable extends StatelessWidget {
  final ProductModel product;
  const _DetailsTable({required this.product});

  @override
  Widget build(BuildContext context) {
    final details = <_ProductDetailItem>[
      if (product.sku.trim().isNotEmpty)
        _ProductDetailItem(
          icon: Icons.confirmation_num_outlined,
          label: 'SKU',
          value: product.sku,
        ),
      _ProductDetailItem(
        icon: Icons.category_outlined,
        label: 'Category',
        value: product.category.name,
      ),
      if (product.formattedWeight.isNotEmpty)
        _ProductDetailItem(
          icon: Icons.monitor_weight_outlined,
          label: 'Weight',
          value: product.formattedWeight,
        ),

      _ProductDetailItem(
        icon: Icons.inventory_2_outlined,
        label: 'Stock',
        value: product.totalStock > 0
            ? '${product.totalStock} available'
            : 'Out of stock',
      ),
      if (product.manufacturedBy.trim().isNotEmpty)
        _ProductDetailItem(
          icon: Icons.verified_outlined,
          label: 'Manufactured By',
          value: product.manufacturedBy,
        ),

      if (product.specialFeatures.trim().isNotEmpty)
        _ProductDetailItem(
          icon: Icons.auto_awesome_outlined,
          label: 'Special Features',
          value: product.specialFeatures,
        ),
      if (product.careAndCleaning.trim().isNotEmpty)
        _ProductDetailItem(
          icon: Icons.local_laundry_service_outlined,
          label: 'Care & Cleaning',
          value: product.careAndCleaning,
        ),
    ];

    if (details.isEmpty) {
      return Text(
        'No product details available. ',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product Specifications',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Essential information, materials, care instructions, and product origin.',
          style: TextStyle(
            fontSize: 13,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        LayoutBuilder(
          builder: (context, constraints) {
            final isTwoColumn = constraints.maxWidth >= 720;
            final columns = isTwoColumn ? 2 : 1;
            const spacing = 14.0;
            final itemWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: details.map((item) {
                return SizedBox(
                  width: itemWidth,
                  child: _ProductDetailTile(item: item),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _MobileProductInfoSections extends StatelessWidget {
  final ProductModel product;

  const _MobileProductInfoSections({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
      child: Column(
        children: [
          const Divider(color: AppColors.border, height: 1),
          _MobileInfoTile(
            title: 'Description',
            initiallyExpanded: true,
            child: Text(
              product.description.trim().isNotEmpty
                  ? product.description
                  : 'No description available.',
              style: AppTextStyles.bodyMd.copyWith(
                height: 1.65,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          _MobileInfoTile(
            title: 'Product Details',
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: _DetailsTable(product: product),
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
        ],
      ),
    );
  }
}

class _MobileInfoTile extends StatelessWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const _MobileInfoTile({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Material(
        color: Colors.transparent,
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(
            bottom: AppDimensions.spacingMd,
          ),
          iconColor: AppColors.textPrimary,
          collapsedIconColor: AppColors.textPrimary,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          children: [Align(alignment: Alignment.centerLeft, child: child)],
        ),
      ),
    );
  }
}

class _ProductVideoOverlay extends StatefulWidget {
  final String videoUrl;
  final String productName;

  const _ProductVideoOverlay({
    required this.videoUrl,
    required this.productName,
  });

  @override
  State<_ProductVideoOverlay> createState() => _ProductVideoOverlayState();
}

class _ProductVideoOverlayState extends State<_ProductVideoOverlay> {
  late final VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    _controller
        .initialize()
        .then((_) {
          if (!mounted) return;
          setState(() => _initialized = true);
          _controller.play();
        })
        .catchError((e) {
          //debugprint('VIDEO INIT ERROR: $e');
          if (!mounted) return;
          setState(() => _hasError = true);
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_initialized || _hasError) return;

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth = width > 900 ? 860.0 : width - 28;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: maxWidth,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 32,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 10, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.productName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              AspectRatio(
                aspectRatio: _initialized
                    ? _controller.value.aspectRatio
                    : 16 / 9,
                child: GestureDetector(
                  onTap: _togglePlay,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: _initialized && !_hasError
                            ? VideoPlayer(_controller)
                            : Container(color: AppColors.background),
                      ),
                      if (!_initialized && !_hasError)
                        const CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      if (_hasError)
                        const Text(
                          'Video could not be loaded.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      if (_initialized && !_controller.value.isPlaying)
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.48),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            size: 46,
                            color: Colors.white,
                          ),
                        ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.52),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Product video',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Flexible(
                              child: Text(
                                widget.productName,
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _ProductDetailItem {
  final IconData icon;
  final String label;
  final String value;

  const _ProductDetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _ProductDetailTile extends StatelessWidget {
  final _ProductDetailItem item;

  const _ProductDetailTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(item.icon, size: 18, color: AppColors.textPrimary),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  item.value,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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

// ── Trust badges full-width row ───────────────────────────────────────────────
class _TrustBadgesRow extends StatelessWidget {
  const _TrustBadgesRow();

  static const _items = [
    (Icons.shopping_bag_outlined, 'Demo Checkout', 'No payment collected'),
    (
      Icons.inventory_2_outlined,
      'Stock Checked',
      'Availability checked at checkout',
    ),
    (Icons.lock_outline, 'Account Orders', 'Sign in to place an order'),
    (Icons.verified_outlined, 'Curated Looks', 'Owner selected pairings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F3F0),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 40),
      child: Row(
        children: _items.map((item) {
          return Expanded(
            child: Column(
              children: [
                Icon(item.$1, size: 26, color: AppColors.textPrimary),
                const SizedBox(height: 8),
                Text(
                  item.$2,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.$3,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Variant selector ──────────────────────────────────────────────────────────
// ── Variant selector with cross-filtering ─────────────────────────────────────
class _VariantSelector extends StatefulWidget {
  final List<ProductVariantModel> variants;
  final String? selectedColor;
  final String? selectedSize;
  final ValueChanged<String> onColorChanged;
  final ValueChanged<String> onSizeChanged;
  final ProductModel product;
  // New: for attribute-based selection
  final Map<String, String> selectedAttributes;
  final void Function(String attrName, String value)? onAttributeChanged;

  const _VariantSelector({
    required this.variants,
    required this.selectedColor,
    required this.selectedSize,
    required this.onColorChanged,
    required this.onSizeChanged,
    required this.product,
    this.selectedAttributes = const {},
    this.onAttributeChanged,
  });

  @override
  State<_VariantSelector> createState() => _VariantSelectorState();
}

class _VariantSelectorState extends State<_VariantSelector> {
  late VariantEngine _engine;

  @override
  void initState() {
    super.initState();
    _engine = VariantEngine(widget.variants);
  }

  @override
  void didUpdateWidget(_VariantSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.variants != widget.variants) {
      _engine = VariantEngine(widget.variants);
    }
  }

  ProductVariantModel? _findSelectedVariant() {
    if (_engine.usesAttributes) {
      return _engine.findExactByAttributes(widget.selectedAttributes);
    }
    return _engine.findExact(
      color: widget.selectedColor,
      size: widget.selectedSize,
    );
  }

  String _computeStockLabel(ProductVariantModel? fullVariant) {
    final stock = fullVariant?.stock ?? widget.product.totalStock;
    if (stock <= 0) return 'Out of stock';
    if (stock <= 5) return 'Only $stock left';
    return 'In stock';
  }

  @override
  Widget build(BuildContext context) {
    final fullVariant = _findSelectedVariant();
    final selectedStock = fullVariant?.stock ?? widget.product.totalStock;
    final isOut = selectedStock <= 0;
    final stockLabel = _computeStockLabel(fullVariant);

    // If using attributes, render attribute-based selectors
    if (_engine.usesAttributes) {
      return _buildAttributesUI(fullVariant, isOut, stockLabel);
    }

    // Otherwise render legacy color/size UI
    return _buildLegacyUI(fullVariant, isOut, stockLabel);
  }

  // ── NEW: Attribute-based variant rendering (jewelry) ──
  Widget _buildAttributesUI(
    ProductVariantModel? fullVariant,
    bool isOut,
    String stockLabel,
  ) {
    final filteredAttrNames = _engine.attributeNames.where((attr) {
      final l = attr.toLowerCase().trim();
      return l != 'title' && l != 'default title';
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dynamic attribute selectors
        for (final attrName in filteredAttrNames) ...[
          _buildAttributeSection(attrName),
          const SizedBox(height: 16),
        ],

        // Price display
        _buildPriceDisplay(fullVariant),
        const SizedBox(height: 14),

        // Stock pill
        _StockPill(
          label: stockLabel,
          inStock: !isOut,
          stock: fullVariant?.stock ?? widget.product.totalStock,
        ),
      ],
    );
  }

  Widget _buildAttributeSection(String attrName) {
    final allValues = _engine.attributeValues(attrName);
    final availableValues = _engine.availableAttributeValues(
      attrName,
      selected: widget.selectedAttributes,
    );
    final currentValue = widget.selectedAttributes[attrName] ?? '';

    final isColorAttr =
        const {
          'color',
          'colour',
          'option1',
        }.contains(attrName.toLowerCase().trim()) ||
        allValues.any((val) => _ProductColor.isKnownColor(val));

    final isSizeAttr = const {
      'size',
      'option2',
    }.contains(attrName.toLowerCase().trim());

    final displayLabel = isColorAttr
        ? 'COLOR'
        : (isSizeAttr ? 'SIZE' : attrName.toUpperCase());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              displayLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            if (currentValue.isNotEmpty) ...[
              const SizedBox(width: 12),
              Text(
                currentValue,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: isColorAttr ? 10 : 8,
          runSpacing: isColorAttr ? 10 : 8,
          children: allValues.map((value) {
            final isSelected = currentValue == value;
            final isAvailable = availableValues.contains(value);

            void handleTap() {
              widget.onAttributeChanged?.call(attrName, value);
              if (!isAvailable) {
                for (final otherAttr in _engine.attributeNames) {
                  if (otherAttr == attrName) continue;
                  final hasCompatibleVariant = widget.variants.any((v) {
                    if (v.attributes[attrName] != value) return false;
                    final otherVal = widget.selectedAttributes[otherAttr] ?? '';
                    if (otherVal.isEmpty) return true;
                    return v.attributes[otherAttr] == otherVal;
                  });
                  if (!hasCompatibleVariant) {
                    final updatedAttrs = {
                      ...widget.selectedAttributes,
                      attrName: value,
                    };
                    final availableForOther = _engine.availableAttributeValues(
                      otherAttr,
                      selected: updatedAttrs,
                    );
                    if (availableForOther.isNotEmpty) {
                      widget.onAttributeChanged?.call(
                        otherAttr,
                        availableForOther.first,
                      );
                    } else {
                      widget.onAttributeChanged?.call(otherAttr, '');
                    }
                  }
                }
              }
            }

            if (isColorAttr) {
              return _ColorSwatchOption(
                label: value,
                selected: isSelected,
                available: isAvailable,
                onTap: handleTap,
              );
            }

            return _VariantChip(
              label: value,
              selected: isSelected,
              enabled: isAvailable,
              onTap: handleTap,
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── LEGACY: Color + Size rendering (clothing) ──
  Widget _buildLegacyUI(
    ProductVariantModel? fullVariant,
    bool isOut,
    String stockLabel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // COLOR
        if (_engine.allColors.isNotEmpty) ...[
          Row(
            children: [
              const Text(
                'COLOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              if (widget.selectedColor != null) ...[
                const SizedBox(width: 12),
                Text(
                  widget.selectedColor!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _engine.allColors.map((color) {
              final isSelected = widget.selectedColor == color;
              final isAvailable = _engine
                  .availableColors(selectedSize: widget.selectedSize)
                  .contains(color);
              return _ColorSwatchOption(
                label: color,
                selected: isSelected,
                available: isAvailable,
                onTap: () => widget.onColorChanged(color),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // SIZE
        if (_engine.allSizes.isNotEmpty) ...[
          Row(
            children: [
              const Text(
                'SIZE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
              if (widget.selectedSize != null) ...[
                const SizedBox(width: 12),
                Text(
                  widget.selectedSize!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => const _SizeGuideDialog(),
                ),
                child: const Text(
                  'Size Guide',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _engine.allSizes.map((size) {
              final isSelected = widget.selectedSize == size;
              final isAvailable = _engine
                  .availableSizes(selectedColor: widget.selectedColor)
                  .contains(size);
              return _VariantChip(
                label: size,
                selected: isSelected,
                enabled: isAvailable,
                onTap: () => widget.onSizeChanged(size),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Price + stock
        _buildPriceDisplay(fullVariant),
        const SizedBox(height: 14),
        _StockPill(
          label: stockLabel,
          inStock: !isOut,
          stock: fullVariant?.stock ?? widget.product.totalStock,
        ),
      ],
    );
  }

  // ── Shared price display ──
  Widget _buildPriceDisplay(ProductVariantModel? fullVariant) {
    if (fullVariant != null && fullVariant.priceOverride != null) {
      final overridePrice = double.tryParse(fullVariant.priceOverride!) ?? 0.0;
      final basePrice = double.tryParse(widget.product.price) ?? 0.0;
      final hasDiscount = basePrice > overridePrice && basePrice > 0;
      final discountPct = hasDiscount
          ? (((basePrice - overridePrice) / basePrice) * 100).round()
          : 0;

      return Row(
        children: [
          Text(
            '\$${fullVariant.priceOverride}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (hasDiscount) ...[
            const SizedBox(width: 12),
            Text(
              '\$${widget.product.price}',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '-$discountPct%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      );
    }

    // Default price
    final compareAt = widget.product.compareAtPricesAsDouble;
    final currentPrice = widget.product.priceAsDouble;
    final hasCompareDiscount =
        compareAt != null && compareAt > currentPrice && compareAt > 0;
    final compareDiscountPct = hasCompareDiscount
        ? (((compareAt - currentPrice) / compareAt) * 100).round()
        : 0;

    return Row(
      children: [
        Text(
          '\$${widget.product.price}',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (hasCompareDiscount) ...[
          const SizedBox(width: 12),
          Text(
            '\$${widget.product.compareAtPrice}',
            style: const TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '-$compareDiscountPct%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _VariantChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  const _VariantChip({
    required this.label,
    required this.selected,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = enabled ? 1.0 : 0.45;

    return Opacity(
      opacity: opacity,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.surface : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductColor {
  static const Map<String, Color> _palette = {
    'black': Color(0xFF181818),
    'blue': Color(0xFF2563EB),
    'brown': Color(0xFF6B4423),
    'cherry': Color(0xFF8B1E3F),
    'cream': Color(0xFFF7F2E7),
    'dusty rose': Color(0xFFC98A7D),
    'fade rose': Color(0xFFE8B4B8),
    'forest green': Color(0xFF1E4D2B),
    'green': Color(0xFF388E3C),
    'grey': Color(0xFF757575),
    'gray': Color(0xFF757575),
    'mint': Color(0xFFA2E8DD),
    'mud': Color(0xFF705335),
    'navy': Color(0xFF1D2D50),
    'olive': Color(0xFF708238),
    'orange': Color(0xFFFF9800),
    'pink': Color(0xFFF06292),
    'purple': Color(0xFF7E57C2),
    'red': Color(0xFFC0392B),
    'white': Color(0xFFFFFFFF),
    'yellow': Color(0xFFFDD835),
    'beige': Color(0xFFD8C3A5),
  };

  static bool isKnownColor(String name) {
    final n = name.trim().toLowerCase();
    if (n.isEmpty) return false;
    if (n.startsWith('#')) return true;
    if (n.contains('/')) {
      final parts = n.split('/');
      return parts.every((p) => _palette.containsKey(p.trim()));
    }
    return _palette.containsKey(n);
  }

  static Color singleColor(String name) {
    final n = name.trim().toLowerCase();
    if (n.startsWith('#')) {
      final hex = n.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    }
    return _palette[n] ?? const Color(0xFF9E9E9E);
  }

  static List<Color> getColors(String name) {
    final n = name.trim().toLowerCase();
    if (n.contains('/')) {
      final parts = n.split('/');
      return parts.map((p) => singleColor(p.trim())).toList();
    }
    return [singleColor(n)];
  }
}

class _ColorSwatchOption extends StatelessWidget {
  final String label;
  final bool selected;
  final bool available;
  final VoidCallback onTap;

  const _ColorSwatchOption({
    required this.label,
    required this.selected,
    this.available = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _ProductColor.getColors(label);
    final isDualTone = colors.length >= 2;
    final primaryColor = colors.first;
    final secondaryColor = isDualTone ? colors[1] : primaryColor;

    final isLight =
        primaryColor.computeLuminance() > 0.70 ||
        (isDualTone && secondaryColor.computeLuminance() > 0.70);

    return Opacity(
      opacity: available ? 1.0 : 0.40,
      child: Tooltip(
        message: label,
        child: MouseRegion(
          cursor: available
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.textPrimary : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isDualTone
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: const [0.0, 0.5, 0.5, 1.0],
                          colors: [
                            primaryColor,
                            primaryColor,
                            secondaryColor,
                            secondaryColor,
                          ],
                        )
                      : null,
                  color: isDualTone ? null : primaryColor,
                  border: Border.all(
                    color: isLight ? const Color(0xFFD6D6D6) : Colors.black12,
                    width: 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: selected
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: isLight ? AppColors.textPrimary : Colors.white,
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class _SizeOption extends StatelessWidget {
//   final String label;
//   final bool selected;
//   final VoidCallback onTap;

//   const _SizeOption({
//     required this.label,
//     required this.selected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         curve: Curves.easeOutCubic,
//         constraints: const BoxConstraints(minWidth: 46, minHeight: 42),
//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//         decoration: BoxDecoration(
//           color: selected ? AppColors.textPrimary : AppColors.surface,
//           borderRadius: BorderRadius.circular(6),
//           border: Border.all(
//             color: selected ? AppColors.textPrimary : AppColors.border,
//           ),
//           boxShadow: selected
//               ? [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.08),
//                     blurRadius: 12,
//                     offset: const Offset(0, 5),
//                   ),
//                 ]
//               : null,
//         ),
//         child: Center(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               color: selected ? Colors.white : AppColors.textPrimary,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class _StockPill extends StatelessWidget {
  final String label;
  final bool inStock;
  final int stock;
  const _StockPill({
    required this.label,
    required this.inStock,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    final Color tone = inStock
        ? stock <= 5
              ? const Color(0xFFB76E00)
              : const Color(0xFF1F7A4D)
        : AppColors.error;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: tone, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: tone,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final isSale = label.toLowerCase() == 'sale';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingXm,
      ),
      decoration: BoxDecoration(
        color: isSale ? AppColors.error : AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.surface,
          height: 1.2,
        ),
      ),
    );
  }
}

// ── Reviews section ───────────────────────────────────────────────────────────
class _ReviewsSection extends ConsumerWidget {
  final String slug;
  final String productName;
  final bool isDesktop;
  const _ReviewsSection({
    required this.slug,
    required this.productName,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsProvider(slug));

    final padding = isDesktop
        ? const EdgeInsets.all(32)
        : const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop) const Divider(color: AppColors.border),
          const SizedBox(height: AppDimensions.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              reviewsAsync.when(
                data: (reviews) {
                  final avg = reviews.isEmpty
                      ? 0.0
                      : reviews.map((r) => r.rating).reduce((a, b) => a + b) /
                            reviews.length;
                  return Row(
                    children: [
                      Text(
                        'Reviews',
                        style: AppTextStyles.bodyLg.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (reviews.isNotEmpty) ...[
                        const SizedBox(width: AppDimensions.spacingSm),
                        StarRating(rating: avg.round(), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${avg.toStringAsFixed(1)} (${reviews.length})',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  );
                },
                loading: () => Text(
                  'Reviews',
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                error: (_, __) => Text(
                  'Reviews',
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () async {
                  final token = await StorageService.getAccessToken();
                  if (token == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please sign in to write a review'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      context.push(AppRoutes.login);
                    }
                    return;
                  }
                  if (context.mounted) {
                    context.push(
                      AppRoutes.writeReview.replaceFirst(':slug', slug),
                      extra: productName,
                    );
                  }
                },
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Write Review'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          reviewsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (_, __) => const Text('Could not load reviews.'),
            data: (reviews) {
              if (reviews.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.spacingMd,
                  ),
                  child: Text(
                    'No reviews yet. Be the first!',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }
              if (isDesktop) {
                // Desktop: 2-col grid
                final rows = <Widget>[];
                for (var i = 0; i < reviews.length; i += 2) {
                  rows.add(
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: ReviewCard(review: reviews[i])),
                        const SizedBox(width: 16),
                        Expanded(
                          child: i + 1 < reviews.length
                              ? ReviewCard(review: reviews[i + 1])
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  );
                  rows.add(const SizedBox(height: 12));
                }
                return Column(children: rows);
              }
              return Column(
                children: reviews
                    .map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimensions.spacingMd,
                        ),
                        child: ReviewCard(review: r),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Recommended products ──────────────────────────────────────────────────────
class _RecommendedSection extends ConsumerWidget {
  final String slug;
  final String intent;
  final String title;
  const _RecommendedSection({
    required this.slug,
    this.intent = 'related',
    this.title = 'You May Also Like',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (slug: slug, intent: intent);
    final recommendedAsync = ref.watch(recommendedProvider(args));
    final isWide = context.isWide;

    return recommendedAsync.when(
      loading: () => const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: AppColors.border),
            Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 40 : AppDimensions.spacingMd,
                AppDimensions.spacingMd,
                isWide ? 40 : AppDimensions.spacingMd,
                AppDimensions.spacingSm,
              ),
              child: Text(
                title,
                style: AppTextStyles.bodyLg.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isWide ? 22 : 16,
                ),
              ),
            ),
            if (isWide)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const cols = 4;
                    const spacing = 16.0;
                    final itemW =
                        (constraints.maxWidth - spacing * (cols - 1)) / cols;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: products.take(4).map((p) {
                        return SizedBox(
                          width: itemW,
                          height: itemW / 0.62,
                          child: ProductCard(
                            product: p,
                            onTap: () =>
                                context.pushReplacement('/products/${p.slug}'),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              )
            else
              SizedBox(
                height: 260,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMd,
                  ),
                  itemCount: products.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppDimensions.spacingMd),
                  itemBuilder: (_, index) {
                    final p = products[index];
                    return SizedBox(
                      width: 160,
                      child: ProductCard(
                        product: p,
                        onTap: () =>
                            context.pushReplacement('/products/${p.slug}'),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: AppDimensions.spacingMd),
          ],
        );
      },
    );
  }
}

class _SizeGuideDialog extends StatelessWidget {
  const _SizeGuideDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 620),
        child: FutureBuilder<SizeChartModel?>(
          future: ContentService.getSizeChart(),
          builder: (context, snapshot) {
            final chart = snapshot.data;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Size Guide',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else if (chart == null || chart.columns.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Text(
                        'Size information is not available for this product yet.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (chart.name.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  chart.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            Table(
                              border: TableBorder.all(color: AppColors.border),
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                  ),
                                  children: chart.columns
                                      .map(
                                        (c) => Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            c,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 13,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                ...chart.rows.map(
                                  (row) => TableRow(
                                    children: row
                                        .map(
                                          (cell) => Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Text(
                                              cell,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                            if (chart.note.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: Text(
                                  chart.note,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
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
          },
        ),
      ),
    );
  }
}
