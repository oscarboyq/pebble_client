import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/providers/header_provider.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/services/product_service.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/core/widgets/footer.dart';
import 'package:pebble_type/core/widgets/pebble_image.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/feature/products/models/filter_model.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/providers/product_providers.dart';
import 'package:pebble_type/feature/products/widgets/filter_sheet.dart';
import 'package:pebble_type/feature/products/widgets/filter_sidebar.dart';
import 'package:pebble_type/feature/products/widgets/product_card.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  String? _lastRouteQuery;
  final ScrollController _scrollController = ScrollController();

  // Pebble facet toolbar & grid switcher state (defaults to 4 columns like reference Shopify Pebble)
  bool _showDesktopFilters = true;
  int _desktopGridColumns = 4;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  SortOption _sortFromQuery(String? value) {
    switch (value) {
      case 'best_selling':
        return SortOption.bestSelling;
      case 'price_asc':
        return SortOption.priceAsc;
      case 'price_desc':
        return SortOption.priceDesc;
      case 'top_rated':
        return SortOption.topRated;
      default:
        return SortOption.newest;
    }
  }

  void _syncRouteQuery(BuildContext context) {
    final routerState = GoRouterState.of(context);
    final uri = routerState.uri;
    final extra = routerState.extra is Map ? (routerState.extra as Map) : null;
    final extraCategory = extra?['category'] as String?;
    final routeQuery = '${uri.query}|${extraCategory ?? ''}';
    if (_lastRouteQuery == routeQuery) return;
    _lastRouteQuery = routeQuery;

    final params = uri.queryParameters;
    final category =
        (params['category'] != null && params['category']!.isNotEmpty)
        ? params['category']
        : extraCategory;
    final search = params['search'] ?? '';
    final gender = params['gender'];
    final productType = params['product_type'];
    final onSale = params['sale'] == 'true' || params['sale'] == '1';
    final sort = _sortFromQuery(params['sort']);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_scrollController.hasClients &&
          _scrollController.position.hasContentDimensions) {
        _scrollController.jumpTo(0.0);
      }

      ref.read(searchQueryProvider.notifier).state = search;
      ref.read(selectedCategoryProvider.notifier).state =
          category != null && category.isNotEmpty ? category : null;
      ref.read(productFilterProvider.notifier).state = ProductFilter(
        categorySlug: category != null && category.isNotEmpty ? category : null,
        productType: productType != null && productType.isNotEmpty
            ? productType
            : null,
        gender: gender != null && gender.isNotEmpty ? gender : null,
        sale: onSale ? true : null,
        sort: sort,
      );
    });
  }

  Future<void> _openFilterSheet(BuildContext context) async {
    final current = ref.read(productFilterProvider);
    ProductFacets facets;
    List<CategoryModel> categories;
    try {
      facets = await ref.read(shopAllFacetsProvider.future);
      categories = await ref.read(categoriesProvider.future);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Filters could not be loaded. Try again.'),
          ),
        );
      }
      return;
    }
    if (!context.mounted) return;
    final result = await showModalBottomSheet<ProductFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterSheet(
        initial: current,
        sizes: facets.sizes,
        colors: facets.colors,
        productTypes: facets.productTypes,
        categories: categories,
        maxPrice: facets.maxPrice,
      ),
    );
    if (result != null) {
      ref.read(productFilterProvider.notifier).state = result;
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncRouteQuery(context);

    final isWide = context.isWide;
    return isWide ? _buildDesktop(context) : _buildMobile(context);
  }

  // ── Collection Information Helper ──────────────────────────────────
  ({String title, String description, String bannerImage}) _getCollectionInfo(
    String? categorySlug,
    List<CategoryModel>? categories,
  ) {
    if (categorySlug == null || categorySlug.isEmpty) {
      return (
        title: 'All Products',
        description: '',
        bannerImage:
            'http://localhost:8000/media/category_banners/sets_banner.webp',
      );
    }

    final cat = categories?.where((c) => c.slug == categorySlug).firstOrNull;
    final name = cat?.name ?? _formatSlug(categorySlug);

    String desc = '';
    String banner;

    if (cat?.bannerImage != null && cat!.bannerImage!.isNotEmpty) {
      banner = cat.bannerImage!;
    } else {
      switch (categorySlug.toLowerCase()) {
        case 'accessories':
          banner =
              'http://localhost:8000/media/category_banners/accessories_banner.webp';
          break;
        case 'clothing':
        case 't-shirts':
        case 'sweaters':
        case 'outerwear':
          banner =
              'http://localhost:8000/media/category_banners/clothing_banner.webp';
          break;
        case 'sets':
        default:
          banner =
              'http://localhost:8000/media/category_banners/sets_banner.webp';
          break;
      }
    }

    return (title: name, description: desc, bannerImage: banner);
  }

  String _formatSlug(String slug) {
    return slug
        .split('-')
        .map(
          (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
        )
        .join(' ');
  }

  // ── Authentic Shopify Pebble Collection Hero Banner ─────────────────
  Widget _buildCollectionHeroBanner({
    required BuildContext context,
    required String title,
    required String description,
    required String bannerUrl,
    required bool isWide,
  }) {
    final bannerHeight = isWide ? 440.0 : 280.0;
    return SizedBox(
      height: bannerHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-bleed lifestyle background photo
          PebbleImage(
            imageUrl: bannerUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: bannerHeight,
            placeholder: Container(color: const Color(0xFF2C2A29)),
            errorWidget: Container(color: const Color(0xFF2C2A29)),
          ),

          // 2. Parallax-feel dark contrast gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.35),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),

          // 3. Bottom-Left aligned breadcrumbs, large display title & subtitle
          Positioned(
            left: isWide ? 44.0 : 20.0,
            right: isWide ? 44.0 : 20.0,
            bottom: isWide ? 36.0 : 24.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Breadcrumbs (Reversed white links)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.dashboard),
                      child: Text(
                        'Home',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '/',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.50),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            null;
                        ref
                            .read(productFilterProvider.notifier)
                            .update((f) => f.copyWith(clearCategory: true));
                        context.go('/products');
                      },
                      child: Text(
                        'Collections',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: title == 'All Products'
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    if (title != 'All Products') ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '/',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.50),
                          ),
                        ),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Giant Display Title (Bricolage Grotesque)
                Text(
                  title,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: isWide ? 48 : 30,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.8,
                    height: 1.1,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: isWide ? 14 : 12.5,
                        color: Colors.white.withValues(alpha: 0.90),
                        height: 1.45,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Facet Toolbar (Pebble Reference) ────────────────────────────────
  Widget _buildFacetToolbar({
    required BuildContext context,
    required int productCount,
    required SortOption currentSort,
    required int activeFilterCount,
    required bool isWide,
  }) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Left: Filters Toggle Pill + Product Count ─────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filters pill button
              InkWell(
                onTap: () {
                  if (isWide) {
                    setState(() {
                      _showDesktopFilters = !_showDesktopFilters;
                    });
                  } else {
                    _openFilterSheet(context);
                  }
                },
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _showDesktopFilters && isWide
                          ? AppColors.textPrimary
                          : AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.filter_alt_outlined,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isWide
                            ? (_showDesktopFilters ? 'Hide filters' : 'Filters')
                            : 'Filter & sort',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (activeFilterCount > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$activeFilterCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Live product count
              Text(
                '$productCount ${productCount == 1 ? 'product' : 'products'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          // ── Right (Desktop only): Sort By + View As Column Switcher ──
          if (isWide)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sort by label & dropdown
                const Text(
                  'Sort by',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                _SortDropdown(
                  current: currentSort,
                  onSelected: (opt) {
                    ref
                        .read(productFilterProvider.notifier)
                        .update((f) => f.copyWith(sort: opt));
                  },
                ),
                const SizedBox(width: 24),

                // View as label & column switcher
                const Text(
                  'View as',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                _ColumnSwitcher(
                  currentColumns: _desktopGridColumns,
                  onSelect: (cols) {
                    setState(() {
                      _desktopGridColumns = cols;
                    });
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ── Desktop layout ────────────────────────────────────────────────
  Widget _buildDesktop(BuildContext context) {
    final productAsync = ref.watch(productListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final filter = ref.watch(productFilterProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filterCount = filter.activeFilterCount;
    final activeSlug = filter.categorySlug ?? selectedCategory;
    final collectionInfo = _getCollectionInfo(
      activeSlug,
      categoriesAsync.value,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification.metrics.axis == Axis.vertical) {
            final isScrolled = notification.metrics.pixels > 35;
            if (ref.read(isHeaderScrolledProvider) != isScrolled) {
              ref.read(isHeaderScrolledProvider.notifier).state = isScrolled;
            }
          }
          return false;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Collection Hero / Header ────────────────────────────
              _buildCollectionHeroBanner(
                context: context,
                title: collectionInfo.title,
                description: collectionInfo.description,
                bannerUrl: collectionInfo.bannerImage,
                isWide: true,
              ),

              // ── Facet Toolbar ────────────────────────────────────────
              _buildFacetToolbar(
                context: context,
                productCount: productAsync.value?.length ?? 0,
                currentSort: filter.sort,
                activeFilterCount: filterCount,
                isWide: true,
              ),
              const Divider(height: 1, color: AppColors.border),

              // ── Main row: collapsible sidebar + product content ──────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 24,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Collapsible Left sidebar
                    if (_showDesktopFilters) ...[
                      SizedBox(
                        width: 270,
                        child: categoriesAsync.when(
                          loading: () => const SizedBox(width: 270),
                          error: (_, _) => const SizedBox(width: 270),
                          data: (cats) => FilterSidebar(categories: cats),
                        ),
                      ),
                      const SizedBox(width: 36),
                    ],

                    // Product area
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Active filter chips (desktop)
                          if (filter.hasActiveFilters)
                            _ActiveFilterChips(
                              filter: filter,
                              onClear: () {
                                ref.read(productFilterProvider.notifier).state =
                                    const ProductFilter();
                                ref
                                        .read(selectedCategoryProvider.notifier)
                                        .state =
                                    null;
                              },
                              onRemove: (updated) {
                                ref.read(productFilterProvider.notifier).state =
                                    updated;
                                if (updated.categorySlug == null) {
                                  ref
                                          .read(
                                            selectedCategoryProvider.notifier,
                                          )
                                          .state =
                                      null;
                                }
                              },
                            ),

                          // Product grid
                          productAsync.when(
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(60.0),
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            error: (err, _) => Center(
                              child: Padding(
                                padding: const EdgeInsets.all(60.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      err.toString(),
                                      style: const TextStyle(
                                        color: AppColors.error,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: () => ref
                                          .read(productListProvider.notifier)
                                          .refresh(),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            data: (products) {
                              if (products.isEmpty) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(60.0),
                                    child: Text('No products found.'),
                                  ),
                                );
                              }
                              final cols = _desktopGridColumns;
                              final childAspect = cols == 4
                                  ? 0.70
                                  : (cols == 3 ? 0.72 : 0.68);
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: cols,
                                      crossAxisSpacing: 24,
                                      mainAxisSpacing: 32,
                                      childAspectRatio: childAspect,
                                    ),
                                itemCount: products.length,
                                itemBuilder: (_, i) => ProductCard(
                                  product: products[i],
                                  onTap: () => context.push(
                                    '/products/${products[i].slug}',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── About Pebble Section & Footer ──
              _buildAboutPebbleSection(true),
              const AppFooter(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Mobile layout ──────────────────────────────────────────────────
  Widget _buildMobile(BuildContext context) {
    final productAsync = ref.watch(productListProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final filter = ref.watch(productFilterProvider);
    final filterCount = filter.activeFilterCount;
    final activeSlug = filter.categorySlug ?? selectedCategory;
    final collectionInfo = _getCollectionInfo(
      activeSlug,
      categoriesAsync.value,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          collectionInfo.title,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.push(AppRoutes.orders),
          ),
        ],
      ),
      body: Column(
        children: [
          // Collection Subtitle / Description (Mobile)
          _buildCollectionHeroBanner(
            context: context,
            title: collectionInfo.title,
            description: collectionInfo.description,
            bannerUrl: collectionInfo.bannerImage,
            isWide: false,
          ),
          const Divider(height: 1, color: AppColors.border),

          // Facet Toolbar (Mobile)
          _buildFacetToolbar(
            context: context,
            productCount: productAsync.value?.length ?? 0,
            currentSort: filter.sort,
            activeFilterCount: filterCount,
            isWide: false,
          ),
          const Divider(height: 1, color: AppColors.border),

          // Active filter chips
          if (filter.hasActiveFilters)
            _ActiveFilterChips(
              filter: filter,
              onClear: () {
                ref.read(productFilterProvider.notifier).state =
                    const ProductFilter();
                ref.read(selectedCategoryProvider.notifier).state = null;
              },
              onRemove: (updated) {
                ref.read(productFilterProvider.notifier).state = updated;
                if (updated.categorySlug == null) {
                  ref.read(selectedCategoryProvider.notifier).state = null;
                }
              },
            ),

          // Product grid
          Expanded(
            child: productAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      err.toString(),
                      style: const TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    TextButton(
                      onPressed: () =>
                          ref.read(productListProvider.notifier).refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () =>
                      ref.read(productListProvider.notifier).refresh(),
                  child: ListView(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppDimensions.spacingMd),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.62,
                            ),
                        itemCount: products.length,
                        itemBuilder: (_, index) => ProductCard(
                          product: products[index],
                          onTap: () =>
                              context.push('/products/${products[index].slug}'),
                        ),
                      ),
                      _buildAboutPebbleSection(false),
                      const AppFooter(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Authentic "About Pebble" Editorial Storytelling Section ───────────
  Widget _buildAboutPebbleSection(bool isWide) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF9F9F8),
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 80 : 20,
        vertical: isWide ? 64 : 44,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 840),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'ABOUT PEBBLE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Everyday Essentials, Made to Last',
                textAlign: TextAlign.center,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: isWide ? 34 : 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  'Our store is built on a simple belief: great style should feel effortless. We design each piece with a balance of comfort, quality, and modern appeal, creating clothing that fits easily into everyday life. From soft organic fabrics to thoughtful fits, every detail is considered with care.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isWide ? 15 : 13.5,
                    height: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              Wrap(
                spacing: 24,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: [
                  _buildValuePill(
                    Icons.favorite_border_rounded,
                    'Everyday Comfort',
                  ),
                  _buildValuePill(Icons.style_outlined, 'Curated Outfits'),
                  _buildValuePill(Icons.grid_view_outlined, 'Shop Collections'),
                  _buildValuePill(Icons.auto_awesome_outlined, 'New Arrivals'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValuePill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE5E5E2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textPrimary),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pebble Facet Toolbar Helpers ─────────────────────────────────────
class _SortDropdown extends StatelessWidget {
  final SortOption current;
  final ValueChanged<SortOption> onSelected;

  const _SortDropdown({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOption>(
      initialValue: current,
      onSelected: onSelected,
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      itemBuilder: (context) => SortOption.values.map((opt) {
        final isSelected = opt == current;
        return PopupMenuItem<SortOption>(
          value: opt,
          height: 38,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  opt.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check, size: 14, color: AppColors.primary),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              current.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ColumnSwitcher extends StatelessWidget {
  final int currentColumns;
  final ValueChanged<int> onSelect;

  const _ColumnSwitcher({required this.currentColumns, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 3-columns icon button
        _ColumnIconButton(
          label: '3 columns',
          isSelected: currentColumns == 3,
          onTap: () => onSelect(3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _colBar(currentColumns == 3),
              const SizedBox(width: 2),
              _colBar(currentColumns == 3),
              const SizedBox(width: 2),
              _colBar(currentColumns == 3),
            ],
          ),
        ),
        const SizedBox(width: 6),
        // 4-columns icon button
        _ColumnIconButton(
          label: '4 columns',
          isSelected: currentColumns == 4,
          onTap: () => onSelect(4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _colBar(currentColumns == 4),
              const SizedBox(width: 2),
              _colBar(currentColumns == 4),
              const SizedBox(width: 2),
              _colBar(currentColumns == 4),
              const SizedBox(width: 2),
              _colBar(currentColumns == 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _colBar(bool active) => Container(
    width: 3.5,
    height: 12,
    decoration: BoxDecoration(
      color: active
          ? AppColors.textPrimary
          : AppColors.textSecondary.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(1),
    ),
  );
}

class _ColumnIconButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  const _ColumnIconButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.textPrimary : AppColors.border,
              width: 1,
            ),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

class _ActiveFilterChips extends StatelessWidget {
  final ProductFilter filter;
  final VoidCallback onClear;
  final void Function(ProductFilter updated) onRemove;

  const _ActiveFilterChips({
    required this.filter,
    required this.onClear,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    if (filter.sort != SortOption.newest) {
      chips.add(
        _Chip(
          label: filter.sort.label,
          onRemove: () => onRemove(filter.copyWith(sort: SortOption.newest)),
        ),
      );
    }
    if (filter.minPrice != null || filter.maxPrice != null) {
      final min = filter.minPrice?.toInt() ?? 0;
      final max = filter.maxPrice?.toInt();
      final label = max != null ? '\$$min – \$$max' : '\$$min+';
      chips.add(
        _Chip(
          label: label,
          onRemove: () => onRemove(
            filter.copyWith(clearMinPrice: true, clearMaxPrice: true),
          ),
        ),
      );
    }
    if (filter.color != null) {
      chips.add(
        _Chip(
          label: filter.color!,
          onRemove: () => onRemove(filter.copyWith(clearColor: true)),
        ),
      );
    }
    if (filter.productType != null) {
      chips.add(
        _Chip(
          label: filter.productType!,
          onRemove: () => onRemove(filter.copyWith(clearProductType: true)),
        ),
      );
    }
    if (filter.size != null) {
      chips.add(
        _Chip(
          label: 'Size: ${filter.size}',
          onRemove: () => onRemove(filter.copyWith(clearSize: true)),
        ),
      );
    }
    if (filter.inStock != null) {
      chips.add(
        _Chip(
          label: filter.inStock! ? 'In stock' : 'Out of stock',
          onRemove: () => onRemove(filter.copyWith(clearInStock: true)),
        ),
      );
    }

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: chips
                    .expand((c) => [c, const SizedBox(width: 6)])
                    .toList(),
              ),
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                'Clear all',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _Chip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
