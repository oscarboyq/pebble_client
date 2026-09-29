import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/widgets/flex_carousel_section.dart';

void main() {
  group('FlexCarouselSection Widget Tests', () {
    final mockCarousel = FlexCarouselModel(
      id: 1,
      heading: 'Dress your explorer in comfort',
      cards: const [
        FlexCarouselCardModel(
          id: 1,
          badge: 'Exclusive',
          heading: 'Cutie finds are here!',
          subtext:
              'Get ready to swoon! Our newest arrivals are full of color, comfort & charm.',
          image: 'https://example.com/slide1.webp',
          widthDesktopPercent: 30,
          link: '/collections/all',
          order: 1,
        ),
        FlexCarouselCardModel(
          id: 2,
          badge: 'Store Only',
          heading: 'Mini styles, major deals',
          subtext: 'Your kid’s next favorite outfit is just a click away',
          image: 'https://example.com/slide2.webp',
          widthDesktopPercent: 39,
          link: '/collections/all',
          order: 2,
        ),
        FlexCarouselCardModel(
          id: 3,
          badge: 'Time Limited',
          heading: 'Sunny days, snappy styles',
          subtext:
              'Lightweight, easy-wear pieces for kids on the move all summer long.',
          image: 'https://example.com/slide3.webp',
          widthDesktopPercent: 21,
          link: '/collections/all',
          order: 3,
        ),
        FlexCarouselCardModel(
          id: 4,
          badge: 'Exclusive',
          heading: 'New looks, same giggles',
          subtext: 'Say hello to cozy fits, bold prints & smile-worthy styles',
          image: 'https://example.com/slide4.webp',
          widthDesktopPercent: 39,
          link: '/collections/all',
          order: 4,
        ),
        FlexCarouselCardModel(
          id: 5,
          badge: 'Store Only',
          heading: 'Colors of childhood',
          subtext: 'Made for tiny adventurers & their big imaginations.',
          image: 'https://example.com/slide5.webp',
          widthDesktopPercent: 30,
          link: '/collections/all',
          order: 5,
        ),
        FlexCarouselCardModel(
          id: 6,
          badge: 'Time Limited',
          heading: 'Sale on! Smiles on!',
          subtext: 'Snag fun, comfy pieces at happy prices',
          image: 'https://example.com/slide6.webp',
          widthDesktopPercent: 21,
          link: '/collections/all',
          order: 6,
        ),
      ],
    );

    testWidgets('renders section heading and all card elements on desktop', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FlexCarouselSection(carouselData: mockCarousel),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Heading
      expect(find.text('Dress your explorer in comfort'), findsOneWidget);

      // Card Headings
      expect(find.text('Cutie finds are here!'), findsOneWidget);
      expect(find.text('Mini styles, major deals'), findsOneWidget);
      expect(find.text('Sunny days, snappy styles'), findsOneWidget);
      expect(find.text('New looks, same giggles'), findsOneWidget);
      expect(find.text('Colors of childhood'), findsOneWidget);
      expect(find.text('Sale on! Smiles on!'), findsOneWidget);

      // Badges
      expect(find.text('Exclusive'), findsNWidgets(2));
      expect(find.text('Store Only'), findsNWidgets(2));
      expect(find.text('Time Limited'), findsNWidgets(2));

      // Arrow buttons
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('adapts seamlessly to mobile viewport', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FlexCarouselSection(carouselData: mockCarousel),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dress your explorer in comfort'), findsOneWidget);
      expect(find.text('Cutie finds are here!'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('arrow buttons respond to tap and scroll', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: FlexCarouselSection(carouselData: mockCarousel),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final nextBtn = find.byIcon(Icons.chevron_right_rounded);
      expect(nextBtn, findsOneWidget);
      await tester.ensureVisible(nextBtn);

      await tester.tap(nextBtn);
      await tester.pumpAndSettle();

      final prevBtn = find.byIcon(Icons.chevron_left_rounded);
      expect(prevBtn, findsOneWidget);
      await tester.ensureVisible(prevBtn);
      await tester.tap(prevBtn);
      await tester.pumpAndSettle();
    });

    testWidgets('empty cards list returns SizedBox.shrink', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FlexCarouselSection(
              carouselData: FlexCarouselModel(
                id: 1,
                heading: 'Dress your explorer in comfort',
                cards: [],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Dress your explorer in comfort'), findsNothing);
    });

    testWidgets(
      'scroll metrics stay safe when a deferred section appears and unmounts',
      (WidgetTester tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 1200)),
                  SliverToBoxAdapter(
                    child: FlexCarouselSection(carouselData: mockCarousel),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.drag(
          find.byType(CustomScrollView),
          const Offset(0, -1000),
        );
        await tester.pumpAndSettle();
        expect(find.text('Dress your explorer in comfort'), findsOneWidget);
        await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  });
}
