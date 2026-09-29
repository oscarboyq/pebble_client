import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/services/product_service.dart';
import 'package:pebble_type/feature/collections/pages/collection_list_page.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/pages/home_page.dart';
import 'package:pebble_type/feature/home/providers/home_provider.dart';
import 'package:pebble_type/feature/home/widgets/animated_arrow_pill.dart';
import 'package:pebble_type/feature/products/providers/product_providers.dart';

void main() {
  testWidgets('Shop Collection opens the configured collection from home', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final data = HomePageData(
      banners: [
        BannerSlideModel(
          id: 1,
          title: 'Softness in Comfort',
          subtitle: 'New Campaign',
          image: '',
          ctaText: 'Shop Collection',
          ctaLink: '/collections/all',
          order: 0,
        ),
      ],
      featuredCategories: const [],
      newArrivals: const [],
      bestSellers: const [],
      shopMenu: ShopMenuModel.fromJson(null),
      collectionsMenu: CollectionsMenuModel.fromJson(null),
    );
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomePage()),
        GoRoute(
          path: '/collections/all',
          builder: (_, _) => const CollectionListPage(slug: 'all'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeProvider.overrideWith(() => _HomeWithBanner(data)),
          categoriesProvider.overrideWith((ref) async => []),
          collectionPageProvider.overrideWith(
            (ref, query) async => PaginatedProducts(
              count: 0,
              page: query.page,
              pageSize: 12,
              products: const [],
            ),
          ),
          collectionFacetsProvider.overrideWith(
            (ref, slug) async =>
                const ProductFacets(colors: [], sizes: [], maxPrice: 100),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.tap(find.byType(AnimatedArrowPill));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/collections/all');
    expect(find.text('Shop All'), findsWidgets);
  });

  testWidgets('hover expands the arrow segment and runs arrow motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AnimatedArrowPill(
              label: 'Shop Collection',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );
    final fill = find.byKey(const ValueKey('hero-cta-fill'));
    expect(tester.getSize(fill).width, closeTo(30, 1));
    final arrow = find.byIcon(Icons.chevron_right_rounded);
    final restingArrowX = tester.getTopLeft(arrow).dx;
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(0, 0));
    await mouse.moveTo(tester.getCenter(find.byType(AnimatedArrowPill)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    expect(tester.getSize(fill).width, greaterThan(150));
    final movingArrowX = tester.getTopLeft(arrow).dx;
    expect(movingArrowX, lessThan(restingArrowX));
    await tester.pump(const Duration(milliseconds: 250));
    expect(tester.getTopLeft(arrow).dx, greaterThan(movingArrowX));
    await mouse.removePointer();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 450));
    expect(tester.getSize(fill).width, closeTo(30, 1));
  });
}

class _HomeWithBanner extends HomeNotifier {
  final HomePageData data;
  _HomeWithBanner(this.data);

  @override
  Future<HomePageData> build() async => data;
}
