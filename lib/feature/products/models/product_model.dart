import 'package:pebble_type/core/config/api_config.dart';

class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? image;
  final String? bannerImage;
  final int productCount;
  final String gender;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.image,
    this.bannerImage,
    this.productCount = 0,
    this.gender = 'boys',
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      image: ApiConfig.resolveImageUrlNullable(json['image'] as String?),
      bannerImage: ApiConfig.resolveImageUrlNullable(
        json['banner_image'] as String?,
      ),
      productCount: (json['product_count'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? 'boys',
    );
  }
}

class ProductImageModel {
  final int id;
  final String image;
  final String? cardImage;
  final String altText;
  final bool isPrimary;
  final int order;

  ProductImageModel({
    required this.id,
    required this.image,
    this.cardImage,
    required this.altText,
    required this.isPrimary,
    required this.order,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] as int,
      image: ApiConfig.resolveImageUrl(json['image'] as String? ?? ''),
      cardImage: ApiConfig.resolveImageUrlNullable(
        json['card_image'] as String?,
      ),
      altText: json['alt_text'] as String? ?? '',
      isPrimary: json['is_primary'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
    );
  }
}

class ProductVariantModel {
  final int id;
  final String color;
  final String size;
  final int stock;
  final String? priceOverride;
  final Map<String, String> attributes;

  const ProductVariantModel({
    required this.id,
    required this.color,
    required this.size,
    required this.stock,
    this.priceOverride,
    this.attributes = const {},
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    final rawAttrs = json['attributes'];
    Map<String, String> parsedAttrs = const {};
    if (rawAttrs is Map) {
      parsedAttrs = rawAttrs.map(
        (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
      );
    }

    var color = json['color'] as String? ?? '';
    var size = json['size'] as String? ?? '';

    if (color.isEmpty) {
      if (parsedAttrs['color']?.isNotEmpty == true) {
        color = parsedAttrs['color']!;
      } else if (parsedAttrs['option1']?.isNotEmpty == true &&
          parsedAttrs['option1']!.toLowerCase() != 'default title' &&
          !parsedAttrs['option1']!.contains('/')) {
        color = parsedAttrs['option1']!;
      }
    }

    if (size.isEmpty) {
      if (parsedAttrs['size']?.isNotEmpty == true) {
        size = parsedAttrs['size']!;
      } else if (parsedAttrs['option2']?.isNotEmpty == true &&
          !parsedAttrs['option2']!.contains('/')) {
        size = parsedAttrs['option2']!;
      }
    }

    return ProductVariantModel(
      id: json['id'] as int? ?? 0,
      color: color,
      size: size,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      priceOverride: json['price_override'] as String?,
      attributes: parsedAttrs,
    );
  }

  /// Human-readable label from attributes (or color/size fallback)
  String get displayLabel {
    if (attributes.isNotEmpty) {
      return attributes.values.join(' \u00b7 ');
    }
    final parts = <String>[];
    if (color.isNotEmpty) parts.add(color);
    if (size.isNotEmpty) parts.add(size);
    return parts.join(' \u00b7 ');
  }
}

class VariantEngine {
  final List<ProductVariantModel> variants;

  VariantEngine(this.variants);

  /// Whether this product uses the new attributes-based variant system (jewelry)
  bool get usesAttributes {
    final customKeys = attributeNames.where((k) {
      final l = k.toLowerCase().trim();
      return l != 'title' &&
          l != 'option1' &&
          l != 'option2' &&
          l != 'color' &&
          l != 'size' &&
          l != 'default title';
    }).toList();
    return customKeys.isNotEmpty && (allColors.isEmpty && allSizes.isEmpty);
  }

  /// The unique attribute names across all variants (e.g. ["Metal", "Ring Size"])
  List<String> get attributeNames {
    final names = <String>{};
    for (final v in variants) {
      names.addAll(v.attributes.keys);
    }
    names.removeWhere((k) {
      final l = k.toLowerCase().trim();
      return l == 'title' ||
          l == 'default title' ||
          l == 'option1' ||
          l == 'option2';
    });
    return names.toList();
  }

  /// All unique values for a given attribute name
  List<String> attributeValues(String attributeName) => variants
      .map((v) => v.attributes[attributeName] ?? '')
      .where((v) => v.isNotEmpty)
      .toSet()
      .toList();

  /// All unique colors (non-empty) — extracted from color property and color/option1 attributes
  List<String> get allColors {
    final colors = <String>{};
    for (final v in variants) {
      if (v.color.isNotEmpty) {
        colors.add(v.color);
      } else if (v.attributes['color']?.isNotEmpty == true) {
        colors.add(v.attributes['color']!);
      } else if (v.attributes['option1']?.isNotEmpty == true &&
          v.attributes['option1']!.toLowerCase() != 'default title' &&
          !v.attributes['option1']!.contains('/')) {
        colors.add(v.attributes['option1']!);
      }
    }
    return colors.toList();
  }

  /// All unique sizes (non-empty) — extracted from size property and size/option2 attributes
  List<String> get allSizes {
    final sizes = <String>{};
    for (final v in variants) {
      if (v.size.isNotEmpty) {
        sizes.add(v.size);
      } else if (v.attributes['size']?.isNotEmpty == true) {
        sizes.add(v.attributes['size']!);
      } else if (v.attributes['option2']?.isNotEmpty == true &&
          !v.attributes['option2']!.contains('/')) {
        sizes.add(v.attributes['option2']!);
      }
    }
    return sizes.toList();
  }

  /// Available values for an attribute given current selections
  List<String> availableAttributeValues(
    String attributeName, {
    Map<String, String>? selected,
  }) {
    if (selected == null || selected.isEmpty) {
      return attributeValues(attributeName);
    }
    // Filter: variants matching ALL selected attributes EXCEPT this one
    return variants
        .where((v) {
          for (final entry in selected.entries) {
            if (entry.key == attributeName) continue;
            if (v.attributes[entry.key] != entry.value) return false;
          }
          return true;
        })
        .map((v) => v.attributes[attributeName] ?? '')
        .where((v) => v.isNotEmpty)
        .toSet()
        .toList();
  }

  /// Colors that have variants matching the currently selected size (legacy).
  List<String> availableColors({String? selectedSize}) {
    if (selectedSize == null || selectedSize.isEmpty) return allColors;
    final matched = variants
        .where(
          (v) =>
              v.size.isEmpty ||
              v.size.toLowerCase() == selectedSize.toLowerCase(),
        )
        .map((v) => v.color)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
    return matched.isNotEmpty ? matched : allColors;
  }

  /// Sizes that have variants matching the currently selected color (legacy).
  List<String> availableSizes({String? selectedColor}) {
    if (selectedColor == null || selectedColor.isEmpty) return allSizes;
    final matched = variants
        .where(
          (v) =>
              v.color.isEmpty ||
              v.color.toLowerCase() == selectedColor.toLowerCase(),
        )
        .map((v) => v.size)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    return matched.isNotEmpty ? matched : allSizes;
  }

  /// Find the variant that matches selections (legacy).
  ProductVariantModel? findExact({String? color, String? size}) {
    try {
      return variants.firstWhere((v) {
        final matchesColor =
            color == null ||
            color.isEmpty ||
            v.color.isEmpty ||
            v.color.toLowerCase() == color.toLowerCase();
        final matchesSize =
            size == null ||
            size.isEmpty ||
            v.size.isEmpty ||
            v.size.toLowerCase() == size.toLowerCase();
        return matchesColor && matchesSize;
      });
    } catch (e) {
      return null;
    }
  }

  /// Find variant by attributes map (for jewelry with dynamic attributes).
  ProductVariantModel? findExactByAttributes(Map<String, String> attrs) {
    try {
      return variants.firstWhere((v) {
        for (final entry in attrs.entries) {
          if (v.attributes[entry.key] != entry.value) return false;
        }
        return true;
      });
    } catch (e) {
      return null;
    }
  }

  /// Auto-select remaining attribute if only one option left.
  String? autoSelectedColor({String? selectedSize}) {
    final colors = availableColors(selectedSize: selectedSize);
    return colors.length == 1 ? colors.first : null;
  }

  String? autoSelectedSize({String? selectedColor}) {
    final sizes = availableSizes(selectedColor: selectedColor);
    return sizes.length == 1 ? sizes.first : null;
  }

  /// Whether a specific variant is in stock (legacy).
  bool isInStock({String? color, String? size}) {
    final v = findExact(color: color, size: size);
    return v != null && v.stock > 0;
  }

  /// Whether a specific variant (by attributes) is in stock.
  bool isInStockByAttributes(Map<String, String> attrs) {
    final v = findExactByAttributes(attrs);
    return v != null && v.stock > 0;
  }

  /// Find variant efficiently (works for both legacy and attributes).
  ProductVariantModel? find({
    String? color,
    String? size,
    Map<String, String>? attributes,
  }) {
    if (usesAttributes && attributes != null) {
      return findExactByAttributes(attributes);
    }
    return findExact(color: color, size: size);
  }
}

class ProductModel {
  final int id;
  final CategoryModel category;
  final String name;
  final String slug;
  final String description;
  final String price;
  final String? compareAtPrice;
  final String sku;
  final String badge;
  final String videoFile;
  final String videoUrl;
  final double? weight;
  final bool isActive;
  final DateTime createdAt;
  final List<ProductImageModel> images;
  final List<ProductVariantModel> variants;

  // Product detail / spec fields
  final String material;
  final String specialFeatures;
  final String careAndCleaning;
  final String manufacturedBy;

  ProductModel({
    required this.id,
    required this.category,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    required this.compareAtPrice,
    required this.sku,
    required this.badge,
    required this.videoUrl,
    required this.weight,
    required this.isActive,
    required this.createdAt,
    required this.images,
    required this.videoFile,
    required this.variants,
    this.material = '',
    this.specialFeatures = '',
    this.careAndCleaning = '',
    this.manufacturedBy = '',
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int? ?? 0,
      category: CategoryModel.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: json['price'] as String? ?? '0.00',
      compareAtPrice: json['compare_at_price'] as String?,
      sku: json['sku'] as String? ?? '',
      badge: json['badge'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      videoFile: ApiConfig.resolveImageUrl(json['video_file'] as String? ?? ''),
      weight: num.tryParse(json['weight']?.toString() ?? '')?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      images: (json['images'] as List<dynamic>? ?? const [])
          .map((e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      variants: (json['variants'] as List<dynamic>? ?? const [])
          .map((e) => ProductVariantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      material: json['material'] as String? ?? '',
      specialFeatures: json['special_features'] as String? ?? '',
      careAndCleaning: json['care_and_cleaning'] as String? ?? '',
      manufacturedBy: json['manufactured_by'] as String? ?? '',
    );
  }

  double get priceAsDouble => double.parse(price);
  double? get compareAtPricesAsDouble =>
      compareAtPrice != null ? double.parse(compareAtPrice!) : null;

  /// True when there's a sale badge or compare_at_price set
  bool get isOnSale => compareAtPrice != null || badge.toLowerCase() == 'sale';

  /// Primary image URL, or null if no images
  String? get primaryImageUrl {
    if (images.isEmpty) return null;
    final primary = images.where((i) => i.isPrimary).toList();
    return primary.isNotEmpty ? primary.first.image : images.first.image;
  }

  /// Smaller image supplied by the API for collection cards on the web.
  String? get primaryCardImageUrl {
    if (images.isEmpty) return null;
    final primary = images.where((i) => i.isPrimary).toList();
    final image = primary.isNotEmpty ? primary.first : images.first;
    return image.cardImage ?? image.image;
  }

  /// Secondary image URL (for hover reveal), or null if less than 2 images
  String? get secondaryImageUrl {
    if (images.length < 2) return null;
    return images[1].image;
  }

  String? get secondaryCardImageUrl {
    if (images.length < 2) return null;
    return images[1].cardImage ?? images[1].image;
  }

  String get playableVideoUrl {
    if (videoFile.trim().isNotEmpty) return videoFile;

    return videoUrl;
  }

  bool get hasVideo => playableVideoUrl.trim().isNotEmpty;

  /// Get effective price for a specific variant combination.
  /// Supports both legacy (color/size) and new (attributes) variant systems.
  /// Returns the variant's price_override if set, otherwise the base price.
  String effectivePrice({
    String? color,
    String? size,
    Map<String, String>? attributes,
  }) {
    final engine = VariantEngine(variants);
    final ProductVariantModel? exact;
    if (attributes != null && engine.usesAttributes) {
      exact = engine.findExactByAttributes(attributes);
    } else {
      exact = engine.findExact(color: color, size: size);
    }
    if (exact?.priceOverride != null) {
      return exact!.priceOverride!;
    }
    return price;
  }

  /// Get effective price as double.
  double effectivePriceAsDouble({
    String? color,
    String? size,
    Map<String, String>? attributes,
  }) {
    final engine = VariantEngine(variants);
    final ProductVariantModel? exact;
    if (attributes != null && engine.usesAttributes) {
      exact = engine.findExactByAttributes(attributes);
    } else {
      exact = engine.findExact(color: color, size: size);
    }
    if (exact?.priceOverride != null) {
      return double.parse(exact!.priceOverride!);
    }
    return priceAsDouble;
  }

  String get formattedWeight {
    if (weight == null) return '';
    return '${weight!.toStringAsFixed(2)} kg';
  }

  int get totalStock => variants.fold(0, (sum, v) => sum + v.stock);

  bool get hasDetailSpecs =>
      material.isNotEmpty ||
      specialFeatures.isNotEmpty ||
      careAndCleaning.isNotEmpty ||
      manufacturedBy.isNotEmpty ||
      weight != null;

  bool get hasQuickSpecs =>
      formattedWeight.isNotEmpty ||
      material.isNotEmpty ||
      manufacturedBy.isNotEmpty;
}
