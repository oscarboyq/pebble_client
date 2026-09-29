import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/widgets/new_in_showcase_section.dart';

void main() {
  testWidgets('sticky Shop Now remains tappable after scrolling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final cards = List.generate(
      6,
      (index) => ShowcaseCardModel(
        id: index + 1,
        title: 'Item $index',
        price: 44,
        lifestyleImage: '',
        thumbnailImage: '',
        productLink: '/products/item-$index',
        order: index,
      ),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: RepaintBoundary(
                    child: NewInShowcaseSection(
                      cards: cards,
                      ctaLink: '/collections/outerwear',
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 900)),
              ],
            ),
          ),
        ),
        GoRoute(
          path: '/collections/outerwear',
          builder: (_, _) => const Scaffold(body: Text('Outerwear collection')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pumpAndSettle();
    final buttonCenter = tester.getCenter(find.text('Shop Now'));
    expect(buttonCenter.dy, inInclusiveRange(0, 900));
    await tester.tap(find.text('Shop Now'));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      '/collections/outerwear',
    );
  });

  testWidgets('Shop Now opens the configured Outerwear collection', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: SingleChildScrollView(
              child: NewInShowcaseSection(
                cards: [
                  ShowcaseCardModel(
                    id: 1,
                    title: 'Jacket',
                    price: 44,
                    lifestyleImage: '',
                    thumbnailImage: '',
                    productLink: '/products/jacket',
                    order: 0,
                  ),
                ],
                ctaLink: '/collections/outerwear',
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/collections/outerwear',
          builder: (_, _) => const Scaffold(body: Text('Outerwear collection')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Shop Now'));
    await tester.pumpAndSettle();
    expect(
      router.routeInformationProvider.value.uri.path,
      '/collections/outerwear',
    );
    expect(find.text('Outerwear collection'), findsOneWidget);
  });

  testWidgets('NewInShowcaseSection renders center headline and cards', (
    tester,
  ) async {
    final sampleCards = [
      ShowcaseCardModel(
        id: 1,
        title: 'Stripe Shorts',
        price: 24.00,
        lifestyleImage: '',
        thumbnailImage: '',
        productLink: '/products/stripe-shorts',
        order: 1,
      ),
      ShowcaseCardModel(
        id: 2,
        title: 'Colorblock Jacket',
        price: 44.00,
        lifestyleImage: '',
        thumbnailImage: '',
        productLink: '/products/colorblock-jacket',
        order: 2,
      ),
      ShowcaseCardModel(
        id: 3,
        title: 'Sneakers Green',
        price: 60.00,
        lifestyleImage: '',
        thumbnailImage: '',
        productLink: '/products/sneakers-green',
        order: 3,
      ),
    ];

    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NewInShowcaseSection(cards: sampleCards),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify "NEW IN" and "Shop Now"
    expect(find.text('NEW IN'), findsOneWidget);
    expect(find.text('Shop Now'), findsOneWidget);
    expect(find.text('Stripe Shorts'), findsOneWidget);
    expect(find.text(r'$24.00'), findsOneWidget);
    expect(find.text('Colorblock Jacket'), findsOneWidget);
    expect(find.text(r'$44.00'), findsOneWidget);
  });
}
