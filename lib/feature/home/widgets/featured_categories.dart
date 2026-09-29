import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

class FeaturedCategories extends StatelessWidget {
  final List<CategoryModel> categories;

  const FeaturedCategories({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final isWide = context.isWide;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isWide ? 40 : 16,
        isWide ? 48 : 24,
        isWide ? 40 : 16,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shop by Category',
                style: TextStyle(
                  fontSize: isWide ? 26 : 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isWide)
                GestureDetector(
                  onTap: () => context.go(AppRoutes.home),
                  child: const Text(
                    'View all →',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Desktop: 4-col grid with image cards
          // Mobile: horizontal scroll chips
          if (isWide)
            _DesktopCategoryGrid(categories: categories)
          else
            _MobileCategoryScroll(categories: categories),
        ],
      ),
    );
  }
}

// ── Desktop 4-column grid ───────────────────────────────────────────
class _DesktopCategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  const _DesktopCategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    final cols = context.responsive<int>(mobile: 2, tablet: 3, desktop: 4);
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (cols - 1) * 16) / cols;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: categories.map((cat) {
            return SizedBox(
              width: itemWidth,
              child: _DesktopCategoryCard(category: cat),
            );
          }).toList(),
        );
      },
    );
  }
}

class _DesktopCategoryCard extends StatefulWidget {
  final CategoryModel category;
  const _DesktopCategoryCard({required this.category});

  @override
  State<_DesktopCategoryCard> createState() => _DesktopCategoryCardState();
}

class _DesktopCategoryCardState extends State<_DesktopCategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go(
          AppRoutes.home,
          extra: {'category': widget.category.slug},
        ),
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image with subtle zoom on hover
                AnimatedScale(
                  scale: _hovered ? 1.04 : 1.0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  child:
                      widget.category.image != null &&
                          widget.category.image!.isNotEmpty
                      ? Image.network(
                          widget.category.image!,
                          fit: BoxFit.cover,
                          cacheWidth: 600,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                // Gradient overlay
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
                // Name label
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    widget.category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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

  Widget _placeholder() => Container(
    color: AppColors.border,
    child: const Center(
      child: Icon(
        Icons.category_outlined,
        color: AppColors.textSecondary,
        size: 40,
      ),
    ),
  );
}

// ── Mobile horizontal scroll chips ─────────────────────────────────
class _MobileCategoryScroll extends StatelessWidget {
  final List<CategoryModel> categories;
  const _MobileCategoryScroll({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          return _CategoryChip(category: category);
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryModel category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.go(AppRoutes.home, extra: {'category': category.slug}),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(32),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: category.image != null && category.image!.isNotEmpty
                  ? Image.network(
                      category.image!,
                      fit: BoxFit.cover,
                      cacheWidth: 150,
                      gaplessPlayback: true,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.category_outlined,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : const Icon(
                      Icons.category_outlined,
                      color: AppColors.textSecondary,
                    ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 72,
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
