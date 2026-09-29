import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/widgets/neon_marquee_section.dart';
import 'package:pebble_type/feature/home/widgets/style_comfort_lookbook_section.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

void main() {
  group('NeonMarqueeSection Widget Tests', () {
    testWidgets('renders neon marquee with exact items and background color', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: NeonMarqueeSection())),
      );

      // Verify presence of texts
      expect(find.text('Comfort Products'), findsWidgets);
      expect(find.text('PEBBLE'), findsWidgets);
      expect(find.text('Everyday Comfort'), findsWidgets);
      expect(find.text('Made for Play'), findsWidgets);

      // Verify container color
      final container = tester.widget<Container>(
        find.byWidgetPredicate(
          (w) => w is Container && w.color == const Color(0xFFF6FD7C),
        ),
      );
      expect(container.color, const Color(0xFFF6FD7C));
    });

    testWidgets(
      'renders cleanly inside a ListView with unbounded height constraints',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(children: const [NeonMarqueeSection()]),
            ),
          ),
        );

        expect(find.text('PEBBLE'), findsWidgets);
      },
    );
  });

  group('StyleComfortLookbookSection Widget Tests', () {
    final mockProduct1 = ProductModel(
      id: 31,
      category: CategoryModel(id: 1, name: 'Tops', slug: 'tops'),
      name: 'Basic Tee',
      slug: 'basic-tee',
      description: 'Comfortable basic tee',
      price: '18.00',
      compareAtPrice: '24.00',
      sku: 'BT-01',
      badge: 'Sale',
      videoFile: '',
      videoUrl: '',
      weight: null,
      isActive: true,
      createdAt: DateTime.now(),
      images: [],
      variants: [],
      material: '100% Cotton',
      specialFeatures: 'Breathable',
      careAndCleaning: 'Machine wash',
      manufacturedBy: 'Pebble',
    );

    final mockProduct2 = ProductModel(
      id: 41,
      category: CategoryModel(id: 2, name: 'Accessories', slug: 'accessories'),
      name: 'Backpacks Kids',
      slug: 'backpacks-kids',
      description: 'Durable school backpack',
      price: '34.00',
      compareAtPrice: null,
      sku: 'BK-01',
      badge: '',
      videoFile: '',
      videoUrl: '',
      weight: null,
      isActive: true,
      createdAt: DateTime.now(),
      images: [],
      variants: [],
      material: 'Canvas',
      specialFeatures: 'Water resistant',
      careAndCleaning: 'Wipe clean',
      manufacturedBy: 'Pebble',
    );

    final mockCards = [
      LookbookCardModel(
        id: 1,
        title: 'Casual Playful Look',
        image: 'https://example.com/lookbook-1.webp',
        itemCountLabel: '2 items',
        taggedProducts: [mockProduct1, mockProduct2],
        order: 0,
      ),
      LookbookCardModel(
        id: 2,
        title: 'Summer Breeze Look',
        image: 'https://example.com/lookbook-2.webp',
        itemCountLabel: '2 items',
        taggedProducts: [mockProduct1],
        order: 1,
      ),
    ];

    testWidgets('renders headline and cards with hotspot buttons', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: StyleComfortLookbookSection(cards: mockCards),
              ),
            ),
          ),
        ),
      );

      // Verify Subheading
      expect(find.text('STYLE & COMFORT'), findsOneWidget);

      // Verify Headline presence
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is RichText &&
              w.text.toPlainText().contains(
                'playful style for every little adventure',
              ),
        ),
        findsOneWidget,
      );

      // Verify Hotspot button with item count label
      expect(find.text('2 items'), findsWidgets);

      // Tap the hotspot button to open desktop dialog
      await tester.tap(find.text('2 items').first);
      await tester.pump(const Duration(milliseconds: 400));

      // Verify modal dialog appears with "Shop The Look"
      expect(find.text('Shop The Look'), findsOneWidget);
      expect(find.text('Basic Tee'), findsOneWidget);
      expect(find.text('Backpacks Kids'), findsOneWidget);
      expect(find.text('Quick Add'), findsWidgets);
    });
  });
}
