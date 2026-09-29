import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/widgets/explore_categories_section.dart';
import 'package:pebble_type/feature/home/widgets/flex_carousel_section.dart';
import 'package:pebble_type/feature/home/widgets/hot_this_week_section.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dummyCategory = CategoryModel(
    id: 1,
    name: 'Boys Sweaters',
    slug: 'boys-sweaters',
    gender: 'boys',
    productCount: 12,
  );

  final List<ProductModel> mockProducts = List.generate(
    10,
    (i) => ProductModel(
      id: i + 1,
      category: dummyCategory,
      name: 'Product ${i + 1}',
      slug: 'product-${i + 1}',
      description: 'Desc',
      price: '30.00',
      compareAtPrice: null,
      sku: 'SKU-$i',
      badge: 'New',
      videoUrl: '',
      weight: null,
      videoFile: '',
      isActive: true,
      createdAt: DateTime.now(),
      images: [
        ProductImageModel(
          id: i + 1,
          image: 'https://example.com/p$i.webp',
          altText: 'Alt',
          isPrimary: true,
          order: 0,
        ),
      ],
      variants: [
        ProductVariantModel(id: i + 1, color: 'Blue', size: 'M', stock: 5),
      ],
    ),
  );

  final mockCategories = List.generate(
    8,
    (i) => CategoryModel(
      id: i + 1,
      name: 'Cat ${i + 1}',
      slug: 'cat-${i + 1}',
      gender: 'boys',
      productCount: 20 + i,
    ),
  );

  final mockCarousel = FlexCarouselModel(
    id: 1,
    heading: 'Explore In Comfort',
    cards: List.generate(
      4,
      (i) => FlexCarouselCardModel(
        id: i + 1,
        badge: 'Badge $i',
        heading: 'Card Heading $i',
        subtext: 'Card Subtext $i',
        image: 'https://example.com/c$i.webp',
        widthDesktopPercent: 30,
        link: '/collections/all',
        order: i,
      ),
    ),
  );

  group('Horizontal Carousel Virtualization & Fixed Extent Tests', () {
    testWidgets('HotThisWeekSection mounts ListView with non-null itemExtent', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HotThisWeekSection(
              bestSellers: mockProducts,
              newArrivals: mockProducts,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);

      final ListView listViewWidget = tester.widget(listViewFinder);
      expect(listViewWidget.scrollDirection, Axis.horizontal);
      expect(listViewWidget.itemExtent, isNotNull);
      expect(listViewWidget.itemExtent!, greaterThan(100.0));

      // Drag horizontally to verify layout stability
      await tester.drag(listViewFinder, const Offset(-300, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('ExploreCategoriesSection mounts ListView with non-null itemExtent', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ExploreCategoriesSection(
              categories: mockCategories,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsOneWidget);

      final ListView listViewWidget = tester.widget(listViewFinder);
      expect(listViewWidget.scrollDirection, Axis.horizontal);
      expect(listViewWidget.itemExtent, isNotNull);
      expect(listViewWidget.itemExtent!, greaterThan(80.0));

      // Drag horizontally to verify layout stability
      await tester.drag(listViewFinder, const Offset(-250, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('FlexCarouselSection cards are wrapped in tight BoxConstraints', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FlexCarouselSection(
                carouselData: mockCarousel,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find ConstrainedBox widgets inside the horizontal row
      final constrainedBoxFinder = find.byType(ConstrainedBox);
      expect(constrainedBoxFinder, findsWidgets);

      bool foundTightCardConstraint = false;
      for (final element in constrainedBoxFinder.evaluate()) {
        final box = element.widget as ConstrainedBox;
        if (box.constraints.hasTightWidth && box.constraints.maxWidth >= 280.0) {
          foundTightCardConstraint = true;
          break;
        }
      }
      expect(foundTightCardConstraint, isTrue);
    });
  });
}
