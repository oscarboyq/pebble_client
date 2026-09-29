import 'package:pebble_type/core/services/api_client.dart';
import 'package:pebble_type/feature/products/models/filter_model.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/providers/product_providers.dart';

class ProductService {
  static Future<PaginatedProducts> getProductPage({
    required String collectionSlug,
    required int page,
    int pageSize = 12,
    ProductFilter? filter,
  }) async {
    final queryParams = <String, dynamic>{
      'collection': collectionSlug,
      'page': page,
      'page_size': pageSize,
    };
    _addFilterParameters(queryParams, filter);
    final response = await ApiClient.dio.get(
      'products/',
      queryParameters: queryParams,
    );
    final data = response.data as Map<String, dynamic>;
    return PaginatedProducts(
      count: (data['count'] as num).toInt(),
      page: (data['page'] as num).toInt(),
      pageSize: (data['page_size'] as num).toInt(),
      products: (data['results'] as List)
          .map((entry) => ProductModel.fromJson(entry as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<List<ProductModel>> getProducts({
    String? search,
    ProductFilter? filter,
    String? collectionSlug,
  }) async {
    final queryParams = <String, dynamic>{};

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (collectionSlug != null && collectionSlug.isNotEmpty) {
      queryParams['collection'] = collectionSlug;
    }

    _addFilterParameters(queryParams, filter);

    final response = await ApiClient.dio.get(
      'products/',
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    final List data = response.data as List;
    return data
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static void _addFilterParameters(
    Map<String, dynamic> queryParams,
    ProductFilter? filter,
  ) {
    if (filter != null) {
      if (filter.categorySlug != null && filter.categorySlug!.isNotEmpty) {
        queryParams['category'] = filter.categorySlug;
      }
      if (filter.productType != null && filter.productType!.isNotEmpty) {
        queryParams['product_type'] = filter.productType;
      }
      if (filter.minPrice != null) {
        queryParams['min_price'] = filter.minPrice.toString();
      }
      if (filter.maxPrice != null) {
        queryParams['max_price'] = filter.maxPrice.toString();
      }
      if (filter.color != null && filter.color!.isNotEmpty) {
        queryParams['color'] = filter.color;
      }
      if (filter.size != null && filter.size!.isNotEmpty) {
        queryParams['size'] = filter.size;
      }
      if (filter.inStock != null) {
        queryParams['in_stock'] = filter.inStock! ? 'true' : 'false';
      }
      if (filter.gender != null && filter.gender!.isNotEmpty) {
        queryParams['gender'] = filter.gender;
      }
      if (filter.sale == true) {
        queryParams['sale'] = 'true';
      }
      if (filter.sort != SortOption.newest) {
        queryParams['sort'] = filter.sort.apiValue;
      }
    }
  }

  static Future<ProductModel> getProduct(String slug) async {
    final response = await ApiClient.dio.get('products/$slug/');
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<List<CategoryModel>> getCategories() async {
    final response = await ApiClient.dio.get('products/categories/');
    final List data = response.data as List;

    return data
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<ProductModel>> getRelated(
    String slug, {
    String intent = 'related',
  }) async {
    final response = await ApiClient.dio.get(
      'products/$slug/related/',
      queryParameters: {'intent': intent},
    );
    final List data =
        (response.data as Map<String, dynamic>)['products'] as List;
    return data
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<ProductFacets> getFacets({
    String? collectionSlug,
    ProductFilter? filter,
  }) async {
    final query = <String, dynamic>{};
    if (collectionSlug != null) query['collection'] = collectionSlug;
    _addFilterParameters(query, filter);
    final response = await ApiClient.dio.get(
      'products/facets/',
      queryParameters: query.isEmpty ? null : query,
    );
    return ProductFacets.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<List<ProductSuggestion>> getSuggestions(String query) async {
    final response = await ApiClient.dio.get(
      'products/suggestions/',
      queryParameters: {'q': query},
    );
    final List data = response.data as List;
    return data
        .map((e) => ProductSuggestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class PaginatedProducts {
  final int count;
  final int page;
  final int pageSize;
  final List<ProductModel> products;

  const PaginatedProducts({
    required this.count,
    required this.page,
    required this.pageSize,
    required this.products,
  });
}

class ProductFacets {
  final List<String> colors;
  final List<String> sizes;
  final Map<String, int> colorCounts;
  final Map<String, int> sizeCounts;
  final Map<String, int> categoryCounts;
  final List<String> productTypes;
  final Map<String, int> productTypeCounts;
  final Map<String, int> availabilityCounts;
  final double maxPrice;

  const ProductFacets({
    required this.colors,
    required this.sizes,
    this.colorCounts = const {},
    this.sizeCounts = const {},
    this.categoryCounts = const {},
    this.productTypes = const [],
    this.productTypeCounts = const {},
    this.availabilityCounts = const {},
    required this.maxPrice,
  });

  factory ProductFacets.fromJson(Map<String, dynamic> json) {
    List<String> values(String key) => (json[key] as List? ?? const [])
        .map((entry) => (entry as Map<String, dynamic>)['value'].toString())
        .toList();
    Map<String, int> counts(String key) => {
      for (final raw in (json[key] as List? ?? const []))
        if (raw is Map && raw['value'] != null)
          raw['value'].toString(): (raw['count'] as num?)?.toInt() ?? 0,
    };
    final price = json['price'] as Map<String, dynamic>? ?? const {};
    return ProductFacets(
      colors: values('colors'),
      sizes: values('sizes'),
      colorCounts: counts('colors'),
      sizeCounts: counts('sizes'),
      categoryCounts: counts('categories'),
      productTypes: values('product_types'),
      productTypeCounts: counts('product_types'),
      availabilityCounts: counts('availability'),
      maxPrice: (price['max'] as num?)?.toDouble() ?? 500,
    );
  }
}
