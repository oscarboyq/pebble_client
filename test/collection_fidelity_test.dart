import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/core/services/product_service.dart';
import 'package:pebble_type/feature/collections/pages/collection_list_page.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/providers/product_providers.dart';
import 'package:pebble_type/feature/products/widgets/product_color_swatch.dart';

void main() {
  final product = ProductModel(
    id: 1,
    category: CategoryModel(id: 1, name: 'T-Shirts', slug: 't-shirts'),
    name: 'Basic Tee',
    slug: 'basic-tee',
    description: '',
    price: '24.00',
    compareAtPrice: null,
    sku: 'BASIC',
    badge: '',
    videoUrl: '',
    videoFile: '',
    weight: null,
    isActive: true,
    createdAt: DateTime(2026),
    images: [],
    variants: [],
  );

  for (final width in [360.0, 768.0, 1280.0]) {
    testWidgets('collection filters and sort work at ${width.toInt()}px', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final requests = <CollectionPageQuery>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            collectionPageProvider.overrideWith((ref, query) async {
              requests.add(query);
              return PaginatedProducts(
                count: 1,
                page: query.page,
                pageSize: 12,
                products: [product],
              );
            }),
            collectionFacetsProvider.overrideWith(
              (ref, slug) async => const ProductFacets(
                colors: ['Navy'],
                sizes: ['2Y', '4Y'],
                maxPrice: 100,
              ),
            ),
          ],
          child: const MaterialApp(
            home: CollectionListPage(slug: 't-shirts', title: 'T-Shirts'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Basic Tee'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Sort products'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Price, low to high').last);
      await tester.pumpAndSettle();
      expect(requests.last.filters, contains('priceAsc'));

      if (width >= 900) {
        expect(find.text('2Y'), findsOneWidget);
        expect(find.text('Navy'), findsOneWidget);
        await tester.ensureVisible(find.text('Navy'));
        await tester.tap(find.text('Navy'));
        await tester.pumpAndSettle();
      } else {
        await tester.tap(find.text('Filter').first);
        await tester.pumpAndSettle();
        expect(find.text('2Y'), findsOneWidget);
        expect(find.text('Navy'), findsOneWidget);
        await tester.tap(find.text('Navy'));
        await tester.tap(find.text('Apply Filters'));
        await tester.pumpAndSettle();
      }
      expect(requests.last.filters, contains('color=Navy'));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Shop All shows collection cards and desktop filters', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          collectionPageProvider.overrideWith(
            (ref, query) async => PaginatedProducts(
              count: 1,
              page: query.page,
              pageSize: 12,
              products: [product],
            ),
          ),
          collectionFacetsProvider.overrideWith(
            (ref, slug) async => const ProductFacets(
              colors: ['Navy'],
              sizes: ['2Y'],
              maxPrice: 100,
            ),
          ),
          categoriesProvider.overrideWith(
            (ref) async => [
              CategoryModel(
                id: 2,
                name: 'Sweaters',
                slug: 'sweaters',
                productCount: 10,
              ),
              CategoryModel(
                id: 3,
                name: 'Pants',
                slug: 'pants',
                productCount: 13,
              ),
            ],
          ),
        ],
        child: const MaterialApp(home: CollectionListPage(slug: 'all')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Shop All'), findsWidgets);
    expect(find.text('Sweaters'), findsWidgets);
    expect(find.text('Availability'), findsOneWidget);
    expect(find.text('Basic Tee'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  final manyColors = [
    'Black',
    'Blue',
    'Brown',
    'Cherry',
    'Cream',
    'Cream/Brown',
    'Green',
    'Grey',
    'Mint',
    'Navy',
    'Olive',
    'Pink',
  ];
  final manySizes = [for (var index = 1; index <= 12; index++) 'Size $index'];
  final manyCategories = [
    for (var index = 1; index <= 12; index++)
      CategoryModel(
        id: index,
        name: 'Category $index',
        slug: 'category-$index',
      ),
  ];

  testWidgets('desktop color and category choices reveal after ten', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          collectionPageProvider.overrideWith(
            (ref, query) async => PaginatedProducts(
              count: 1,
              page: 1,
              pageSize: 12,
              products: [product],
            ),
          ),
          collectionFacetsProvider.overrideWith(
            (ref, slug) async => ProductFacets(
              colors: manyColors,
              sizes: manySizes,
              colorCounts: const {'Black': 2},
              sizeCounts: const {'Size 1': 5},
              maxPrice: 100,
            ),
          ),
          categoriesProvider.overrideWith((ref) async => manyCategories),
        ],
        child: const MaterialApp(home: CollectionListPage(slug: 'all')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Olive'), findsNothing);
    expect(find.text('Size 11'), findsNothing);
    expect(find.text('Category 11'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is ProductColorSwatch && widget.name == 'Cream/Brown',
      ),
      findsOneWidget,
    );
    expect(ProductColorPalette.forName('Cream/Brown'), hasLength(2));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -650));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show more (2)').first);
    await tester.pumpAndSettle();
    expect(find.text('Olive'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show more (2)').first);
    await tester.pumpAndSettle();
    expect(find.text('Size 11'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show more (2)').last);
    await tester.pumpAndSettle();
    expect(find.text('Category 11'), findsOneWidget);
    await tester.ensureVisible(find.text('Category 11'));
    await tester.tap(find.text('Category 11'));
    await tester.pumpAndSettle();
    expect(find.text('Show less'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile sheet reveals more colors and categories', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final requests = <CollectionPageQuery>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          collectionPageProvider.overrideWith((ref, query) async {
            requests.add(query);
            return PaginatedProducts(
              count: 1,
              page: 1,
              pageSize: 12,
              products: [product],
            );
          }),
          collectionFacetsProvider.overrideWith(
            (ref, slug) async => ProductFacets(
              colors: manyColors,
              sizes: manySizes,
              maxPrice: 100,
            ),
          ),
          categoriesProvider.overrideWith((ref) async => manyCategories),
        ],
        child: const MaterialApp(home: CollectionListPage(slug: 'all')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filter').first);
    await tester.pumpAndSettle();
    expect(find.text('Olive'), findsNothing);
    expect(find.text('Size 11'), findsNothing);
    expect(find.text('Category 11'), findsNothing);
    await tester.ensureVisible(find.text('Show more sizes (2)'));
    await tester.tap(find.text('Show more sizes (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Size 11'), findsOneWidget);
    await tester.ensureVisible(find.text('Show more colors (2)'));
    await tester.tap(find.text('Show more colors (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Olive'), findsOneWidget);
    await tester.ensureVisible(find.text('Show more categories (2)'));
    await tester.tap(find.text('Show more categories (2)'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Category 11'));
    await tester.tap(find.text('Category 11'));
    await tester.ensureVisible(find.text('Apply Filters'));
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();
    expect(requests.last.filters, contains('category=category-11'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Shop All prefetches the next page before scrolling', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final requested = <int>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          collectionPageProvider.overrideWith((ref, query) async {
            requested.add(query.page);
            return PaginatedProducts(
              count: 13,
              page: query.page,
              pageSize: 12,
              products: query.page == 1
                  ? List<ProductModel>.filled(12, product)
                  : [product],
            );
          }),
          collectionFacetsProvider.overrideWith(
            (ref, slug) async =>
                const ProductFacets(colors: [], sizes: [], maxPrice: 100),
          ),
          categoriesProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: CollectionListPage(slug: 'all')),
      ),
    );
    await tester.pumpAndSettle();
    expect(requested, [1, 2]);
    expect(find.text('13 products'), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1800));
    await tester.pumpAndSettle();
    expect(requested, [1, 2]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dragging desktop price handles waits until release to query', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1280, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final requested = <CollectionPageQuery>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          collectionPageProvider.overrideWith((ref, query) async {
            requested.add(query);
            return PaginatedProducts(
              count: 1,
              page: query.page,
              pageSize: 12,
              products: [product],
            );
          }),
          collectionFacetsProvider.overrideWith(
            (ref, slug) async =>
                const ProductFacets(colors: [], sizes: [], maxPrice: 100),
          ),
        ],
        child: const MaterialApp(home: CollectionListPage(slug: 't-shirts')),
      ),
    );
    await tester.pumpAndSettle();
    final slider = find.byType(RangeSlider);
    await tester.ensureVisible(slider);
    final rect = tester.getRect(slider);
    final gesture = await tester.startGesture(
      Offset(rect.right - 25, rect.center.dy),
    );
    await gesture.moveBy(const Offset(-40, 0));
    await tester.pump();
    expect(requested.length, 1);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(requested.length, 2);
    expect(requested.last.filters, contains('max='));
  });
}
