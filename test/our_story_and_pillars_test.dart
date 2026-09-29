import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/widgets/our_story_section.dart';
import 'package:pebble_type/feature/home/widgets/brand_pillars_marquee_section.dart';

void main() {
  group('OurStorySection Widget Tests', () {
    final mockStory = OurStoryModel(
      id: 1,
      tag: 'our story',
      heading: 'Delicate ruffles with soft finishes.',
      description:
          'From newborn essentials to toddler trends, we curate collections that keep your little ones stylish and cozy.',
      image: 'https://example.com/story.webp',
      buttonText: 'Learn more',
      buttonLink: '/pages/our-story',
      badge1Text: 'Wow',
      badge1Color: '#BDE6EE',
      badge2Text: 'Playful',
      badge2Color: '#FFC8C8',
    );

    testWidgets('renders all story text elements and floating badges',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 900));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OurStorySection(story: mockStory),
            ),
          ),
        ),
      );

      // Verify Tag, Heading, Description, and Button text
      expect(find.text('OUR STORY'), findsOneWidget);
      expect(
        find.text('Delicate ruffles with soft finishes.'),
        findsOneWidget,
      );
      expect(
        find.textContaining('From newborn essentials to toddler trends'),
        findsOneWidget,
      );
      expect(find.text('Learn more'), findsOneWidget);

      // Verify Floating badges
      expect(find.text('Wow'), findsOneWidget);
      expect(find.text('Playful'), findsOneWidget);
    });

    testWidgets('adapts layout for mobile screens', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OurStorySection(story: mockStory),
            ),
          ),
        ),
      );

      expect(find.text('OUR STORY'), findsOneWidget);
      expect(find.text('Delicate ruffles with soft finishes.'), findsOneWidget);
      expect(find.text('Wow'), findsOneWidget);
      expect(find.text('Playful'), findsOneWidget);
    });
  });

  group('BrandPillarsMarqueeSection Widget Tests', () {
    final mockPillars = [
      const BrandPillarItemModel(
        id: 1,
        title: 'Comfort Products',
        icon: 'https://example.com/StarFour.webp',
        buttonText: 'shop',
        buttonLink: '/collections/all',
        order: 1,
      ),
      const BrandPillarItemModel(
        id: 2,
        title: 'Organic Cotton',
        icon: 'https://example.com/DropSimple.webp',
        buttonText: 'shop',
        buttonLink: '/collections/all',
        order: 2,
      ),
      const BrandPillarItemModel(
        id: 3,
        title: 'Safety for Skin',
        icon: 'https://example.com/Heart.webp',
        buttonText: 'shop',
        buttonLink: '/collections/all',
        order: 3,
      ),
    ];

    testWidgets('renders pillar titles and shop buttons',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 400));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BrandPillarsMarqueeSection(pillars: mockPillars),
          ),
        ),
      );

      // We duplicate cycles in the marquee ticker, so findWidgets finds >= 1
      expect(find.text('Comfort Products'), findsWidgets);
      expect(find.text('Organic Cotton'), findsWidgets);
      expect(find.text('Safety for Skin'), findsWidgets);
      expect(find.text('shop'), findsWidgets);
    });

    testWidgets('empty pillars returns SizedBox.shrink',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BrandPillarsMarqueeSection(pillars: []),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsNothing);
    });
  });
}
