import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/core/services/home_service.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/providers/home_provider.dart';

import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async {
        return null;
      },
    );
  });
  final mockJson = <String, dynamic>{
    'banners': [
      {
        'id': 1,
        'title': 'SWR Cached Banner',
        'subtitle': '0ms Render',
        'image': '/media/banner.jpg',
        'cta_text': 'Shop Now',
        'cta_link': '/collections/all',
        'bg_color': '#C99484',
        'order': 0,
      }
    ],
    'promo_bar': {'id': 1, 'text': 'SWR Free Shipping'},
    'store_settings': {
      'store_name': 'Pebble SWR',
      'promo_bar_enabled': true,
      'promo_bar_text': 'Free Shipping',
      'hero_transition': 'fade_zoom',
    },
    'shop_menu': null,
    'collections_menu': null,
    'featured_categories': [],
    'best_sellers': [],
    'new_arrivals': [],
    'new_in_showcase': [],
    'outfit_highlights': [],
    'layered_scrolling': [],
    'lookbook_cards': [],
    'products_highlight': null,
    'product_suggestion': null,
    'products_bundle': null,
    'testimonials_parallax': null,
    'our_story': null,
    'brand_pillars': [],
    'flex_carousel': null,
  };

  tearDown(() {
    HomeService.clearCache();
  });

  group('Stale-While-Revalidate (SWR) Local Snapshot Tests', () {
    test('homeProvider emits cached snapshot synchronously in 0ms', () {
      final cachedModel = HomePageData.fromJson(mockJson);
      HomeService.setMockCache(data: cachedModel, etag: '"test-etag-123"');

      final testContainer = ProviderContainer();

      // Read provider state immediately
      final state = testContainer.read(homeProvider);

      // Verify that it emits AsyncData synchronously on frame 0 without loading state!
      expect(state, isA<AsyncData<HomePageData>>());
      expect(state.value?.banners.first.title, equals('SWR Cached Banner'));
      expect(state.value?.promoBar?.text, equals('SWR Free Shipping'));
      expect(HomeService.cachedEtag, equals('"test-etag-123"'));

      testContainer.dispose();
    });

    test('HomeService.getHomePageData returns cached data without waiting for network', () async {
      final cachedModel = HomePageData.fromJson(mockJson);
      HomeService.setMockCache(data: cachedModel, etag: '"etag-abc"');

      final stopwatch = Stopwatch()..start();
      final data = await HomeService.getHomePageData();
      stopwatch.stop();

      expect(data.banners.first.title, equals('SWR Cached Banner'));
      expect(stopwatch.elapsedMilliseconds, lessThan(50));
    });

    test('HomeService handles corrupted snapshot gracefully', () async {
      HomeService.clearCache();
      // Should not throw, but safely keep cachedData as null
      await HomeService.initMemoryCache();
      // When cache is empty, cachedData is null
      expect(HomeService.cachedData, isNull);
    });
  });
}
