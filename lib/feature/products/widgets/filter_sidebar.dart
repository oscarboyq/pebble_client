import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/feature/products/models/filter_model.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/providers/product_providers.dart';
import 'package:pebble_type/feature/products/widgets/product_color_swatch.dart';

/// Persistent desktop filter sidebar with expandable accordions
/// matching Shopify Pebble reference theme.
class FilterSidebar extends ConsumerStatefulWidget {
  final List<CategoryModel> categories;

  const FilterSidebar({super.key, required this.categories});

  @override
  ConsumerState<FilterSidebar> createState() => _FilterSidebarState();
}

class _FilterSidebarState extends ConsumerState<FilterSidebar> {
  static const double _maxPrice = 500;

  late RangeValues _priceRange;
  String? _size;
  String? _color;
  String? _productType;
  bool? _inStock;
  bool _showAllColors = false;
  bool _showAllSizes = false;
  bool _showAllCategories = false;
  bool _showAllTypes = false;

  // Accordion open/closed state
  bool _isAvailabilityOpen = true;
  bool _isPriceOpen = true;
  bool _isColorOpen = true;
  bool _isSizeOpen = true;
  bool _isCategoriesOpen = true;
  bool _isProductTypesOpen = true;

  @override
  void initState() {
    super.initState();
    final f = ref.read(productFilterProvider);
    _priceRange = RangeValues(f.minPrice ?? 0, f.maxPrice ?? _maxPrice);
    _size = f.size;
    _color = f.color;
    _productType = f.productType;
    _inStock = f.inStock;
  }

  void _apply() {
    final maxPrice =
        ref.read(shopAllFacetsProvider).value?.maxPrice ?? _maxPrice;
    ref
        .read(productFilterProvider.notifier)
        .update(
          (f) => f.copyWith(
            minPrice: _priceRange.start > 0 ? _priceRange.start : null,
            clearMinPrice: _priceRange.start == 0,
            maxPrice: _priceRange.end < maxPrice ? _priceRange.end : null,
            clearMaxPrice: _priceRange.end >= maxPrice,
            color: _color,
            clearColor: _color == null,
            productType: _productType,
            clearProductType: _productType == null,
            size: _size,
            clearSize: _size == null,
            inStock: _inStock,
            clearInStock: _inStock == null,
          ),
        );
  }

  void _reset() {
    setState(() {
      _priceRange = const RangeValues(0, _maxPrice);
      _size = null;
      _color = null;
      _productType = null;
      _inStock = null;
    });
    ref.read(productFilterProvider.notifier).state = ProductFilter(
      categorySlug: ref.read(productFilterProvider).categorySlug,
      sort: ref.read(productFilterProvider).sort,
    );
    ref.read(selectedCategoryProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProductFilter>(productFilterProvider, (previous, next) {
      if (!mounted) return;
      setState(() {
        _size = next.size;
        _color = next.color;
        _productType = next.productType;
        _inStock = next.inStock;
        _priceRange = RangeValues(
          next.minPrice ?? 0,
          next.maxPrice ?? _maxPrice,
        );
      });
    });
    final filter = ref.watch(productFilterProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final facets = ref.watch(shopAllFacetsProvider).value;
    final maxPrice = (facets?.maxPrice ?? _maxPrice).clamp(1.0, 100000.0);
    final displayedRange = RangeValues(
      _priceRange.start.clamp(0.0, maxPrice),
      _priceRange.end.clamp(0.0, maxPrice),
    );

    return Container(
      width: 280,
      color: AppColors.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sidebar Header: "Filters" + "Clear all" ──────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (filter.hasActiveFilters)
                  GestureDetector(
                    onTap: _reset,
                    child: const Text(
                      'Clear all',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.border, height: 1, thickness: 1),

            // ── Accordion 1: Availability ────────────────────────
            _AccordionSection(
              title: 'Availability',
              isOpen: _isAvailabilityOpen,
              hasActiveValue: _inStock != null,
              onToggle: () =>
                  setState(() => _isAvailabilityOpen = !_isAvailabilityOpen),
              child: Column(
                children: [
                  _CheckboxRow(
                    label: 'In stock',
                    count: facets?.availabilityCounts['in_stock'],
                    isChecked: _inStock == true,
                    onTap: () {
                      setState(() => _inStock = _inStock == true ? null : true);
                      _apply();
                    },
                  ),
                  const SizedBox(height: 8),
                  _CheckboxRow(
                    label: 'Out of stock',
                    count: facets?.availabilityCounts['out_of_stock'],
                    isChecked: _inStock == false,
                    onTap: () {
                      setState(
                        () => _inStock = _inStock == false ? null : false,
                      );
                      _apply();
                    },
                  ),
                ],
              ),
            ),

            // ── Accordion 2: Price ───────────────────────────────
            _AccordionSection(
              title: 'Price',
              isOpen: _isPriceOpen,
              hasActiveValue:
                  filter.minPrice != null || filter.maxPrice != null,
              onToggle: () => setState(() => _isPriceOpen = !_isPriceOpen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The highest price is \$${maxPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '\$${displayedRange.start.toInt()}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'to',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            '\$${displayedRange.end.toInt()}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  RangeSlider(
                    values: displayedRange,
                    min: 0,
                    max: maxPrice,
                    divisions: 50,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.border,
                    onChanged: (v) => setState(() => _priceRange = v),
                    onChangeEnd: (_) => _apply(),
                  ),
                ],
              ),
            ),

            // ── Accordion 3: Color ───────────────────────────────
            _AccordionSection(
              title: 'Color',
              isOpen: _isColorOpen,
              hasActiveValue: _color != null,
              onToggle: () => setState(() => _isColorOpen = !_isColorOpen),
              child: Column(
                children: [
                  for (final color in _visibleChoices(
                    facets?.colors ?? const <String>[],
                    _showAllColors,
                    _color,
                  ))
                    _CheckboxRow(
                      label: color,
                      count: facets?.colorCounts[color],
                      isChecked: _color == color,
                      leading: ProductColorSwatch(
                        name: color,
                        selected: _color == color,
                      ),
                      onTap: () {
                        setState(() => _color = _color == color ? null : color);
                        _apply();
                      },
                    ),
                  if ((facets?.colors.length ?? 0) > 10)
                    _showMore(
                      _showAllColors,
                      () => setState(() => _showAllColors = !_showAllColors),
                    ),
                ],
              ),
            ),

            // ── Accordion 4: Size ────────────────────────────────
            _AccordionSection(
              title: 'Size',
              isOpen: _isSizeOpen,
              hasActiveValue: _size != null,
              onToggle: () => setState(() => _isSizeOpen = !_isSizeOpen),
              child: Column(
                children: [
                  for (final size in _visibleChoices(
                    facets?.sizes ?? const <String>[],
                    _showAllSizes,
                    _size,
                  ))
                    _CheckboxRow(
                      label: size,
                      count: facets?.sizeCounts[size],
                      isChecked: _size == size,
                      onTap: () {
                        setState(() => _size = _size == size ? null : size);
                        _apply();
                      },
                    ),
                  if ((facets?.sizes.length ?? 0) > 10)
                    _showMore(
                      _showAllSizes,
                      () => setState(() => _showAllSizes = !_showAllSizes),
                    ),
                ],
              ),
            ),

            // ── Accordion 5: Categories ──────────────────────────
            _AccordionSection(
              title: 'Categories',
              isOpen: _isCategoriesOpen,
              hasActiveValue: filter.categorySlug != null,
              onToggle: () =>
                  setState(() => _isCategoriesOpen = !_isCategoriesOpen),
              child: Column(
                children: [
                  for (final cat in _visibleChoices(
                    widget.categories,
                    _showAllCategories,
                    widget.categories
                        .where((c) => c.slug == filter.categorySlug)
                        .firstOrNull,
                  ))
                    Builder(
                      builder: (context) {
                        final isSelected =
                            selectedCategory == cat.slug ||
                            filter.categorySlug == cat.slug;
                        final hasNameCollision =
                            widget.categories
                                .where(
                                  (c) =>
                                      c.name.trim().toLowerCase() ==
                                      cat.name.trim().toLowerCase(),
                                )
                                .length >
                            1;
                        final displayLabel = hasNameCollision
                            ? '${cat.name} (${cat.gender.toLowerCase() == 'girls' ? "Girl's" : "Boy's"})'
                            : cat.name;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: _CategoryRow(
                            label: displayLabel,
                            imageUrl: cat.image,
                            count: cat.productCount,
                            isChecked: isSelected,
                            onTap: () {
                              final newSlug = isSelected ? null : cat.slug;
                              ref
                                      .read(selectedCategoryProvider.notifier)
                                      .state =
                                  newSlug;
                              ref
                                  .read(productFilterProvider.notifier)
                                  .update(
                                    (f) => f.copyWith(
                                      categorySlug: newSlug,
                                      clearCategory: newSlug == null,
                                    ),
                                  );
                            },
                          ),
                        );
                      },
                    ),
                  if (widget.categories.length > 10)
                    _showMore(
                      _showAllCategories,
                      () => setState(
                        () => _showAllCategories = !_showAllCategories,
                      ),
                    ),
                ],
              ),
            ),
            _AccordionSection(
              title: 'Product type',
              isOpen: _isProductTypesOpen,
              hasActiveValue: filter.productType != null,
              onToggle: () =>
                  setState(() => _isProductTypesOpen = !_isProductTypesOpen),
              child: Column(
                children: [
                  for (final type in _visibleChoices(
                    facets?.productTypes ?? const <String>[],
                    _showAllTypes,
                    _productType,
                  ))
                    _CheckboxRow(
                      label: type,
                      count: facets?.productTypeCounts[type],
                      isChecked: _productType == type,
                      onTap: () {
                        setState(
                          () =>
                              _productType = _productType == type ? null : type,
                        );
                        _apply();
                      },
                    ),
                  if ((facets?.productTypes.length ?? 0) > 10)
                    _showMore(
                      _showAllTypes,
                      () => setState(() => _showAllTypes = !_showAllTypes),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<T> _visibleChoices<T>(List<T> values, bool expanded, T? selected) {
    if (expanded || values.length <= 10) return values;
    final first = values.take(10).toList();
    if (selected != null &&
        !first.contains(selected) &&
        values.contains(selected)) {
      first.add(selected);
    }
    return first;
  }

  Widget _showMore(bool expanded, VoidCallback onPressed) => Align(
    alignment: Alignment.centerLeft,
    child: TextButton.icon(
      onPressed: onPressed,
      icon: Icon(expanded ? Icons.remove : Icons.add, size: 16),
      label: Text(expanded ? 'Show less' : 'Show more'),
    ),
  );
}

// ── Accordion Section Component (Shopify Pebble Style) ────────────────
class _AccordionSection extends StatelessWidget {
  final String title;
  final bool isOpen;
  final bool hasActiveValue;
  final VoidCallback onToggle;
  final Widget child;

  const _AccordionSection({
    required this.title,
    required this.isOpen,
    required this.onToggle,
    required this.child,
    this.hasActiveValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (hasActiveValue) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                // Animated plus/minus icon
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 180),
                  crossFadeState: isOpen
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const Icon(
                    Icons.add,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                  secondChild: const Icon(
                    Icons.remove,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 200),
          crossFadeState: isOpen
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity, height: 0),
          secondChild: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: child,
          ),
        ),
        const Divider(color: AppColors.border, height: 1, thickness: 1),
      ],
    );
  }
}

// ── Checkbox Row with Pebble Style ───────────────────────────────────
class _CheckboxRow extends StatelessWidget {
  final String label;
  final int? count;
  final bool isChecked;
  final VoidCallback onTap;
  final Widget? leading;

  const _CheckboxRow({
    required this.label,
    required this.isChecked,
    required this.onTap,
    this.count,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            leading ??
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isChecked ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isChecked ? AppColors.primary : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, size: 13, color: Colors.white)
                      : null,
                ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isChecked ? FontWeight.w600 : FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (count != null)
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final int count;
  final bool isChecked;
  final VoidCallback onTap;

  const _CategoryRow({
    required this.label,
    required this.imageUrl,
    required this.count,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 66,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          border: Border.all(
            color: isChecked ? AppColors.textPrimary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: SizedBox(
                width: 44,
                height: 44,
                child: imageUrl == null || imageUrl!.isEmpty
                    ? const ColoredBox(
                        color: Color(0xFFF2F2F2),
                        child: Icon(Icons.checkroom_outlined, size: 21),
                      )
                    : Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        cacheWidth: 88,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.checkroom_outlined, size: 21),
                      ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
