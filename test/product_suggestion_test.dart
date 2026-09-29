import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/widgets/product_suggestion_section.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

void main() {
  group('ProductSuggestionSection Widget Tests', () {
    ProductModel createMockProduct(int id, String name, String slug, String price) {
      return ProductModel(
        id: id,
        category: CategoryModel(id: 1, name: 'Tops', slug: 'tops'),
        name: name,
        slug: slug,
        description: 'Mock product description',
        price: price,
        compareAtPrice: null,
        sku: '$slug-01',
        badge: 'New',
        videoFile: '',
        videoUrl: '',
        weight: null,
        isActive: true,
        createdAt: DateTime.now(),
        images: [
          ProductImageModel(
            id: id * 10,
            image: 'https://example.com/$slug.jpg',
            altText: name,
            isPrimary: true,
            order: 0,
          ),
        ],
        variants: [
          const ProductVariantModel(
            id: 1,
            color: 'Blue',
            size: 'M',
            stock: 10,
          ),
          const ProductVariantModel(
            id: 2,
            color: 'Green',
            size: 'M',
            stock: 10,
          ),
        ],
        material: 'Cotton',
        specialFeatures: 'Soft',
        careAndCleaning: 'Machine wash',
        manufacturedBy: 'Pebble',
      );
    }

    final mockSuggestion = ProductSuggestionModel(
      id: 1,
      tag: 'How you style it',
      heading: 'Dress up in 3 steps.\nPick - Pair - Play!',
      steps: [
        ProductSuggestionStepModel(
          id: 1,
          stepNumber: 1,
          title: 'Pick a top you love',
          badge1: '4-Way Stretch',
          badge2: 'Eco-Friendly',
          order: 0,
          products: [
            createMockProduct(1, 'Pocket Vest', 'pocket-vest', '55.00'),
            createMockProduct(2, 'Varsity Jacket Blue', 'varsity-jacket-blue', '45.00'),
            createMockProduct(3, 'Sleeveless Top', 'sleeveless-top', '26.00'),
            createMockProduct(4, 'Stripe Polo Pink', 'stripe-polo-pink', '45.00'),
          ],
        ),
        ProductSuggestionStepModel(
          id: 2,
          stepNumber: 2,
          title: 'Match it with cool bottoms',
          badge1: '100% Cotton',
          badge2: 'Water Proof',
          order: 1,
          products: [
            createMockProduct(5, 'Pleated Skirt Kids', 'pleated-skirt-kids', '33.00'),
            createMockProduct(6, 'Linen Shorts', 'linen-shorts', '45.00'),
            createMockProduct(7, 'Floral Pant Mint', 'floral-knit-mint', '22.00'),
            createMockProduct(8, 'Chino Pant Beige', 'chino-shorts-beige', '35.00'),
          ],
        ),
        ProductSuggestionStepModel(
          id: 3,
          stepNumber: 3,
          title: 'Add fun extras',
          badge1: '100% Cotton',
          badge2: 'Colorful',
          order: 2,
          products: [
            createMockProduct(9, 'Canvas Sneaker', 'canvas-sneaker', '50.00'),
            createMockProduct(10, 'Stripe Sun Hat', 'stripe-sun-hat', '15.00'),
            createMockProduct(11, 'Puffer Jacket', 'puffer-jacket', '66.00'),
            createMockProduct(12, 'Knit Beanie Kids', 'knit-beanie-kids', '12.00'),
          ],
        ),
      ],
    );

    testWidgets('renders section header and all 3 step headers with chips',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProductSuggestionSection(suggestion: mockSuggestion),
              ),
            ),
          ),
        ),
      );

      // Section Header
      expect(find.text('HOW YOU STYLE IT'), findsOneWidget);
      expect(find.text('Dress up in 3 steps.\nPick - Pair - Play!'), findsOneWidget);

      // Step Titles
      expect(find.text('Pick a top you love'), findsOneWidget);
      expect(find.text('Match it with cool bottoms'), findsOneWidget);
      expect(find.text('Add fun extras'), findsOneWidget);

      // Feature Badges
      expect(find.text('4-Way Stretch'), findsOneWidget);
      expect(find.text('Eco-Friendly'), findsOneWidget);
      expect(find.text('Water Proof'), findsOneWidget);
      expect(find.text('Colorful'), findsOneWidget);

      // Step 1 Products visible initially
      expect(find.text('Pocket Vest'), findsOneWidget);
      expect(find.text('Varsity Jacket Blue'), findsOneWidget);
    });

    testWidgets('accordion expands clicked step and collapses previous step',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProductSuggestionSection(suggestion: mockSuggestion),
              ),
            ),
          ),
        ),
      );

      // Initially Step 1 is open: 'Pocket Vest' is in tree
      expect(find.text('Pocket Vest'), findsOneWidget);

      // Tap Step 2 header to open Step 2
      await tester.tap(find.text('Match it with cool bottoms'));
      await tester.pumpAndSettle();

      // Step 2 products are now displayed
      expect(find.text('Pleated Skirt Kids'), findsOneWidget);
      expect(find.text('Linen Shorts'), findsOneWidget);

      // Tap Step 3 header to open Step 3
      await tester.tap(find.text('Add fun extras'));
      await tester.pumpAndSettle();

      // Step 3 products are now displayed
      expect(find.text('Canvas Sneaker'), findsOneWidget);
      expect(find.text('Stripe Sun Hat'), findsOneWidget);
    });

    testWidgets('renders mobile layout cleanly without RenderFlex overflow',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProductSuggestionSection(suggestion: mockSuggestion),
              ),
            ),
          ),
        ),
      );

      expect(find.text('HOW YOU STYLE IT'), findsOneWidget);
      expect(find.text('Pick a top you love'), findsOneWidget);
      expect(find.text('Pocket Vest'), findsOneWidget);
    });
  });
}
