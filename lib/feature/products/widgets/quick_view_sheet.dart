import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/services/storage_service.dart';
import 'package:pebble_type/feature/cart/providers/cart_provider.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/providers/product_providers.dart';

void showQuickView(BuildContext context, String slug) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => QuickViewSheet(slug: slug),
  );
}

class QuickViewSheet extends ConsumerStatefulWidget {
  final String slug;
  const QuickViewSheet({super.key, required this.slug});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _QuickViewSheetState();
}

class _QuickViewSheetState extends ConsumerState<QuickViewSheet> {
  String? _selectedColor;
  String? _selectedSize;
  Map<String, String> _selectedAttributes = {};
  bool _initialized = false;

  void _initVariants(List<ProductVariantModel> variants) {
    if (!_initialized && variants.isNotEmpty) {
      final engine = VariantEngine(variants);
      final initial = variants.firstWhere(
        (variant) => variant.stock > 0,
        orElse: () => variants.first,
      );
      if (engine.usesAttributes) {
        _selectedAttributes = Map.from(initial.attributes);
      } else {
        _selectedColor = initial.color;
        _selectedSize = initial.size;
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.slug));
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: productAsync.when(
        data: (product) {
          _initVariants(product.variants);
          return _buildContent(context, product);
        },
        error: (_, __) => const SizedBox(
          height: 200,
          child: Center(child: Text('Failed to load product.')),
        ),
        loading: () => const SizedBox(
          height: 300,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductModel product) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle
        Center(
          child: Container(
            margin: EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,

              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),

        //Image + Info row
        Padding(
          padding: EdgeInsetsGeometry.symmetric(
            horizontal: AppDimensions.spacingMd,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                child: SizedBox(
                  width: 110,
                  height: 110,
                  child: product.primaryImageUrl != null
                      ? Image.network(
                          product.primaryImageUrl!,
                          fit: BoxFit.cover,
                          cacheWidth: 250,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
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
              ),
              SizedBox(width: AppDimensions.spacingMd),
              //Name , Category, Price, badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.name.toLowerCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '\$${product.price}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (product.compareAtPricesAsDouble != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '\$${product.compareAtPrice}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (product.badge.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: product.badge.toLowerCase() == 'sale'
                              ? AppColors.error
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusSm,
                          ),
                        ),
                        child: Text(
                          product.badge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.spacingMd),
        // Variants
        if (product.variants.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
            ),
            child: _QuickViewVariantSelector(
              variants: product.variants,
              selectedColor: _selectedColor,
              selectedSize: _selectedSize,
              selectedAttributes: _selectedAttributes,
              onColorChanged: (c) => setState(() => _selectedColor = c),
              onSizeChanged: (s) => setState(() => _selectedSize = s),
              onAttributeChanged: (name, value) {
                setState(() => _selectedAttributes[name] = value);
              },
              product: product,
            ),
          ),
        // Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingMd,
            0,
            AppDimensions.spacingMd,
            AppDimensions.spacingMd,
          ),
          child: Column(
            children: [
              // Add to cart
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: product.totalStock > 0
                      ? () async {
                          final token = await StorageService.getAccessToken();
                          if (token == null) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please sign in to add items to your cart',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              context.push(AppRoutes.login);
                            }
                            return;
                          }
                          ProductVariantModel? selectedVariant;
                          final engine = VariantEngine(product.variants);
                          if (engine.usesAttributes &&
                              _selectedAttributes.isNotEmpty) {
                            selectedVariant = engine.findExactByAttributes(
                              _selectedAttributes,
                            );
                          } else if (_selectedColor != null ||
                              _selectedSize != null) {
                            final match = product.variants.where(
                              (v) =>
                                  v.color == _selectedColor &&
                                  v.size == _selectedSize,
                            );
                            if (match.isNotEmpty) selectedVariant = match.first;
                          }
                          if (selectedVariant == null ||
                              selectedVariant.stock <= 0) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Select an available option before adding to cart.',
                                  ),
                                ),
                              );
                            }
                            return;
                          }
                          final success = await ref
                              .read(cartProvider.notifier)
                              .addItem(
                                productSlung: widget.slug,
                                variantId: selectedVariant.id,
                              );
                          if (context.mounted) {
                            if (success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to cart!')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Could not add this item. Please try again.',
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                  ),
                  child: Text(
                    product.variants.isEmpty
                        ? 'Unavailable'
                        : product.totalStock <= 0
                        ? 'Sold out'
                        : 'Add to Cart',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),

              // View full details
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/products/${widget.slug}');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                  ),
                  child: const Text(
                    'View Full Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickViewVariantSelector extends StatelessWidget {
  final List<ProductVariantModel> variants;
  final String? selectedColor;
  final String? selectedSize;
  final Map<String, String> selectedAttributes;
  final ValueChanged<String> onColorChanged;
  final ValueChanged<String> onSizeChanged;
  final void Function(String, String) onAttributeChanged;
  final ProductModel product;

  const _QuickViewVariantSelector({
    required this.variants,
    this.selectedColor,
    this.selectedSize,
    this.selectedAttributes = const {},
    required this.onColorChanged,
    required this.onSizeChanged,
    required this.onAttributeChanged,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final engine = VariantEngine(variants);

    if (engine.usesAttributes) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final attrName in engine.attributeNames) ...[
            Text(
              attrName.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: engine
                  .attributeValues(attrName)
                  .map(
                    (value) => _VariantChip(
                      label: value,
                      selected: selectedAttributes[attrName] == value,
                      onTap: () => onAttributeChanged(attrName, value),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],
        ],
      );
    }

    // Legacy: color + size
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (engine.allColors.isNotEmpty) ...[
          const Text(
            'COLOR',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: engine.allColors
                .map(
                  (c) => _VariantChip(
                    label: c,
                    selected: selectedColor == c,
                    onTap: () => onColorChanged(c),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (engine.allSizes.isNotEmpty) ...[
          const Text(
            'SIZE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: engine.allSizes
                .map(
                  (s) => _VariantChip(
                    label: s,
                    selected: selectedSize == s,
                    onTap: () => onSizeChanged(s),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _VariantChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _VariantChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
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
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
