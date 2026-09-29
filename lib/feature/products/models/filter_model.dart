class ProductFilter {
  final String? categorySlug;
  final String? productType;
  final double? minPrice;
  final double? maxPrice;
  final String? color;
  final String? size;
  final bool? inStock;
  final String? gender;
  final bool? sale;
  final SortOption sort;

  const ProductFilter({
    this.categorySlug,
    this.productType,
    this.minPrice,
    this.maxPrice,
    this.color,
    this.size,
    this.inStock,
    this.gender,
    this.sale,
    this.sort = SortOption.newest,
  });

  ProductFilter copyWith({
    String? categorySlug,
    String? productType,
    double? minPrice,
    double? maxPrice,
    String? color,
    String? size,
    bool? inStock,
    String? gender,
    bool? sale,
    SortOption? sort,
    bool clearCategory = false,
    bool clearProductType = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearColor = false,
    bool clearSize = false,
    bool clearInStock = false,
    bool clearGender = false,
    bool clearSale = false,
  }) {
    return ProductFilter(
      categorySlug: clearCategory ? null : categorySlug ?? this.categorySlug,
      productType: clearProductType ? null : productType ?? this.productType,
      minPrice: clearMinPrice ? null : minPrice ?? this.minPrice,
      maxPrice: clearMaxPrice ? null : maxPrice ?? this.maxPrice,
      color: clearColor ? null : color ?? this.color,
      size: clearSize ? null : size ?? this.size,
      inStock: clearInStock ? null : inStock ?? this.inStock,
      gender: clearGender ? null : gender ?? this.gender,
      sale: clearSale ? null : sale ?? this.sale,
      sort: sort ?? this.sort,
    );
  }

  bool get hasActiveFilters =>
      categorySlug != null ||
      productType != null ||
      minPrice != null ||
      maxPrice != null ||
      color != null ||
      size != null ||
      inStock != null ||
      gender != null ||
      sale != null ||
      sort != SortOption.newest;

  int get activeFilterCount {
    int count = 0;
    if (categorySlug != null) count++;
    if (productType != null) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (color != null) count++;
    if (size != null) count++;
    if (inStock != null) count++;
    if (gender != null) count++;
    if (sale != null) count++;
    if (sort != SortOption.newest) count++;
    return count;
  }
}

enum SortOption {
  newest,
  bestSelling,
  priceAsc,
  priceDesc,
  topRated;

  String get label {
    switch (this) {
      case SortOption.newest:
        return 'Featured';
      case SortOption.bestSelling:
        return 'Best selling';
      case SortOption.priceAsc:
        return 'Price, low to high';
      case SortOption.priceDesc:
        return 'Price, high to low';
      case SortOption.topRated:
        return 'Top rated';
    }
  }

  String get apiValue {
    switch (this) {
      case SortOption.newest:
        return 'newest';
      case SortOption.bestSelling:
        return 'best_selling';
      case SortOption.priceAsc:
        return 'price_asc';
      case SortOption.priceDesc:
        return 'price_desc';
      case SortOption.topRated:
        return 'top_rated';
    }
  }
}
