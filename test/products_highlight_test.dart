import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/widgets/products_highlight_section.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

void main() {
  group('ProductsHighlightSection Widget Tests', () {
    final mockProduct1 = ProductModel(
      id: 101,
      category: CategoryModel(id: 1, name: 'Hoodies', slug: 'hoodies'),
      name: 'Fleece Hoodie Kids',
      slug: 'fleece-hoodie-kids',
      description: 'Super soft fleece hoodie',
      price: '36.00',
      compareAtPrice: null,
      sku: 'FHK-01',
      badge: '',
      videoFile: '',
      videoUrl: '',
      weight: null,
      isActive: true,
      createdAt: DateTime.now(),
      images: [
        ProductImageModel(
          id: 1,
          image: 'https://example.com/hoodie-green.jpg',
          altText: 'Fleece Hoodie Kids Forest Green',
          isPrimary: true,
          order: 0,
        ),
        ProductImageModel(
          id: 2,
          image: 'https://example.com/hoodie-pink.jpg',
          altText: 'Fleece Hoodie Kids Dusty Rose',
          isPrimary: false,
          order: 1,
        ),
      ],
      variants: [],
      material: 'Fleece',
      specialFeatures: 'Warm',
      careAndCleaning: 'Machine wash',
      manufacturedBy: 'Pebble',
    );

    final mockProduct2 = ProductModel(
      id: 102,
      category: CategoryModel(id: 2, name: 'Pants', slug: 'pants'),
      name: 'Fleece Jogger Pants',
      slug: 'fleece-jogger-pants',
      description: 'Comfortable jogger pants',
      price: '23.00',
      compareAtPrice: null,
      sku: 'FJP-01',
      badge: '',
      videoFile: '',
      videoUrl: '',
      weight: null,
      isActive: true,
      createdAt: DateTime.now(),
      images: [
        ProductImageModel(
          id: 3,
          image: 'https://example.com/pants-green.jpg',
          altText: 'Fleece Jogger Pants Forest Green',
          isPrimary: true,
          order: 0,
        ),
        ProductImageModel(
          id: 4,
          image: 'https://example.com/pants-pink.jpg',
          altText: 'Fleece Jogger Pants Dusty Rose',
          isPrimary: false,
          order: 1,
        ),
      ],
      variants: [],
      material: 'Fleece',
      specialFeatures: 'Elastic waist',
      careAndCleaning: 'Machine wash',
      manufacturedBy: 'Pebble',
    );

    final mockHighlight = ProductsHighlightModel(
      id: 1,
      tag: 'HOT ITEMS',
      heading: 'Shop The Winter Set',
      description: 'Explore the softest fleece hoodies and joggers made for all-day comfort.',
      buttonText: 'Shop now',
      buttonLink: '/collections/winter-set',
      bannerImage: 'https://example.com/banner.webp',
      videoUrl: 'https://example.com/video.mp4',
      videoPoster: 'https://example.com/poster.jpg',
      carouselProducts: [mockProduct1, mockProduct2],
    );

    testWidgets('renders header, copy, and shop now pill button', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProductsHighlightSection(highlight: mockHighlight),
              ),
            ),
          ),
        ),
      );

      // Tag
      expect(find.text('HOT ITEMS'), findsOneWidget);

      // Heading
      expect(find.text('Shop The Winter Set'), findsOneWidget);

      // Description
      expect(
        find.text('Explore the softest fleece hoodies and joggers made for all-day comfort.'),
        findsOneWidget,
      );

      // Button
      expect(find.text('Shop now'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('renders initial product and navigates between slides with arrows',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProductsHighlightSection(highlight: mockHighlight),
              ),
            ),
          ),
        ),
      );

      // Initially product 1 is visible
      expect(find.text('Fleece Hoodie Kids'), findsOneWidget);
      expect(find.text('\$36.00'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);

      // Tap Next arrow
      await tester.tap(find.byIcon(Icons.chevron_right).last);
      await tester.pumpAndSettle();

      // Slide 2 is now active
      expect(find.text('Fleece Jogger Pants'), findsOneWidget);
      expect(find.text('\$23.00'), findsOneWidget);
      expect(find.text('2 / 2'), findsOneWidget);

      // Tap Prev arrow
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Back to Slide 1
      expect(find.text('Fleece Hoodie Kids'), findsOneWidget);
      expect(find.text('\$36.00'), findsOneWidget);
      expect(find.text('1 / 2'), findsOneWidget);
    });

    testWidgets('renders mobile layout seamlessly without overflow', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProductsHighlightSection(highlight: mockHighlight),
              ),
            ),
          ),
        ),
      );

      expect(find.text('HOT ITEMS'), findsOneWidget);
      expect(find.text('Shop The Winter Set'), findsOneWidget);
      expect(find.text('Fleece Hoodie Kids'), findsOneWidget);
    });
  });
}
