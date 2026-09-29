import 'package:pebble_type/core/services/api_client.dart';
import 'package:pebble_type/feature/content/models/content_models.dart';

class ContentService {
  static Future<List<PageModel>> getPages() async {
    final response = await ApiClient.dio.get('pages/');
    final List data = response.data as List;
    return data
        .map((e) => PageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<PageModel> getPage(String slug) async {
    final response = await ApiClient.dio.get('pages/$slug/');
    return PageModel.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<List<ArticleModel>> getArticles({String blog = 'news'}) async {
    final response = await ApiClient.dio.get('blogs/$blog/');
    final List data = response.data as List;
    return data
        .map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<ArticleModel> getArticle(String slug, {String blog = 'news'}) async {
    final response = await ApiClient.dio.get('blogs/$blog/$slug/');
    return ArticleModel.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<SearchResultsModel> search(String query) async {
    final response = await ApiClient.dio.get(
      'search/',
      queryParameters: {'q': query},
    );
    return SearchResultsModel.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<SizeChartModel?> getSizeChart() async {
    final response = await ApiClient.dio.get('products/size-chart/');
    if (response.data == null) return null;
    return SizeChartModel.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<List<CollectionSummaryModel>> getCollections({
    bool featuredOnly = false,
  }) async {
    final response = await ApiClient.dio.get(
      'collections/',
      queryParameters: featuredOnly ? {'featured': 'true'} : null,
    );
    final List data = response.data as List;
    return data
        .map((e) => CollectionSummaryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
