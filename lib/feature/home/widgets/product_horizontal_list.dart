import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/core/widgets/reveal_on_scroll.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/widgets/quick_view_sheet.dart';

class ProductHorizontalList extends StatelessWidget {
  final String title;
  final List<ProductModel> products;

  const ProductHorizontalList({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

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
                title,
                style: TextStyle(
                  fontSize: isWide ? 26 : 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/products'),
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

          // Desktop: responsive grid | Mobile: horizontal scroll
          if (isWide)
            _DesktopProductGrid(products: products)
          else
            _MobileProductScroll(products: products),
        ],
      ),
    );
  }
}

// ── Desktop 4-col product grid ──────────────────────────────────────
class _DesktopProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  const _DesktopProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    final cols = context.responsive<int>(mobile: 2, tablet: 3, desktop: 4);
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 16.0;
        final itemWidth = (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: products.asMap().entries.map((e) {
            return RevealOnScroll(
              delay: Duration(milliseconds: e.key * 65),
              child: SizedBox(
                width: itemWidth,
                child: _DesktopProductCard(product: e.value),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _DesktopProductCard extends ConsumerStatefulWidget {
  final ProductModel product;
  const _DesktopProductCard({required this.product});

  @override
  ConsumerState<_DesktopProductCard> createState() =>
      _DesktopProductCardState();
}

class _DesktopProductCardState extends ConsumerState<_DesktopProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => context.go('/products/${product.slug}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            AspectRatio(
              aspectRatio: 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image with hover zoom
                    AnimatedScale(
                      scale: _hovered ? 1.04 : 1.0,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                      child: product.primaryImageUrl != null
                          ? Image.network(
                              product.primaryImageUrl!,
                              fit: BoxFit.cover,
                              cacheWidth: 600,
                              gaplessPlayback: true,
                              errorBuilder: (_, __, ___) => _placeholder(),
                            )
                          : _placeholder(),
                    ),
                    // Badge
                    if (product.badge.isNotEmpty)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            product.badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    // Quick view — appears on hover
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _hovered ? 1.0 : 0.0,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: GestureDetector(
                          onTap: () => showQuickView(context, product.slug),
                          child: Container(
                            width: double.infinity,
                            color: Colors.black.withValues(alpha: 0.7),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: const Text(
                              'Quick View',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  '\$${product.price}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (product.compareAtPrice != null) ...[
                  const SizedBox(width: 6),
                  Text(
                    '\$${product.compareAtPrice}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.background,
    child: const Center(
      child: Icon(Icons.image_outlined, color: AppColors.border, size: 40),
    ),
  );
}

// ── Mobile horizontal scroll ────────────────────────────────────────
class _MobileProductScroll extends StatelessWidget {
  final List<ProductModel> products;
  const _MobileProductScroll({required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return RevealOnScroll(
            delay: Duration(milliseconds: index * 60),
            child: _HorizontalProductCard(product: products[index]),
          );
        },
      ),
    );
  }
}

class _HorizontalProductCard extends ConsumerWidget {
  final ProductModel product;
  const _HorizontalProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => context.go('/products/${product.slug}'),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: Stack(
                children: [
                  SizedBox(
                    height: 140,
                    width: 150,
                    child: product.primaryImageUrl != null
                        ? Image.network(
                            product.primaryImageUrl!,
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                            gaplessPlayback: true,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.background,
                              child: const Icon(
                                Icons.image_outlined,
                                color: AppColors.border,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.background,
                            child: const Icon(
                              Icons.image_outlined,
                              color: AppColors.border,
                            ),
                          ),
                  ),
                  if (product.badge.isNotEmpty)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          product.badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => showQuickView(context, product.slug),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withAlpha(220),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.visibility_outlined,
                          size: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
}
