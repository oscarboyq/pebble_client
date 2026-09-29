import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/widgets/testimonials_parallax_section.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

void main() {
  group('TestimonialsParallaxSection Widget Tests', () {
    final mockProduct = ProductModel(
      id: 101,
      category: CategoryModel(id: 1, name: 'Hats', slug: 'hats'),
      name: 'Straw Hat Beige',
      slug: 'straw-hat-beige',
      description: 'Elegant straw hat',
      price: '35.00',
      compareAtPrice: null,
      sku: 'SHB-01',
      badge: '',
      videoFile: '',
      videoUrl: '',
      weight: null,
      isActive: true,
      createdAt: DateTime.now(),
      images: [
        ProductImageModel(
          id: 1,
          image: 'https://example.com/hat.webp',
          altText: 'Straw Hat Beige',
          isPrimary: true,
          order: 0,
        ),
      ],
      variants: const [],
    );

    final mockTestimonialsData = TestimonialsParallaxModel(
      id: 1,
      tag: 'What customers say',
      heading: 'Over 500\nHappy Reviews',
      testimonials: [
        TestimonialItemModel(
          id: 1,
          author: 'Tony S.',
          quote: 'Amazing look and quality! The dress is beautiful.',
          rating: 5,
          image: 'https://example.com/review1.webp',
          product: mockProduct,
          columnIndex: 0,
          order: 1,
        ),
        TestimonialItemModel(
          id: 2,
          author: 'Juniper',
          quote: 'Beautiful piece! The fit is perfect.',
          rating: 5,
          image: 'https://example.com/review2.webp',
          product: mockProduct,
          columnIndex: 2,
          order: 2,
        ),
        TestimonialItemModel(
          id: 3,
          author: 'Chloe M.',
          quote: 'Such great quality! Fits beautifully.',
          rating: 5,
          image: 'https://example.com/review3.webp',
          product: mockProduct,
          columnIndex: 1,
          order: 3,
        ),
      ],
    );

    Widget buildTestWidget({
      required Size surfaceSize,
      required TestimonialsParallaxModel data,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: surfaceSize.width,
              child: TestimonialsParallaxSection(testimonialsData: data),
            ),
          ),
        ),
      );
    }

    testWidgets('Renders header tag and heading properly', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestWidget(
          surfaceSize: const Size(1200, 900),
          data: mockTestimonialsData,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('WHAT CUSTOMERS SAY'), findsOneWidget);
      expect(find.text('Over 500\nHappy Reviews'), findsOneWidget);
    });

    testWidgets('Desktop view renders 3 columns and card details', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestWidget(
          surfaceSize: const Size(1200, 900),
          data: mockTestimonialsData,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tony S.'), findsOneWidget);
      expect(find.text('Juniper'), findsOneWidget);
      expect(find.text('Chloe M.'), findsOneWidget);

      expect(find.text('"Amazing look and quality! The dress is beautiful."'), findsOneWidget);
      expect(find.text('"Beautiful piece! The fit is perfect."'), findsOneWidget);
      expect(find.text('"Such great quality! Fits beautifully."'), findsOneWidget);

      expect(find.text('Straw Hat Beige'), findsNWidgets(3));
    });

    testWidgets('Mobile view renders carousel without overflow', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestWidget(
          surfaceSize: const Size(400, 800),
          data: mockTestimonialsData,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('WHAT CUSTOMERS SAY'), findsOneWidget);
      expect(find.byType(PageView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
