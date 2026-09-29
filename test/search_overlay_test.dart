import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/providers/header_provider.dart';
import 'package:pebble_type/core/widgets/search_overlay.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

void main() {
  late ProviderContainer container;
  late GoRouter router;

  setUp(() {
    final category = CategoryModel(id: 1, name: 'T-Shirts', slug: 't-shirts', gender: 'all');
    ProductModel product(String name, String slug) => ProductModel(
      id: slug.hashCode,
      category: category,
      name: name,
      slug: slug,
      description: '',
      price: '26.00',
      compareAtPrice: null,
      sku: slug,
      badge: 'New',
      videoUrl: '',
      weight: null,
      isActive: true,
      createdAt: DateTime(2026),
      images: [],
      videoFile: '',
      variants: [],
    );
    container = ProviderContainer(overrides: [
      searchFeaturedProductsProvider.overrideWith((ref) async => [
        product('Print Tee Green', 'print-tee-green'),
        product('Floral Pant Mint', 'floral-pant-mint'),
        product('Wave Knit Top', 'wave-knit-top'),
      ]),
    ]);
    container.read(isSearchOpenProvider.notifier).state = true;
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Consumer(
            builder: (context, ref, _) => Scaffold(
              body: Stack(
                children: [
                  if (ref.watch(isSearchOpenProvider)) const SearchOverlay(),
                ],
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/search',
          builder: (_, state) => Scaffold(
            body: Text('Search results: ${state.uri.queryParameters['q']}'),
          ),
        ),
        GoRoute(
          path: '/products/:slug',
          builder: (_, state) => Scaffold(
            body: Text('Product: ${state.pathParameters['slug']}'),
          ),
        ),
      ],
    );
    addTearDown(() {
      router.dispose();
      container.dispose();
    });
  });

  testWidgets('popular search opens results and dismisses overlay', (
    tester,
  ) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pants'));
    await tester.pumpAndSettle();

    expect(find.text('Search results: Pants'), findsOneWidget);
    expect(container.read(isSearchOpenProvider), isFalse);
  });

  testWidgets('desktop dropdown shows reference cards and opens a product', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    container.read(searchAnchorProvider.notifier).state =
        const Rect.fromLTWH(1040, 18, 220, 40);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Popular Search'), findsOneWidget);
    expect(find.text('Featured Products'), findsOneWidget);
    expect(find.text('Print Tee Green'), findsOneWidget);
    expect(find.text('Floral Pant Mint'), findsOneWidget);
    expect(find.text('Wave Knit Top'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Wave Knit Top'));
    await tester.pumpAndSettle();
    expect(find.text('Product: wave-knit-top'), findsOneWidget);
    expect(container.read(isSearchOpenProvider), isFalse);
  });

  testWidgets('Escape closes search from the focused input', (tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(container.read(isSearchOpenProvider), isFalse);
    expect(find.byType(SearchOverlay), findsNothing);
  });

  testWidgets('Enter submits search on a narrow screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'T');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Search results: T'), findsOneWidget);
    expect(container.read(isSearchOpenProvider), isFalse);
    expect(tester.takeException(), isNull);
  });
}
