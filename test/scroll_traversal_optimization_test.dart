import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/core/widgets/auto_pause_visibility.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/widgets/layered_cards_section.dart';
import 'package:pebble_type/feature/home/widgets/new_in_showcase_section.dart';
import 'package:pebble_type/feature/home/widgets/testimonials_parallax_section.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

void main() {
  group('Scroll Traversal & Coordinate Caching Optimization Tests', () {
    testWidgets('AutoPauseVisibility caches content coordinate during scroll',
        (tester) async {
      bool isVisible = false;
      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 500),
                  AutoPauseVisibility(
                    onVisibilityChanged: (visible) => isVisible = visible,
                    throttleDuration: Duration.zero,
                    child: const SizedBox(height: 200, width: 200),
                  ),
                  const SizedBox(height: 1500),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(isVisible, isTrue);

      // Scroll far down past the widget
      scrollController.jumpTo(1400);
      await tester.pumpAndSettle();
      expect(isVisible, isFalse);

      // Scroll back up into viewport
      scrollController.jumpTo(400);
      await tester.pumpAndSettle();
      expect(isVisible, isTrue);

      scrollController.dispose();
    });

    testWidgets('NewInShowcaseSection calculates progress without matrix crash during fling',
        (tester) async {
      final sampleCards = [
        ShowcaseCardModel(
          id: 1,
          title: 'Card 1',
          price: 20.0,
          lifestyleImage: '',
          thumbnailImage: '',
          productLink: '',
          order: 1,
        ),
        ShowcaseCardModel(
          id: 2,
          title: 'Card 2',
          price: 30.0,
          lifestyleImage: '',
          thumbnailImage: '',
          productLink: '',
          order: 2,
        ),
      ];

      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final scrollController = ScrollController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 300),
                  NewInShowcaseSection(cards: sampleCards),
                  const SizedBox(height: 2000),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll incrementally simulating 60fps scrolling
      for (double offset = 50; offset <= 800; offset += 50) {
        scrollController.jumpTo(offset);
        await tester.pump();
      }
      await tester.pumpAndSettle();

      expect(find.text('NEW IN'), findsOneWidget);
      scrollController.dispose();
    });

    testWidgets('LayeredCardsSection and TestimonialsParallax handle scroll seamlessly',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final scrollController = ScrollController();
      final mockTestimonialsData = TestimonialsParallaxModel(
        id: 1,
        tag: 'Reviews',
        heading: 'Customer Praise',
        testimonials: [
          TestimonialItemModel(
            id: 1,
            author: 'Jane',
            quote: 'Great fit!',
            rating: 5,
            image: '',
            product: ProductModel(
              id: 1,
              category: CategoryModel(id: 1, name: 'Hats', slug: 'hats'),
              name: 'Hat',
              slug: 'hat',
              description: '',
              price: '20.00',
              compareAtPrice: null,
              sku: 'H-1',
              badge: '',
              videoFile: '',
              videoUrl: '',
              weight: null,
              isActive: true,
              createdAt: DateTime.now(),
              images: const [],
              variants: const [],
            ),
            columnIndex: 0,
            order: 1,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 200),
                  LayeredCardsSection(cards: const []),
                  TestimonialsParallaxSection(testimonialsData: mockTestimonialsData),
                  const SizedBox(height: 1000),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Scroll down across sections
      scrollController.jumpTo(600);
      await tester.pump();
      scrollController.jumpTo(1200);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('REVIEWS'), findsOneWidget);
      scrollController.dispose();
    });
  });
}
