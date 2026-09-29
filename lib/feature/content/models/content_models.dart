import 'package:pebble_type/core/config/api_config.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

class PageModel {
  final int id;
  final String title;
  final String slug;
  final String body;

  PageModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.body,
  });

  factory PageModel.fromJson(Map<String, dynamic> json) => PageModel(
        id: json['id'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );
}

class ArticleModel {
  final int id;
  final String blogHandle;
  final String title;
  final String slug;
  final String excerpt;
  final String? body;
  final String? coverImage;
  final String authorName;
  final DateTime? publishedAt;

  ArticleModel({
    required this.id,
    required this.blogHandle,
    required this.title,
    required this.slug,
    required this.excerpt,
    this.body,
    this.coverImage,
    required this.authorName,
    this.publishedAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) => ArticleModel(
        id: json['id'] as int? ?? 0,
        blogHandle: json['blog_handle'] as String? ?? 'news',
        title: json['title'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        excerpt: json['excerpt'] as String? ?? '',
        body: json['body'] as String?,
        coverImage: ApiConfig.resolveImageUrlNullable(json['cover_image'] as String?),
        authorName: json['author_name'] as String? ?? '',
        publishedAt: json['published_at'] != null
            ? DateTime.tryParse(json['published_at'].toString())
            : null,
      );
}

class CollectionSummaryModel {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String? image;
  final bool isFeatured;
  final int productCount;

  CollectionSummaryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    this.image,
    required this.isFeatured,
    required this.productCount,
  });

  factory CollectionSummaryModel.fromJson(Map<String, dynamic> json) =>
      CollectionSummaryModel(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        slug: json['slug'] as String? ?? '',
        description: json['description'] as String? ?? '',
        image: ApiConfig.resolveImageUrlNullable(json['image'] as String?),
        isFeatured: json['is_featured'] as bool? ?? false,
        productCount: (json['product_count'] as num?)?.toInt() ?? 0,
      );
}

class SizeChartModel {
  final String name;
  final List<String> columns;
  final List<List<String>> rows;
  final String note;
  final String? image;

  SizeChartModel({
    required this.name,
    required this.columns,
    required this.rows,
    required this.note,
    this.image,
  });

  factory SizeChartModel.fromJson(Map<String, dynamic> json) => SizeChartModel(
        name: json['name'] as String? ?? 'Size chart',
        columns: (json['columns'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        rows: (json['rows'] as List? ?? const [])
            .map((row) => (row as List).map((e) => e.toString()).toList())
            .toList(),
        note: json['note'] as String? ?? '',
        image: ApiConfig.resolveImageUrlNullable(json['image'] as String?),
      );
}

class SearchResultsModel {
  final String query;
  final List<ProductModel> products;
  final List<CollectionSummaryModel> collections;
  final List<PageModel> pages;
  final List<ArticleModel> articles;

  SearchResultsModel({
    required this.query,
    required this.products,
    required this.collections,
    required this.pages,
    required this.articles,
  });

  factory SearchResultsModel.fromJson(Map<String, dynamic> json) =>
      SearchResultsModel(
        query: json['query'] as String? ?? '',
        products: (json['products'] as List? ?? const [])
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        collections: (json['collections'] as List? ?? const [])
            .map((e) => CollectionSummaryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        pages: (json['pages'] as List? ?? const [])
            .map((e) => PageModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        articles: (json['articles'] as List? ?? const [])
            .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
