import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pebble_type/core/services/content_service.dart';
import 'package:pebble_type/feature/content/models/content_models.dart';

final pageDetailProvider = FutureProvider.family<PageModel, String>(
  (ref, slug) => ContentService.getPage(slug),
);

final pagesProvider = FutureProvider<List<PageModel>>((ref) async {
  return ContentService.getPages();
});

final articlesProvider = FutureProvider.family<List<ArticleModel>, String>((
  ref,
  blog,
) async {
  return ContentService.getArticles(blog: blog);
});

typedef ArticleArgs = ({String blog, String slug});

final articleDetailProvider = FutureProvider.family<ArticleModel?, ArticleArgs>(
  (ref, args) async {
    try {
      return await ContentService.getArticle(args.slug, blog: args.blog);
    } catch (_) {
      return null;
    }
  },
);

final collectionsIndexProvider = FutureProvider<List<CollectionSummaryModel>>((
  ref,
) async {
  return ContentService.getCollections();
});

final sizeChartProvider = FutureProvider<SizeChartModel?>((ref) async {
  try {
    return await ContentService.getSizeChart();
  } catch (_) {
    return null;
  }
});

final searchResultsProvider = FutureProvider.family<SearchResultsModel, String>(
  (ref, query) async {
    if (query.trim().isEmpty) {
      return SearchResultsModel(
        query: query,
        products: const [],
        collections: const [],
        pages: const [],
        articles: const [],
      );
    }
    return ContentService.search(query.trim());
  },
);
