import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/widgets/products_bundle_section.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

void main() {
  group('ProductsBundleSection Widget Tests', () {
    final mockProduct1 = ProductModel(
      id: 201,
      category: CategoryModel(id: 1, name: 'Tanks', slug: 'tanks'),
      name: 'Crochet Tank Mint',
      slug: 'crochet-tank-mint',
      description: 'Elegant crochet tank in refreshing mint',
      price: '45.00',
      compareAtPrice: null,
      sku: 'CTM-01',
      badge: '',
      videoFile: '',
      videoUrl: '',
      weight: null,
      isActive: true,
      createdAt: DateTime.now(),
      images: [
        ProductImageModel(
          id: 2011,
          image: 'https://example.com/crochet-1.jpg',
          altText: 'Crochet Tank Mint Photo 1',
          isPrimary: true,
          order: 0,
        ),
      ],
      variants: [
        const ProductVariantModel(id: 1, color: 'Mint', size: '3Y', stock: 10),
        const ProductVariantModel(id: 2, color: 'Mint', size: '4Y', stock: 10),
        const ProductVariantModel(id: 3, color: 'Mint', size: '5Y', stock: 10),
      ],
      material: 'Cotton',
      specialFeatures: 'Breathable',
      careAndCleaning: 'Hand wash',
      manufacturedBy: 'Pebble',
    );

    final mockProduct2 = ProductModel(
      id: 202,
      category: CategoryModel(id: 2, name: 'Pants', slug: 'pants'),
      name: 'Floral Pant Mint',
      slug: 'floral-knit-mint',
      description: 'Comfortable floral pants',
      price: '22.00',
      compareAtPrice: '32.00',
      sku: 'FPM-01',
      badge: 'Sale',
      videoFile: '',
      videoUrl: '',
      weight: null,
      isActive: true,
      createdAt: DateTime.now(),
      images: [
        ProductImageModel(
          id: 2021,
          image: 'https://example.com/floral-1.jpg',
          altText: 'Floral Pant Mint Photo 1',
          isPrimary: true,
          order: 0,
        ),
      ],
      variants: [
        const ProductVariantModel(id: 4, color: 'Pink', size: '3Y', stock: 10),
        const ProductVariantModel(id: 5, color: 'Pink', size: '4Y', stock: 10),
      ],
      material: 'Cotton',
      specialFeatures: 'Elastic waistband',
      careAndCleaning: 'Machine wash',
      manufacturedBy: 'Pebble',
    );

    final mockBundle = ProductsBundleModel(
      id: 1,
      tag: 'Bundle & Save',
      heading: 'Buy 2 Get 10% Off',
      discountPercentage: 10,
      bannerImage: 'https://example.com/bundle-banner.webp',
      hotspot1X: 56.0,
      hotspot1Y: 26.0,
      hotspot2X: 40.0,
      hotspot2Y: 62.0,
      bundleProducts: [mockProduct1, mockProduct2],
      buttonText: 'Add all to cart',
    );

    testWidgets(
      'bundle with a missing variant offers no invented sizes or purchase',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final unavailable = ProductModel(
          id: 203,
          category: mockProduct1.category,
          name: 'Unavailable Item',
          slug: 'unavailable-item',
          description: '',
          price: '20.00',
          compareAtPrice: null,
          sku: 'UNAVAILABLE',
          badge: '',
          videoFile: '',
          videoUrl: '',
          weight: null,
          isActive: true,
          createdAt: DateTime(2026),
          images: [],
          variants: [],
        );
        final incompleteBundle = ProductsBundleModel(
          id: 2,
          tag: mockBundle.tag,
          heading: mockBundle.heading,
          discountPercentage: mockBundle.discountPercentage,
          bannerImage: '',
          hotspot1X: 56,
          hotspot1Y: 26,
          hotspot2X: 40,
          hotspot2Y: 62,
          bundleProducts: [mockProduct1, unavailable],
          buttonText: mockBundle.buttonText,
        );
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: ProductsBundleSection(bundle: incompleteBundle),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Bundle unavailable'), findsOneWidget);
        expect(find.text('Unavailable'), findsOneWidget);
        expect(find.text('Size: 3Y'), findsOneWidget);
        final button = tester.widget<InkWell>(
          find
              .ancestor(
                of: find.text('Bundle unavailable'),
                matching: find.byType(InkWell),
              )
              .first,
        );
        expect(button.onTap, isNull);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'renders bundle header, lifestyle hotspots, and product cards',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 1000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: ProductsBundleSection(bundle: mockBundle),
                ),
              ),
            ),
          ),
        );

        // Verify Header
        expect(find.text('BUNDLE & SAVE'), findsOneWidget);
        expect(find.text('Buy 2 Get 10% Off'), findsOneWidget);

        // Verify Hotspots (pins 1 and 2)
        expect(find.text('1'), findsWidgets);
        expect(find.text('2'), findsWidgets);

        // Verify Products
        expect(find.text('Crochet Tank Mint'), findsOneWidget);
        expect(find.text('\$45.00'), findsOneWidget);
        expect(find.text('Floral Pant Mint'), findsOneWidget);
        expect(find.text('\$22.00'), findsOneWidget);
        expect(find.text('Sale'), findsOneWidget);

        // Verify "Add all to cart" button
        expect(find.text('Add all to cart'), findsOneWidget);
      },
    );

    testWidgets('calculates 10% discount and bundle savings correctly', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProductsBundleSection(bundle: mockBundle),
              ),
            ),
          ),
        ),
      );

      // Combined: $45 + $22 = $67.00
      // Discount: 10% of $67 = $6.70
      // Discounted Total: $60.30
      expect(find.text('\$60.30'), findsOneWidget);
      expect(find.text('\$67.00'), findsOneWidget);
      expect(find.text('Save 10% (\$6.70)'), findsOneWidget);
    });

    testWidgets('tapping hotspot toggles focus on corresponding product card', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProductsBundleSection(bundle: mockBundle),
              ),
            ),
          ),
        ),
      );

      // Find first pin '1' and tap it
      final pin1 = find.text('1').first;
      await tester.tap(pin1);
      await tester.pumpAndSettle();

      // Tap second pin '2'
      final pin2 = find.text('2').first;
      await tester.tap(pin2);
      await tester.pumpAndSettle();
    });

    for (final width in [320.0, 390.0]) {
      testWidgets(
        'renders mobile layout without overflow at ${width.toInt()}px',
        (tester) async {
          tester.view.physicalSize = Size(width, 844);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() => tester.view.resetPhysicalSize());

          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: ProductsBundleSection(bundle: mockBundle),
                  ),
                ),
              ),
            ),
          );

          expect(find.text('BUNDLE & SAVE'), findsOneWidget);
          expect(find.text('Buy 2 Get 10% Off'), findsOneWidget);
          expect(find.text('Crochet Tank Mint'), findsOneWidget);
          expect(find.text('Add all to cart'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
