import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/widgets/outfit_highlight_section.dart';

void main() {
  testWidgets('OutfitHighlightSection renders all tabs and switches on tap',
      (tester) async {
    final sampleItems = [
      OutfitHighlightModel(
        id: 1,
        title: 'Move',
        subheading: 'Move collection',
        heading: 'Made to Move,\nBuilt for Comfort',
        description:
            'The feeling of getting home from work to find the sun still shining.',
        thumbnailImage: '',
        lifestyleImage: '',
        buttonText: 'Shop Now',
        linkUrl: '/collections/shirts',
        order: 0,
      ),
      OutfitHighlightModel(
        id: 2,
        title: 'Glow',
        subheading: 'Glow collection',
        heading: 'Save Up to 30%,\nComfort You Love',
        description:
            'Cozy pieces made for daily comfort, with up to 30% off selected styles.',
        thumbnailImage: '',
        lifestyleImage: '',
        buttonText: 'Shop Now',
        linkUrl: '/collections/coats-jackets',
        order: 1,
      ),
      OutfitHighlightModel(
        id: 3,
        title: 'Study',
        subheading: 'Study collection',
        heading: 'Clean Styles Made for Focused Days',
        description:
            'Designed for comfort and ease, these pieces support every moment from study.',
        thumbnailImage: '',
        lifestyleImage: '',
        buttonText: 'Shop Now',
        linkUrl: '/collections/accessories',
        order: 2,
      ),
      OutfitHighlightModel(
        id: 4,
        title: 'Roam',
        subheading: 'Roam collection',
        heading: 'Ready to Roam,\nMade for Play',
        description:
            'Soft, easy outfits that keep up with every little adventure.',
        thumbnailImage: '',
        lifestyleImage: '',
        buttonText: 'Shop Now',
        linkUrl: '/collections/sweaters',
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
            child: OutfitHighlightSection(items: sampleItems),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify "OUTFIT FOR" header
    expect(find.text('OUTFIT FOR'), findsOneWidget);

    // Verify all 4 titles exist
    expect(find.text('Move'), findsOneWidget);
    expect(find.text('Glow'), findsOneWidget);
    expect(find.text('Study'), findsOneWidget);
    expect(find.text('Roam'), findsOneWidget);

    // Initial state: Move is active
    expect(find.text('Made to Move,\nBuilt for Comfort'), findsOneWidget);
    expect(find.text('Shop Now'), findsOneWidget);
    expect(find.text('MOVE COLLECTION'), findsOneWidget); // Left card subheading
    expect(find.text('Move collection'), findsOneWidget); // Bottom preview title

    // Tap "Glow" tab
    await tester.tap(find.text('Glow'));
    await tester.pumpAndSettle();

    // Now Glow should be active
    expect(find.text('Save Up to 30%,\nComfort You Love'), findsOneWidget);
    expect(find.text('GLOW COLLECTION'), findsOneWidget);
    expect(find.text('Glow collection'), findsOneWidget);
  });
}

