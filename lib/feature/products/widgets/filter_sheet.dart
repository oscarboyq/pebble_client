import 'package:flutter/material.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/feature/products/models/filter_model.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/widgets/product_color_swatch.dart';

class FilterSheet extends StatefulWidget {
  final ProductFilter initial;
  final List<String>? sizes;
  final List<String>? colors;
  final List<String>? productTypes;
  final List<CategoryModel>? categories;
  final double? maxPrice;

  const FilterSheet({
    super.key,
    required this.initial,
    this.sizes,
    this.colors,
    this.productTypes,
    this.categories,
    this.maxPrice,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late SortOption _sort;
  late RangeValues _priceRange;
  String? _color;
  String? _categorySlug;
  String? _productType;
  String? _size;
  bool? _inStock;
  bool _showAllColors = false;
  bool _showAllSizes = false;
  bool _showAllCategories = false;
  bool _showAllTypes = false;

  double get _maxPrice =>
      widget.maxPrice == null || widget.maxPrice! <= 0 ? 500 : widget.maxPrice!;

  static const List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  static const List<String> _colors = [
    'Black',
    'White',
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Pink',
    'Brown',
  ];

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

  @override
  void initState() {
    super.initState();
    _sort = widget.initial.sort;
    _priceRange = RangeValues(
      widget.initial.minPrice ?? 0,
      (widget.initial.maxPrice ?? _maxPrice).clamp(0, _maxPrice),
    );
    _color = widget.initial.color;
    _categorySlug = widget.initial.categorySlug;
    _productType = widget.initial.productType;
    _size = widget.initial.size;
    _inStock = widget.initial.inStock;
  }

  ProductFilter get _currentFilter => ProductFilter(
    categorySlug: _categorySlug,
    productType: _productType,
    minPrice: _priceRange.start > 0 ? _priceRange.start : null,
    maxPrice: _priceRange.end < _maxPrice ? _priceRange.end : null,
    color: _color,
    size: _size,
    inStock: _inStock,
    gender: widget.initial.gender,
    sale: widget.initial.sale,
    sort: _sort,
  );

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppDimensions.spacingSm,
                children: [
                  const Text(
                    'Filter & Sort',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _sort = SortOption.newest;
                        _priceRange = RangeValues(0, _maxPrice);
                        _color = null;
                        _categorySlug = null;
                        _productType = null;
                        _size = null;
                        _inStock = null;
                      });
                    },
                    child: const Text(
                      'Reset all',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Sort ──────────────────────────────────────
                    _SectionLabel('Sort by'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SortOption.values.map((option) {
                        final selected = _sort == option;
                        return _ChoiceChip(
                          label: option.label,
                          selected: selected,
                          onTap: () => setState(() => _sort = option),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // ── Price range ───────────────────────────────
                    _SectionLabel('Price range'),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${_priceRange.start.toInt()}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _priceRange.end >= _maxPrice
                              ? '\$${_priceRange.end.toInt()}+'
                              : '\$${_priceRange.end.toInt()}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        thumbColor: AppColors.primary,
                        inactiveTrackColor: AppColors.border,
                        overlayColor: AppColors.primary.withValues(alpha: 0.1),
                        trackHeight: 2,
                      ),
                      child: RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: _maxPrice,
                        divisions: 50,
                        onChanged: (v) => setState(() => _priceRange = v),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Size ──────────────────────────────────────
                    _SectionLabel('Size'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          _visibleChoices(
                            widget.sizes ?? _sizes,
                            _showAllSizes,
                            _size,
                          ).map((s) {
                            final selected = _size == s;
                            return _ChoiceChip(
                              label: s,
                              selected: selected,
                              onTap: () =>
                                  setState(() => _size = selected ? null : s),
                            );
                          }).toList(),
                    ),
                    if ((widget.sizes ?? _sizes).length > 10)
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _showAllSizes = !_showAllSizes),
                        icon: Icon(
                          _showAllSizes ? Icons.remove : Icons.add,
                          size: 16,
                        ),
                        label: Text(
                          _showAllSizes
                              ? 'Show less sizes'
                              : 'Show more sizes (${(widget.sizes ?? _sizes).length - 10})',
                        ),
                      ),
                    const SizedBox(height: 20),

                    // ── Color ─────────────────────────────────────
                    _SectionLabel('Color'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          _visibleChoices(
                            widget.colors ?? _colors,
                            _showAllColors,
                            _color,
                          ).map((name) {
                            return _ChoiceChip(
                              label: name,
                              leading: ProductColorSwatch(
                                name: name,
                                width: 14,
                                height: 14,
                              ),
                              selected: _color == name,
                              onTap: () => setState(
                                () => _color = _color == name ? null : name,
                              ),
                            );
                          }).toList(),
                    ),
                    if ((widget.colors ?? _colors).length > 10)
                      TextButton.icon(
                        onPressed: () =>
                            setState(() => _showAllColors = !_showAllColors),
                        icon: Icon(
                          _showAllColors ? Icons.remove : Icons.add,
                          size: 16,
                        ),
                        label: Text(
                          _showAllColors
                              ? 'Show less colors'
                              : 'Show more colors (${(widget.colors ?? _colors).length - 10})',
                        ),
                      ),
                    if (widget.categories?.isNotEmpty == true) ...[
                      const SizedBox(height: 20),
                      _SectionLabel('Categories'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _visibleChoices(
                                  widget.categories!,
                                  _showAllCategories,
                                  widget.categories!
                                      .where(
                                        (category) =>
                                            category.slug == _categorySlug,
                                      )
                                      .firstOrNull,
                                )
                                .map(
                                  (category) => _ChoiceChip(
                                    label: category.name,
                                    leading: category.image == null
                                        ? null
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                            child: Image.network(
                                              category.image!,
                                              width: 24,
                                              height: 24,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, _, _) =>
                                                  const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                  ),
                                            ),
                                          ),
                                    selected: _categorySlug == category.slug,
                                    onTap: () => setState(
                                      () => _categorySlug =
                                          _categorySlug == category.slug
                                          ? null
                                          : category.slug,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      if (widget.categories!.length > 10)
                        TextButton.icon(
                          onPressed: () => setState(
                            () => _showAllCategories = !_showAllCategories,
                          ),
                          icon: Icon(
                            _showAllCategories ? Icons.remove : Icons.add,
                            size: 16,
                          ),
                          label: Text(
                            _showAllCategories
                                ? 'Show less categories'
                                : 'Show more categories (${widget.categories!.length - 10})',
                          ),
                        ),
                    ],
                    if (widget.productTypes?.isNotEmpty == true) ...[
                      const SizedBox(height: 20),
                      _SectionLabel('Product type'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            _visibleChoices(
                                  widget.productTypes!,
                                  _showAllTypes,
                                  _productType,
                                )
                                .map(
                                  (type) => _ChoiceChip(
                                    label: type,
                                    selected: _productType == type,
                                    onTap: () => setState(
                                      () => _productType = _productType == type
                                          ? null
                                          : type,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                      if (widget.productTypes!.length > 10)
                        TextButton.icon(
                          onPressed: () =>
                              setState(() => _showAllTypes = !_showAllTypes),
                          icon: Icon(
                            _showAllTypes ? Icons.remove : Icons.add,
                            size: 16,
                          ),
                          label: Text(
                            _showAllTypes ? 'Show less' : 'Show more',
                          ),
                        ),
                    ],
                    const SizedBox(height: 20),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('In stock only'),
                      value: _inStock == true,
                      onChanged: (value) =>
                          setState(() => _inStock = value ? true : null),
                    ),
                    const SizedBox(height: 24),

                    // ── Apply button ──────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, _currentFilter),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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

// ── Helpers ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final Widget? leading;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    this.leading,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 6)],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
