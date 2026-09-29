import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pebble_type/core/services/product_service.dart';
import 'package:pebble_type/feature/products/models/filter_model.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Single filter state — replaces selectedCategoryProvider
final productFilterProvider = StateProvider<ProductFilter>(
  (ref) => const ProductFilter(),
);

// Keep this alias so existing code using selectedCategoryProvider still works
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Categories list
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ProductService.getCategories();
});

final shopAllFacetsProvider = FutureProvider<ProductFacets>((ref) async {
  final filter = ref.watch(productFilterProvider);
  // Keep choices available after selection while scoping them to the current
  // browse category, as on the reference's Shop All page.
  return ProductService.getFacets(
    filter: ProductFilter(
      categorySlug: filter.categorySlug,
      gender: filter.gender,
      sale: filter.sale,
    ),
  );
});

// Product list — reacts to search + filter changes
class ProductListNotifier extends AsyncNotifier<List<ProductModel>> {
  @override
  Future<List<ProductModel>> build() async {
    final search = ref.watch(searchQueryProvider);
    final filter = ref.watch(productFilterProvider);
    // Keep legacy category support in sync
    final legacyCategory = ref.watch(selectedCategoryProvider);
    return ProductService.getProducts(
      search: search,
      filter: filter.categorySlug != null
          ? filter
          : filter.copyWith(categorySlug: legacyCategory),
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    final search = ref.read(searchQueryProvider);
    final filter = ref.read(productFilterProvider);
    final legacyCategory = ref.read(selectedCategoryProvider);
    state = await AsyncValue.guard(
      () => ProductService.getProducts(
        search: search,
        filter: filter.categorySlug != null
            ? filter
            : filter.copyWith(categorySlug: legacyCategory),
      ),
    );
  }
}

final productListProvider =
    AsyncNotifierProvider<ProductListNotifier, List<ProductModel>>(
      ProductListNotifier.new,
    );

final productDetailProvider = FutureProvider.family<ProductModel, String>((
  ref,
  slug,
) async {
  return ProductService.getProduct(slug);
});

// Products belonging to a storefront collection slug (smart/manual).
final collectionProductsProvider =
    FutureProvider.family<List<ProductModel>, String>((ref, slug) async {
      return ProductService.getProducts(collectionSlug: slug);
    });

typedef CollectionQuery = ({String slug, String filters});
typedef CollectionPageQuery = ({String slug, String filters, int page});

final collectionPageProvider = FutureProvider.autoDispose
    .family<PaginatedProducts, CollectionPageQuery>((ref, query) {
      final values = Uri.splitQueryString(query.filters);
      return ProductService.getProductPage(
        collectionSlug: query.slug,
        page: query.page,
        filter: ProductFilter(
          categorySlug: values['category'],
          minPrice: double.tryParse(values['min'] ?? ''),
          maxPrice: double.tryParse(values['max'] ?? ''),
          color: values['color'],
          size: values['size'],
          inStock: values['stock'] == null ? null : values['stock'] == 'true',
          sort: SortOption.values.firstWhere(
            (option) => option.name == values['sort'],
            orElse: () => SortOption.newest,
          ),
        ),
      );
    });

final filteredCollectionProductsProvider =
    FutureProvider.family<List<ProductModel>, CollectionQuery>((ref, query) {
      final values = Uri.splitQueryString(query.filters);
      return ProductService.getProducts(
        collectionSlug: query.slug,
        filter: ProductFilter(
          categorySlug: values['category'],
          minPrice: double.tryParse(values['min'] ?? ''),
          maxPrice: double.tryParse(values['max'] ?? ''),
          color: values['color'],
          size: values['size'],
          inStock: values['stock'] == null ? null : values['stock'] == 'true',
          sort: SortOption.values.firstWhere(
            (option) => option.name == values['sort'],
            orElse: () => SortOption.newest,
          ),
        ),
      );
    });

final collectionFacetsProvider = FutureProvider.family<ProductFacets, String>(
  (ref, slug) => ProductService.getFacets(collectionSlug: slug),
);

// Curated recommendations, with backend fallback for the related intent.
typedef RecommendedArgs = ({String slug, String intent});

final recommendedProvider =
    FutureProvider.family<List<ProductModel>, RecommendedArgs>((
      ref,
      args,
    ) async {
      return ProductService.getRelated(args.slug, intent: args.intent);
    });

// Cart item count helper
final cartItemCountProvider = Provider<int>((ref) => 0);

//search suggestions
class ProductSuggestion {
  final String name;
  final String slug;

  ProductSuggestion({required this.name, required this.slug});

  factory ProductSuggestion.fromJson(Map<String, dynamic> json) =>
      ProductSuggestion(
        name: json['name'] as String,
        slug: json['slug'] as String,
      );
}

// Returns suggestions for a query string; empty list if query < 2 chars
final searchSuggestionsProvider =
    FutureProvider.family<List<ProductSuggestion>, String>((ref, query) async {
      if (query.trim().length < 2) return [];
      return ProductService.getSuggestions(query.trim());
    });
