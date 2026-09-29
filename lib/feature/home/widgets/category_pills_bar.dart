import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

class CategoryPillsBar extends StatefulWidget {
  final List<CategoryModel> categories;
  final String? initialSelectedSlug;
  final ValueChanged<String?>? onCategoryChanged;

  const CategoryPillsBar({
    super.key,
    required this.categories,
    this.initialSelectedSlug,
    this.onCategoryChanged,
  });

  @override
  State<CategoryPillsBar> createState() => _CategoryPillsBarState();
}

class _CategoryPillsBarState extends State<CategoryPillsBar> {
  late String? _selectedSlug;

  @override
  void initState() {
    super.initState();
    _selectedSlug = widget.initialSelectedSlug;
  }

  int get _totalProductCount {
    return widget.categories.fold<int>(
      0,
      (sum, cat) => sum + cat.productCount,
    );
  }

  void _selectCategory(String? slug) {
    setState(() => _selectedSlug = slug);
    widget.onCategoryChanged?.call(slug);
    if (slug != null) {
      context.go(AppRoutes.home, extra: {'category': slug});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.categories.isEmpty) return const SizedBox.shrink();

    final isWide = context.isWide;
    final totalCount = _totalProductCount;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 48 : 20,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Explore Collections',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: isWide ? 22 : 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$totalCount Items',
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF888888),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Pills
          if (isWide)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                // "All" Pill
                _CategoryPillItem(
                  label: 'All',
                  count: totalCount,
                  isSelected: _selectedSlug == null,
                  onTap: () => _selectCategory(null),
                ),
                ...widget.categories.map((cat) {
                  return _CategoryPillItem(
                    label: cat.name,
                    count: cat.productCount,
                    isSelected: _selectedSlug == cat.slug,
                    onTap: () => _selectCategory(cat.slug),
                  );
                }),
              ],
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  _CategoryPillItem(
                    label: 'All',
                    count: totalCount,
                    isSelected: _selectedSlug == null,
                    onTap: () => _selectCategory(null),
                  ),
                  const SizedBox(width: 8),
                  ...widget.categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CategoryPillItem(
                        label: cat.name,
                        count: cat.productCount,
                        isSelected: _selectedSlug == cat.slug,
                        onTap: () => _selectCategory(cat.slug),
                      ),
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

class _CategoryPillItem extends StatefulWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPillItem({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryPillItem> createState() => _CategoryPillItemState();
}

class _CategoryPillItemState extends State<_CategoryPillItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF111111)
                : (_hovered ? const Color(0xFFEBE8E3) : const Color(0xFFF5F3EF)),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: active
                  ? const Color(0xFF111111)
                  : (_hovered ? const Color(0xFF111111) : const Color(0xFFE5E1D8)),
              width: 1,
            ),
            boxShadow: _hovered && !active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  color: active ? Colors.white : const Color(0xFF1E1E1E),
                ),
              ),
              if (widget.count > 0) ...[
                const SizedBox(width: 6),
                Text(
                  '(${widget.count})',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: active
                        ? Colors.white.withValues(alpha: 0.70)
                        : const Color(0xFF888888),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
