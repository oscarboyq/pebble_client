import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/services/product_service.dart';
import 'package:pebble_type/core/theme/app_text_styles.dart';
import 'package:pebble_type/core/widgets/pebble_image.dart';
import 'package:pebble_type/feature/products/models/filter_model.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/providers/product_providers.dart';
import 'package:pebble_type/feature/products/widgets/filter_sheet.dart';
import 'package:pebble_type/feature/products/widgets/product_card.dart';
import 'package:pebble_type/feature/products/widgets/product_color_swatch.dart';

/// Collection filters are local to this route, independent of the shop search.
class CollectionListPage extends ConsumerStatefulWidget {
  final String slug;
  final String? title;

  const CollectionListPage({super.key, required this.slug, this.title});

  @override
  ConsumerState<CollectionListPage> createState() => _CollectionListPageState();
}

class _CollectionListPageState extends ConsumerState<CollectionListPage> {
  ProductFilter _filter = const ProductFilter();
  bool _showSidebar = true;
  bool _showAllColors = false;
  bool _showAllSizes = false;
  bool _showAllCategories = false;
  int _requestedPages = 1;
  String? _pageQueryKey;
  RangeValues? _priceDraft;
  bool _pageAdvancePending = false;
  final Set<String> _prefetchedImages = {};

  void _prefetchCardImages(List<ProductModel> products, String queryKey) {
    final urls = products
        .take(6)
        .map((product) => product.primaryCardImageUrl)
        .whereType<String>()
        .where((url) => url.isNotEmpty && _prefetchedImages.add(url))
        .toList();
    if (urls.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _pageQueryKey != queryKey) return;
      for (final url in urls) {
        unawaited(
          precacheImage(NetworkImage(url), context, onError: (_, _) {}),
        );
      }
    });
  }

  int get _facetCount => [
    _filter.minPrice != null || _filter.maxPrice != null,
    _filter.color != null,
    _filter.size != null,
    _filter.inStock != null,
    _filter.categorySlug != null,
  ].where((active) => active).length;

  String get _filtersKey => Uri(
    queryParameters: {
      if (_filter.minPrice != null) 'min': _filter.minPrice.toString(),
      if (_filter.maxPrice != null) 'max': _filter.maxPrice.toString(),
      if (_filter.color != null) 'color': _filter.color!,
      if (_filter.size != null) 'size': _filter.size!,
      if (_filter.inStock != null) 'stock': _filter.inStock.toString(),
      if (_filter.categorySlug != null) 'category': _filter.categorySlug!,
      'sort': _filter.sort.name,
    },
  ).query;

  Future<void> _openFilters() async {
    final facets = ref.read(collectionFacetsProvider(widget.slug)).value;
    final result = await showModalBottomSheet<ProductFilter>(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 560),
      builder: (_) => FilterSheet(
        initial: _filter,
        sizes: facets?.sizes,
        colors: facets?.colors,
        categories: widget.slug == 'all'
            ? ref
                  .read(categoriesProvider)
                  .value
                  ?.where((category) => category.slug != 'clothing')
                  .toList()
            : null,
        maxPrice: facets?.maxPrice,
      ),
    );
    if (result != null && mounted) setState(() => _filter = result);
  }

  @override
  Widget build(BuildContext context) {
    final query = (slug: widget.slug, filters: _filtersKey);
    final queryKey = '${query.slug}|${query.filters}';
    if (_pageQueryKey != queryKey) {
      _pageQueryKey = queryKey;
      _requestedPages = 1;
      _prefetchedImages.clear();
    }
    final firstPageKey = (slug: query.slug, filters: query.filters, page: 1);
    final firstPage = ref.watch(collectionPageProvider(firstPageKey));
    final morePages = [
      for (var page = 2; page <= _requestedPages; page++)
        ref.watch(
          collectionPageProvider((
            slug: query.slug,
            filters: query.filters,
            page: page,
          )),
        ),
    ];
    final products = [
      if (firstPage.value != null) ...firstPage.value!.products,
      for (final page in morePages)
        if (page.value != null) ...page.value!.products,
    ];
    final total = firstPage.value?.count ?? 0;
    final pageError = morePages.any((page) => page.hasError);
    final loadingMore = morePages.any((page) => page.isLoading);
    // Keep one API page ready ahead of the visible grid. It is displayed only
    // when the shopper approaches the end of the current page.
    final nextPage = _requestedPages + 1;
    final canPrefetch =
        firstPage.hasValue &&
        !loadingMore &&
        !pageError &&
        nextPage <= (total / (firstPage.value?.pageSize ?? 12)).ceil();
    final prefetchedPage = canPrefetch
        ? ref.watch(
            collectionPageProvider((
              slug: query.slug,
              filters: query.filters,
              page: nextPage,
            )),
          )
        : null;
    if (prefetchedPage?.value != null) {
      _prefetchCardImages(prefetchedPage!.value!.products, queryKey);
    }
    final facets = ref.watch(collectionFacetsProvider(widget.slug)).value;
    final categories = widget.slug == 'all'
        ? ref.watch(categoriesProvider).value ?? const <CategoryModel>[]
        : const <CategoryModel>[];
    final heading = widget.title?.isNotEmpty == true
        ? widget.title!
        : widget.slug == 'all'
        ? 'Shop All'
        : widget.slug.replaceAll('-', ' ');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1296),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.axis == Axis.vertical &&
                  notification.metrics.extentAfter < 800 &&
                  firstPage.hasValue &&
                  !loadingMore &&
                  !pageError &&
                  products.length < total &&
                  !_pageAdvancePending) {
                _pageAdvancePending = true;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _pageAdvancePending = false;
                  if (mounted &&
                      _pageQueryKey == queryKey &&
                      _requestedPages <
                          (total / (firstPage.value?.pageSize ?? 12)).ceil()) {
                    setState(() => _requestedPages++);
                  }
                });
              }
              return false;
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildIntro(heading, categories)),
                const SliverToBoxAdapter(
                  child: Divider(height: 1, color: AppColors.border),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      MediaQuery.sizeOf(context).width >= 900 ? 0 : 16,
                      MediaQuery.sizeOf(context).width >= 900 ? 36 : 16,
                      MediaQuery.sizeOf(context).width >= 900 ? 0 : 16,
                      18,
                    ),
                    child: LayoutBuilder(
                      builder: (context, toolbar) => Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppDimensions.spacingSm,
                        runSpacing: AppDimensions.spacingSm,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton.icon(
                                onPressed:
                                    MediaQuery.sizeOf(context).width >= 900
                                    ? () => setState(
                                        () => _showSidebar = !_showSidebar,
                                      )
                                    : _openFilters,
                                icon: const Icon(Icons.tune, size: 18),
                                label: Text(
                                  _facetCount == 0
                                      ? 'Filter'
                                      : 'Filter ($_facetCount)',
                                ),
                              ),
                              if (_filter.hasActiveFilters) ...[
                                const SizedBox(width: AppDimensions.spacingSm),
                                TextButton(
                                  onPressed: () => setState(
                                    () => _filter = const ProductFilter(),
                                  ),
                                  child: const Text('Clear'),
                                ),
                              ],
                              if (firstPage.value != null &&
                                  toolbar.maxWidth >= 540)
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    '$total products',
                                    style: AppTextStyles.bodyMd,
                                  ),
                                ),
                            ],
                          ),
                          PopupMenuButton<SortOption>(
                            tooltip: 'Sort products',
                            onSelected: (sort) => setState(
                              () => _filter = _filter.copyWith(sort: sort),
                            ),
                            itemBuilder: (_) => SortOption.values
                                .map(
                                  (sort) => PopupMenuItem(
                                    value: sort,
                                    child: Text(sort.label),
                                  ),
                                )
                                .toList(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (toolbar.maxWidth >= 380)
                                    Text(_filter.sort.label)
                                  else
                                    const Text('Sort'),
                                  const Icon(Icons.expand_more),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                firstPage.when<Widget>(
                  loading: () => const SliverToBoxAdapter(
                    child: SizedBox(
                      height: 320,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  error: (_, _) => SliverToBoxAdapter(
                    child: SizedBox(
                      height: 320,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Could not load this collection.'),
                            TextButton(
                              onPressed: () => ref.invalidate(
                                collectionPageProvider(firstPageKey),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  data: (_) {
                    if (products.isEmpty) {
                      return SliverToBoxAdapter(
                        child: SizedBox(
                          height: 320,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('No products match these filters.'),
                                TextButton(
                                  onPressed: () => setState(
                                    () => _filter = const ProductFilter(),
                                  ),
                                  child: const Text('Clear filters'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final desktop = constraints.crossAxisExtent >= 900;
                        final showSidebar = desktop && _showSidebar;
                        final width =
                            constraints.crossAxisExtent -
                            (showSidebar ? 280 : 0);
                        final cols = width >= AppDimensions.desktopBreakpoint
                            ? 3
                            : width >= 720
                            ? 3
                            : 2;
                        final gap = width < AppDimensions.compactBreakpoint
                            ? 12.0
                            : 24.0;
                        final tileWidth =
                            (width - 32 - gap * (cols - 1)) / cols;
                        final grid = SliverPadding(
                          padding: const EdgeInsets.all(
                            AppDimensions.spacingMd,
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  crossAxisSpacing: gap,
                                  mainAxisSpacing: gap,
                                  mainAxisExtent:
                                      tileWidth /
                                      AppDimensions.productCardAspectRatio,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => ProductCard(
                                product: products[index],
                                onTap: () => context.push(
                                  '/products/${products[index].slug}',
                                ),
                              ),
                              childCount: products.length,
                            ),
                          ),
                        );
                        if (!showSidebar) return grid;
                        return SliverCrossAxisGroup(
                          slivers: [
                            SliverConstrainedCrossAxis(
                              maxExtent: 280,
                              sliver: SliverToBoxAdapter(
                                child: _buildSidebar(facets, categories),
                              ),
                            ),
                            SliverCrossAxisExpanded(flex: 1, sliver: grid),
                          ],
                        );
                      },
                    );
                  },
                ),
                if (firstPage.hasValue &&
                    (products.length < total || pageError))
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: pageError
                            ? TextButton(
                                onPressed: () => ref.invalidate(
                                  collectionPageProvider((
                                    slug: query.slug,
                                    filters: query.filters,
                                    page: _requestedPages,
                                  )),
                                ),
                                child: const Text('Retry loading products'),
                              )
                            : loadingMore
                            ? const CircularProgressIndicator(
                                color: AppColors.primary,
                              )
                            : TextButton(
                                onPressed: () =>
                                    setState(() => _requestedPages++),
                                child: const Text('Load more products'),
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

  Widget _buildSidebar(ProductFacets? facets, List<CategoryModel> categories) {
    final maxPrice = (facets?.maxPrice ?? 100).clamp(1.0, 100000.0);
    final choices = [
      for (final category in categories)
        if (category.slug != 'clothing') category,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sidebarSection('Availability', [
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('In stock'),
              value: _filter.inStock == true,
              onChanged: (checked) => setState(() {
                _filter = checked == true
                    ? _filter.copyWith(inStock: true)
                    : _filter.copyWith(clearInStock: true);
              }),
            ),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Out of stock'),
              value: _filter.inStock == false,
              onChanged: (checked) => setState(() {
                _filter = checked == true
                    ? _filter.copyWith(inStock: false)
                    : _filter.copyWith(clearInStock: true);
              }),
            ),
          ]),
          _sidebarSection('Price', [_priceFilter(maxPrice)]),
          if (facets != null && facets.colors.isNotEmpty)
            _sidebarSection('Color', [
              for (final color in _visibleChoices(
                facets.colors,
                _showAllColors,
                _filter.color,
              ))
                _colorFacetRow(color, facets.colorCounts[color]),
              if (facets.colors.length > 10)
                _moreChoicesButton(
                  expanded: _showAllColors,
                  hiddenCount: facets.colors.length - 10,
                  onPressed: () =>
                      setState(() => _showAllColors = !_showAllColors),
                ),
            ]),
          if (facets != null && facets.sizes.isNotEmpty)
            _sidebarSection('Size', [
              for (final size in _visibleChoices(
                facets.sizes,
                _showAllSizes,
                _filter.size,
              ))
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(size),
                  secondary: facets.sizeCounts[size] == null
                      ? null
                      : Text('${facets.sizeCounts[size]}'),
                  value: _filter.size == size,
                  onChanged: (checked) => setState(() {
                    _filter = checked == true
                        ? _filter.copyWith(size: size)
                        : _filter.copyWith(clearSize: true);
                  }),
                ),
              if (facets.sizes.length > 10)
                _moreChoicesButton(
                  expanded: _showAllSizes,
                  hiddenCount: facets.sizes.length - 10,
                  onPressed: () =>
                      setState(() => _showAllSizes = !_showAllSizes),
                ),
            ]),
          if (choices.isNotEmpty)
            _sidebarSection('Categories', [
              for (final category in _visibleChoices(
                choices,
                _showAllCategories,
                choices
                    .where((category) => category.slug == _filter.categorySlug)
                    .firstOrNull,
              ))
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(category.name),
                  secondary: facets?.categoryCounts[category.slug] == null
                      ? null
                      : Text('${facets!.categoryCounts[category.slug]}'),
                  value: _filter.categorySlug == category.slug,
                  onChanged: (checked) => setState(() {
                    _filter = checked == true
                        ? _filter.copyWith(categorySlug: category.slug)
                        : _filter.copyWith(clearCategory: true);
                  }),
                ),
              if (choices.length > 10)
                _moreChoicesButton(
                  expanded: _showAllCategories,
                  hiddenCount: choices.length - 10,
                  onPressed: () =>
                      setState(() => _showAllCategories = !_showAllCategories),
                ),
            ]),
        ],
      ),
    );
  }

  Widget _colorFacetRow(String color, int? count) {
    final selected = _filter.color == color;
    return Semantics(
      button: true,
      selected: selected,
      label: count == null ? '$color color' : '$color color, $count products',
      child: InkWell(
        onTap: () => setState(() {
          _filter = selected
              ? _filter.copyWith(clearColor: true)
              : _filter.copyWith(color: color);
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              ExcludeSemantics(
                child: ProductColorSwatch(name: color, selected: selected),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  color,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (count != null) Text('$count', style: AppTextStyles.bodyMd),
            ],
          ),
        ),
      ),
    );
  }

  List<T> _visibleChoices<T>(List<T> items, bool expanded, T? selected) {
    if (expanded || items.length <= 10) return items;
    final visible = items.take(10).toList();
    if (selected != null &&
        !visible.contains(selected) &&
        items.contains(selected)) {
      visible.add(selected);
    }
    return visible;
  }

  Widget _moreChoicesButton({
    required bool expanded,
    required int hiddenCount,
    required VoidCallback onPressed,
  }) => TextButton.icon(
    onPressed: onPressed,
    icon: Icon(expanded ? Icons.remove : Icons.add, size: 16),
    label: Text(expanded ? 'Show less' : 'Show more ($hiddenCount)'),
  );

  Widget _sidebarSection(String title, List<Widget> children) => Column(
    children: [
      ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        children: children,
      ),
      const Divider(height: 1, color: AppColors.border),
    ],
  );

  Widget _priceFilter(double maxPrice) => StatefulBuilder(
    builder: (context, setPriceState) {
      final minimum = (_priceDraft?.start ?? _filter.minPrice ?? 0).clamp(
        0.0,
        maxPrice,
      );
      final maximum = (_priceDraft?.end ?? _filter.maxPrice ?? maxPrice).clamp(
        minimum,
        maxPrice,
      );
      return Column(
        children: [
          RangeSlider(
            values: RangeValues(minimum, maximum),
            min: 0,
            max: maxPrice,
            labels: RangeLabels(
              '\$${minimum.toStringAsFixed(0)}',
              '\$${maximum.toStringAsFixed(0)}',
            ),
            onChanged: (values) => setPriceState(() => _priceDraft = values),
            onChangeEnd: (values) => setState(() {
              _priceDraft = null;
              _filter = _filter.copyWith(
                minPrice: values.start,
                maxPrice: values.end,
                clearMinPrice: values.start == 0,
                clearMaxPrice: values.end == maxPrice,
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '\$${minimum.toStringAsFixed(0)} – \$${maximum.toStringAsFixed(0)}',
              style: AppTextStyles.bodyMd,
            ),
          ),
        ],
      );
    },
  );

  Widget _buildIntro(String heading, List<CategoryModel> categories) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    const preferred = [
      'sweaters',
      'pants',
      'coats-jackets',
      'accessories',
      'shirts',
      't-shirts',
    ];
    final featured = [
      for (final slug in preferred)
        ...categories.where((category) => category.slug == slug),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isWide ? 0 : 20,
        22,
        isWide ? 0 : 20,
        isWide && widget.slug == 'all' ? 52 : 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('Home'),
              ),
              const Text(
                ' / ',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(heading, style: const TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            heading,
            style: TextStyle(
              fontSize: isWide ? 36 : 30,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (widget.slug == 'all' && featured.isNotEmpty) ...[
            SizedBox(height: isWide ? 36 : 22),
            SizedBox(
              height: isWide ? 360 : 245,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: featured.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = featured[index];
                  return SizedBox(
                    width: isWide ? 300 : 190,
                    child: InkWell(
                      onTap: () => context.go('/collections/${category.slug}'),
                      borderRadius: BorderRadius.circular(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: SizedBox.expand(
                                child: category.image == null
                                    ? const ColoredBox(
                                        color: AppColors.mediaBackground,
                                      )
                                    : PebbleImage.card(
                                        imageUrl: category.image!,
                                        fit: BoxFit.cover,
                                        errorWidget: const ColoredBox(
                                          color: AppColors.mediaBackground,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            category.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${category.productCount} products',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
