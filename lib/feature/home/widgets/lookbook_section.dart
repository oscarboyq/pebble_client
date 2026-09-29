import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

/// Lookbook section — a lifestyle image with product hotspot circles.
/// Pass [imageUrl] as the lifestyle photo URL and [hotspots] as
/// a list of products with their normalised (0–1) positions on the image.
class LookbookSection extends StatelessWidget {
  final String imageUrl;
  final List<LookbookHotspot> hotspots;
  final String? sectionTitle;

  const LookbookSection({
    super.key,
    required this.imageUrl,
    required this.hotspots,
    this.sectionTitle,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = context.isWide;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isWide ? 48 : 32,
        horizontal: isWide ? 40 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sectionTitle != null)
            Padding(
              padding: EdgeInsets.only(bottom: 20, left: isWide ? 0 : 16),
              child: Text(
                sectionTitle!,
                style: TextStyle(
                  fontSize: isWide ? 26 : 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(isWide ? 4 : 0),
            child: _LookbookImage(imageUrl: imageUrl, hotspots: hotspots),
          ),
        ],
      ),
    );
  }
}

class LookbookHotspot {
  /// Normalised position on the image (0.0 – 1.0 for both x and y)
  final double left;
  final double top;
  final ProductModel product;

  const LookbookHotspot({
    required this.left,
    required this.top,
    required this.product,
  });
}

class _LookbookImage extends StatefulWidget {
  final String imageUrl;
  final List<LookbookHotspot> hotspots;

  const _LookbookImage({required this.imageUrl, required this.hotspots});

  @override
  State<_LookbookImage> createState() => _LookbookImageState();
}

class _LookbookImageState extends State<_LookbookImage> {
  int? _activeIndex;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background lifestyle image
          Image.network(
            widget.imageUrl,
            fit: BoxFit.cover,
            cacheWidth: 1200,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => Container(color: AppColors.border),
          ),
          // Hotspot circles + popups
          ...widget.hotspots.asMap().entries.map((entry) {
            final i = entry.key;
            final hotspot = entry.value;
            return _Hotspot(
              hotspot: hotspot,
              isActive: _activeIndex == i,
              onTap: () =>
                  setState(() => _activeIndex = _activeIndex == i ? null : i),
            );
          }),
        ],
      ),
    );
  }
}

class _Hotspot extends StatelessWidget {
  final LookbookHotspot hotspot;
  final bool isActive;
  final VoidCallback onTap;

  const _Hotspot({
    required this.hotspot,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: null,
      top: null,
      child: FractionallySizedBox(
        widthFactor: hotspot.left,
        heightFactor: hotspot.top,
        child: Align(
          alignment: Alignment.bottomRight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Popup card
              if (isActive)
                Container(
                  width: 180,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () =>
                        context.go('/products/${hotspot.product.slug}'),
                    child: Row(
                      children: [
                        // Thumbnail
                        if (hotspot.product.primaryImageUrl != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(4),
                            ),
                            child: Image.network(
                              hotspot.product.primaryImageUrl!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              cacheWidth: 150,
                              gaplessPlayback: true,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox(width: 56, height: 56),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hotspot.product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '\$${hotspot.product.price}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ),
              // Hotspot circle button
              GestureDetector(
                onTap: onTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isActive ? 36 : 28,
                  height: isActive ? 36 : 28,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.surface.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add,
                    size: isActive ? 18 : 14,
                    color: isActive ? AppColors.surface : AppColors.primary,
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
