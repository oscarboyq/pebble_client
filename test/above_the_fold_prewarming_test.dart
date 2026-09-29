import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/core/services/home_service.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/pages/home_page.dart';
import 'package:pebble_type/feature/home/providers/home_provider.dart';
import 'package:pebble_type/feature/home/widgets/banner_slider.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockData = HomePageData(
    banners: [
      BannerSlideModel(
        id: 1,
        title: 'Prewarmed Hero Banner',
        subtitle: 'Sub',
        image: 'https://cdn.example.com/banner1.webp',
        ctaText: 'Shop',
        ctaLink: '/collections/all',
        order: 0,
      ),
      BannerSlideModel(
        id: 2,
        title: 'Second Banner',
        subtitle: 'Sub 2',
        image: 'https://cdn.example.com/banner2.webp',
        ctaText: 'Explore',
        ctaLink: '/collections/all',
        order: 1,
      ),
    ],
    promoBar: PromoBarModel(id: 1, text: 'Special Promo'),
    storeSettings: StoreSettingsModel(
      storeName: 'Pebble Prewarm',
      contactEmail: 'test@example.com',
      logo: 'https://cdn.example.com/logo.webp',
    ),
    featuredCategories: [
      CategoryModel(
        id: 10,
        name: 'Outerwear',
        slug: 'outerwear',
        gender: 'boys',
        productCount: 5,
        image: 'https://cdn.example.com/cat1.webp',
      ),
      CategoryModel(
        id: 11,
        name: 'Sweaters',
        slug: 'sweaters',
        gender: 'boys',
        productCount: 8,
        image: 'https://cdn.example.com/cat2.webp',
      ),
    ],
    bestSellers: const [],
    newArrivals: const [],
    newInShowcase: const [],
    outfitHighlights: const [],
    layeredCards: const [],
    lookbookCards: const [],
    brandPillars: const [],
    shopMenu: ShopMenuModel.fromJson(null),
    collectionsMenu: CollectionsMenuModel.fromJson(null),
  );

  tearDown(() {
    HomeService.clearCache();
  });

  group('Above-the-Fold Image Pre-warming Tests', () {
    for (final width in [360.0, 768.0, 1280.0]) {
      testWidgets('home hero fits at ${width.toInt()}px', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              homeProvider.overrideWith(() => _MockHomeNotifier(mockData)),
            ],
            child: const MaterialApp(home: HomePage()),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.text('Prewarmed Hero Banner'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pump(const Duration(seconds: 4));
      });
    }
    testWidgets(
      'HomePage mounts and pre-warms hero banners and category images without crash',
      (tester) async {
        HomeService.setMockCache(data: mockData, etag: '"etag-prewarm"');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              homeProvider.overrideWith(() => _MockHomeNotifier(mockData)),
            ],
            child: const MaterialApp(home: HomePage()),
          ),
        );

        // Verify HomePage mounts successfully with cached data
        expect(find.byType(HomePage), findsOneWidget);
        expect(find.text('Prewarmed Hero Banner'), findsOneWidget);

        // Verify second pump does not cause errors or re-entrant precache crashes
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Prewarmed Hero Banner'), findsOneWidget);

        // Drain any pending promo delay timers
        await tester.pump(const Duration(seconds: 4));
      },
    );

    testWidgets(
      'BannerSlider pre-warms all banner images upon mounting without error',
      (tester) async {
        final banners = [
          BannerSlideModel(
            id: 1,
            title: 'Slide 1',
            subtitle: 'Sub 1',
            image: 'https://cdn.example.com/slide1.webp',
            ctaText: 'Shop',
            ctaLink: '/link1',
            order: 0,
          ),
          BannerSlideModel(
            id: 2,
            title: 'Slide 2',
            subtitle: 'Sub 2',
            image: 'https://cdn.example.com/slide2.webp',
            ctaText: 'Shop',
            ctaLink: '/link2',
            order: 1,
          ),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BannerSlider(banners: banners, isActive: true),
            ),
          ),
        );

        expect(find.byType(BannerSlider), findsOneWidget);
        expect(find.text('1 / 2'), findsOneWidget);

        await tester.pump(const Duration(milliseconds: 200));
      },
    );
  });
}

class _MockHomeNotifier extends HomeNotifier {
  final HomePageData _initialData;
  _MockHomeNotifier(this._initialData);

  @override
  HomePageData build() => _initialData;
}
