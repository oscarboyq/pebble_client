import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/widgets/layered_cards_section.dart';

void main() {
  final sampleCards = [
    LayeredScrollingCardModel(
      id: 1,
      label: 'Trendy Picks',
      subheading: 'Fun & comfy style',
      heading: 'Cool Kids',
      image: 'https://example.com/card1.jpg',
      buttonText: 'Shop now',
      linkUrl: '/collections/all',
      order: 0,
    ),
    LayeredScrollingCardModel(
      id: 2,
      label: 'New Arrival',
      subheading: 'Move freely',
      heading: 'Playtime Outfits',
      image: 'https://example.com/card2.jpg',
      buttonText: 'Shop now',
      linkUrl: '/collections/all',
      order: 1,
    ),
    LayeredScrollingCardModel(
      id: 3,
      label: 'Fancy Set',
      subheading: 'new in',
      heading: 'Winter Season',
      image: 'https://example.com/card3.jpg',
      buttonText: 'Shop now',
      linkUrl: '/collections/all',
      order: 2,
    ),
  ];

  testWidgets('LayeredCardsSection renders header, floating stickers, and cards',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LayeredCardsSection(cards: sampleCards),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // 1. Verify header text
    expect(find.text('MIX YOUR STYLE'), findsOneWidget);
    expect(find.text('Feel good & enjoy\nevery day'), findsOneWidget);

    // 2. Verify floating stickers
    expect(find.text('Kids'), findsOneWidget);
    expect(find.text('Playful'), findsOneWidget);
    expect(find.text('Wow'), findsOneWidget);

    // 3. Verify active card content
    expect(find.text('Cool Kids'), findsOneWidget);
    expect(find.text('Trendy Picks'), findsOneWidget);
    expect(find.text('FUN & COMFY STYLE'), findsOneWidget);
    expect(find.text('Shop Now'), findsNWidgets(3));
  });
}
