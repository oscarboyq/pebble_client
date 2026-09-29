import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/constants/app_strings.dart';
import 'package:pebble_type/core/providers/header_provider.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

class MegaMenu extends ConsumerStatefulWidget {
  final List<CategoryModel> categories;
  final ShopMenuModel shopMenu;
  final String bannerImage;
  final String bannerCtaText;
  final String bannerCtaLink;
  final String navKey;

  const MegaMenu({
    super.key,
    required this.categories,
    required this.shopMenu,
    required this.bannerImage,
    required this.bannerCtaText,
    required this.bannerCtaLink,
    required this.navKey,
  });

  @override
  ConsumerState<MegaMenu> createState() => _MegaMenuState();
}

class _MegaMenuState extends ConsumerState<MegaMenu> {
  String _activeSection = 'new_arrivals';

  /// Authentic 1:1 category lists per section directly from the Pebble Shopify theme.
  static final Map<String, List<CategoryModel>> _defaultSectionCategories = {
    'new_arrivals': [
      CategoryModel(
        id: 1,
        name: 'T-Shirts',
        slug: 't-shirts',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-1.jpg',
      ),
      CategoryModel(
        id: 2,
        name: 'Sets',
        slug: 'sets',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-5.jpg',
      ),
      CategoryModel(
        id: 3,
        name: 'Sweaters',
        slug: 'sweaters',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-2.jpg',
      ),
      CategoryModel(
        id: 4,
        name: 'Accessories',
        slug: 'accessories',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-6.jpg',
      ),
      CategoryModel(
        id: 5,
        name: 'Outerwear',
        slug: 'outerwear',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-3.jpg',
      ),
      CategoryModel(
        id: 6,
        name: 'Shirts',
        slug: 'shirts',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-7.jpg',
      ),
      CategoryModel(
        id: 7,
        name: 'Pants',
        slug: 'pants',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-4.jpg',
      ),
      CategoryModel(
        id: 8,
        name: 'Shoes',
        slug: 'girls-shoes',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-8.jpg',
      ),
    ],
    'best_sellers': [
      CategoryModel(
        id: 9,
        name: 'Outerwear',
        slug: 'outerwear',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-9.jpg',
      ),
      CategoryModel(
        id: 10,
        name: 'Accessories',
        slug: 'accessories',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-15.jpg',
      ),
      CategoryModel(
        id: 11,
        name: 'Pants',
        slug: 'pants',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-13.jpg',
      ),
      CategoryModel(
        id: 12,
        name: 'Shorts',
        slug: 'shorts',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-11.jpg',
      ),
      CategoryModel(
        id: 13,
        name: 'Dresses',
        slug: 'girls-dresses',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-14.jpg',
      ),
      CategoryModel(
        id: 14,
        name: 'T-Shirts',
        slug: 't-shirts',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-16.jpg',
      ),
      CategoryModel(
        id: 15,
        name: 'Skirts',
        slug: 'girls-skirts',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-10.jpg',
      ),
      CategoryModel(
        id: 16,
        name: 'Sandals',
        slug: 'sandals',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-12.jpg',
      ),
    ],
    'clothing': [
      CategoryModel(
        id: 17,
        name: 'Outerwear',
        slug: 'outerwear',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-17.jpg',
      ),
      CategoryModel(
        id: 18,
        name: 'Bags',
        slug: 'girls-bags',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-20.jpg',
      ),
      CategoryModel(
        id: 19,
        name: 'Pants',
        slug: 'pants',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-13.jpg',
      ),
      CategoryModel(
        id: 20,
        name: 'Coats & Jackets',
        slug: 'coats-jackets',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-21.jpg',
      ),
      CategoryModel(
        id: 21,
        name: 'Dresses',
        slug: 'girls-dresses',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-18.jpg',
      ),
      CategoryModel(
        id: 22,
        name: 'T-Shirts',
        slug: 't-shirts',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-22.jpg',
      ),
      CategoryModel(
        id: 23,
        name: 'Accessories',
        slug: 'accessories',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-19.jpg',
      ),
    ],
    'shop_all': [
      CategoryModel(
        id: 24,
        name: 'Shirts',
        slug: 'shirts',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-7.jpg',
      ),
      CategoryModel(
        id: 25,
        name: 'Sandals',
        slug: 'sandals',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-12.jpg',
      ),
      CategoryModel(
        id: 26,
        name: 'Outerwear',
        slug: 'outerwear',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-3.jpg',
      ),
      CategoryModel(
        id: 27,
        name: 'Coats & Jackets',
        slug: 'coats-jackets',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-21.jpg',
      ),
      CategoryModel(
        id: 28,
        name: 'Accessories',
        slug: 'accessories',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-15.jpg',
      ),
      CategoryModel(
        id: 29,
        name: 'Pants',
        slug: 'pants',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-4.jpg',
      ),
      CategoryModel(
        id: 30,
        name: 'Bags',
        slug: 'girls-bags',
        image:
            'https://pebble-little.myshopify.com/cdn/shop/files/menu-shop-collection-20.jpg',
      ),
    ],
  };

  static final Map<String, ShopMenuPromoModel> _defaultPromos = {
    'new_arrivals': ShopMenuPromoModel(
      eyebrow: 'NEW COLLECTION',
      title: 'The Cozy Crew',
      ctaText: 'Shop Now',
      ctaLink: '/products?sort=newest',
      image:
          'https://pebble-little.myshopify.com/cdn/shop/files/menu-banner-shop-v2.webp',
      bgColor: '#84A999',
    ),
    'best_sellers': ShopMenuPromoModel(
      eyebrow: 'MOST POPULAR',
      title: 'Loved by Little Ones',
      ctaText: 'Explore Best Sellers',
      ctaLink: '/products?sort=best_selling',
      image:
          'https://pebble-little.myshopify.com/cdn/shop/files/menu-collection-banner-1-v2.webp',
      bgColor: '#D39E82',
    ),
    'clothing': ShopMenuPromoModel(
      eyebrow: 'SEASONAL FAVORITES',
      title: 'Everyday Essentials',
      ctaText: 'View All Clothing',
      ctaLink: '/collections/clothing',
      image:
          'https://pebble-little.myshopify.com/cdn/shop/files/menu-collection-banner-2-v2.webp',
      bgColor: '#7B9EA8',
    ),
    'shop_all': ShopMenuPromoModel(
      eyebrow: 'FULL CATALOG',
      title: 'Explore Everything',
      ctaText: 'Shop Collection',
      ctaLink: '/products',
      image:
          'https://pebble-little.myshopify.com/cdn/shop/files/menu-collection-banner-3-v2.webp',
      bgColor: '#C49B71',
    ),
  };

  ShopMenuPromoModel get _activePromo {
    final sectionPromo = widget.shopMenu.sections[_activeSection]?.promo;
    if (sectionPromo != null && sectionPromo.title.isNotEmpty) {
      return sectionPromo;
    }
    return _defaultPromos[_activeSection] ?? _defaultPromos['new_arrivals']!;
  }

  List<CategoryModel> get _activeCategories {
    final sectionCategories = widget.shopMenu.categoriesFor(_activeSection);
    if (sectionCategories.isNotEmpty) return sectionCategories;
    if (widget.shopMenu.sections.containsKey(_activeSection)) return const [];
    return _defaultSectionCategories[_activeSection] ??
        _defaultSectionCategories['new_arrivals']!;
  }

  List<ProductModel> get _activeProducts =>
      widget.shopMenu.sections[_activeSection]?.products ?? const [];

  bool get _activeShowsProducts =>
      widget.shopMenu.sections[_activeSection]?.showsProducts ?? false;

  void _setActiveSection(String section) {
    if (_activeSection == section) return;
    setState(() {
      _activeSection = section;
    });
  }

  @override
  Widget build(BuildContext context) {
    final activePromo = _activePromo;
    final defaultImg =
        _defaultPromos[_activeSection]?.image ??
        'https://pebble-little.myshopify.com/cdn/shop/files/menu-banner-shop-v2.webp';
    final sectionImg =
        (activePromo.image != null && activePromo.image!.isNotEmpty)
        ? activePromo.image!
        : defaultImg;

    final String promoImage = sectionImg;
    final String eyebrow = activePromo.eyebrow.isNotEmpty
        ? activePromo.eyebrow
        : 'NEW COLLECTION';
    final String headline = activePromo.title.isNotEmpty
        ? activePromo.title
        : 'The Cozy Crew';
    final String ctaText = activePromo.ctaText.isNotEmpty
        ? activePromo.ctaText
        : 'Shop Now';
    final String ctaLink = activePromo.ctaLink.isNotEmpty
        ? activePromo.ctaLink
        : '/products';
    final String bgColorHex = activePromo.bgColor.isNotEmpty
        ? activePromo.bgColor
        : '#84A999';

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.headerMaxWidth,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Left column: tabs with underline indicator ─────
              _MenuLinksColumn(
                activeSection: _activeSection,
                onHoverSection: _setActiveSection,
              ),
              const SizedBox(width: 48),

              // ── Middle column: 2 columns of categories (switches dynamically on section hover) ──
              Expanded(
                flex: 5,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.015, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(
                      'content_${_activeSection}_$_activeShowsProducts',
                    ),
                    child: _activeShowsProducts
                        ? _ProductGrid(products: _activeProducts)
                        : _CategoryGrid(categories: _activeCategories),
                  ),
                ),
              ),
              const SizedBox(width: 40),

              // ── Right column: curated promo banner card (switches dynamically with section) ──
              Expanded(
                flex: 4,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: _BannerCard(
                    key: ValueKey('banner_${_activeSection}_$promoImage'),
                    imageUrl: promoImage,
                    eyebrow: eyebrow,
                    title: headline,
                    ctaText: ctaText,
                    ctaLink: ctaLink,
                    bgColorHex: bgColorHex,
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

// ── Left column: menu links ──────────────────────────────────────
class _MenuLinksColumn extends StatelessWidget {
  final String activeSection;
  final ValueChanged<String> onHoverSection;

  const _MenuLinksColumn({
    required this.activeSection,
    required this.onHoverSection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MenuLink(
          text: AppStrings.newArrivals,
          route: '/products?sort=newest',
          sectionKey: 'new_arrivals',
          isActive: activeSection == 'new_arrivals',
          onHover: onHoverSection,
        ),
        const SizedBox(height: 8),
        _MenuLink(
          text: AppStrings.bestSellers,
          route: '/products?sort=best_selling',
          sectionKey: 'best_sellers',
          isActive: activeSection == 'best_sellers',
          onHover: onHoverSection,
        ),
        const SizedBox(height: 8),
        _MenuLink(
          text: AppStrings.clothing,
          route: '/collections/clothing',
          sectionKey: 'clothing',
          isActive: activeSection == 'clothing',
          onHover: onHoverSection,
        ),
        const SizedBox(height: 8),
        _MenuLink(
          text: AppStrings.shopAll,
          route: '/products',
          sectionKey: 'shop_all',
          isActive: activeSection == 'shop_all',
          onHover: onHoverSection,
        ),
      ],
    );
  }
}

class _MenuLink extends ConsumerStatefulWidget {
  final String text;
  final String route;
  final String sectionKey;
  final bool isActive;
  final ValueChanged<String> onHover;

  const _MenuLink({
    required this.text,
    required this.route,
    required this.sectionKey,
    required this.isActive,
    required this.onHover,
  });

  @override
  ConsumerState<_MenuLink> createState() => __MenuLinkState();
}

class __MenuLinkState extends ConsumerState<_MenuLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (event) {
        setState(() => _hovered = true);
        widget.onHover(widget.sectionKey);
      },
      onHover: (event) {
        if (!_hovered) {
          setState(() => _hovered = true);
        }
        widget.onHover(widget.sectionKey);
      },
      onExit: (event) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onFocusChange: (focused) {
          if (focused) widget.onHover(widget.sectionKey);
        },
        onTap: () {
          ref.read(activeMegaMenuProvider.notifier).state = null;
          context.go(widget.route);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? Colors.black.withValues(alpha: 0.05)
                : (_hovered
                      ? Colors.black.withValues(alpha: 0.03)
                      : Colors.transparent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 15,
                  fontWeight: widget.isActive
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: widget.isActive || _hovered
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: 2,
                width: widget.isActive ? 22 : 0,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Middle column: 2-column category grid with rounded square badges ──
class _CategoryGrid extends ConsumerWidget {
  final List<CategoryModel> categories;

  const _CategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayCategories = categories.take(8).toList();
    final half = (displayCategories.length / 2).ceil();
    final col1 = displayCategories.take(half).toList();
    final col2 = displayCategories.skip(half).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: col1.map((cat) => _CategoryItemRow(cat: cat)).toList(),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: col2.map((cat) => _CategoryItemRow(cat: cat)).toList(),
          ),
        ),
      ],
    );
  }
}

class _CategoryItemRow extends ConsumerStatefulWidget {
  final CategoryModel cat;

  const _CategoryItemRow({required this.cat});

  @override
  ConsumerState<_CategoryItemRow> createState() => _CategoryItemRowState();
}

class _CategoryItemRowState extends ConsumerState<_CategoryItemRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.opaque,
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          ref.read(activeMegaMenuProvider.notifier).state = null;
          context.go('/products?category=${widget.cat.slug}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.black.withValues(alpha: 0.035)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: _hovered ? 1.05 : 1.0,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      widget.cat.image != null && widget.cat.image!.isNotEmpty
                      ? Image.network(
                          widget.cat.image!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.checkroom_outlined,
                                size: 20,
                                color: Color(0xFF888888),
                              ),
                        )
                      : const Icon(
                          Icons.checkroom_outlined,
                          size: 20,
                          color: Color(0xFF888888),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.cat.name,
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 14,
                        fontWeight: _hovered
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: _hovered
                            ? AppColors.accentWarm
                            : AppColors.textPrimary,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      height: 1.5,
                      width: _hovered ? 24 : 0,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accentWarm,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Middle column: product grid (when section display_mode == products) ──
class _ProductGrid extends ConsumerWidget {
  final List<ProductModel> products;

  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayProducts = products.take(8).toList();
    final half = (displayProducts.length / 2).ceil();
    final col1 = displayProducts.take(half).toList();
    final col2 = displayProducts.skip(half).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: col1.map((p) => _ProductItemRow(product: p)).toList(),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: col2.map((p) => _ProductItemRow(product: p)).toList(),
          ),
        ),
      ],
    );
  }
}

class _ProductItemRow extends ConsumerStatefulWidget {
  final ProductModel product;

  const _ProductItemRow({required this.product});

  @override
  ConsumerState<_ProductItemRow> createState() => _ProductItemRowState();
}

class _ProductItemRowState extends ConsumerState<_ProductItemRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final imageUrl = product.primaryImageUrl;

    return MouseRegion(
      hitTestBehavior: HitTestBehavior.opaque,
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          ref.read(activeMegaMenuProvider.notifier).state = null;
          context.go('/products/${product.slug}');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.black.withValues(alpha: 0.035)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: _hovered ? 1.05 : 1.0,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F3F3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.checkroom_outlined,
                                size: 20,
                                color: Color(0xFF888888),
                              ),
                        )
                      : const Icon(
                          Icons.checkroom_outlined,
                          size: 20,
                          color: Color(0xFF888888),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 14,
                        fontWeight: _hovered
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: _hovered
                            ? AppColors.accentWarm
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '\$${product.priceAsDouble.toStringAsFixed(2)}',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Right column: banner with CTA ─────────────────────────────
class _BannerCard extends ConsumerStatefulWidget {
  final String imageUrl;
  final String eyebrow;
  final String title;
  final String ctaText;
  final String ctaLink;
  final String bgColorHex;

  const _BannerCard({
    super.key,
    required this.imageUrl,
    required this.eyebrow,
    required this.title,
    required this.ctaText,
    required this.ctaLink,
    required this.bgColorHex,
  });

  @override
  ConsumerState<_BannerCard> createState() => _BannerCardState();
}

class _BannerCardState extends ConsumerState<_BannerCard> {
  bool _hovered = false;

  Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF84A999);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _parseColor(widget.bgColorHex);
    final hasImage = widget.imageUrl.isNotEmpty;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          final route = widget.ctaLink.trim();
          if (route.isEmpty) return;
          ref.read(activeMegaMenuProvider.notifier).state = null;
          context.go(route);
        },
        child: Container(
          height: 270,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (hasImage)
                Positioned.fill(
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    scale: _hovered ? 1.05 : 1.0,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),
                  ),
                ),
              if (hasImage)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.58),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.eyebrow.toUpperCase(),
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                            color: hasImage
                                ? Colors.white70
                                : const Color(0xFF2C3E35),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.title,
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: hasImage
                                ? Colors.white
                                : const Color(0xFF1E2B25),
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),

                    // Pill Button with forward chevron
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: _hovered ? 0.16 : 0.08,
                            ),
                            blurRadius: _hovered ? 12 : 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.ctaText,
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
