import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/widgets/banner_slider.dart';

void main() {
  final sampleBanners = [
    BannerSlideModel(
      id: 1,
      title: 'First Banner Slide',
      subtitle: 'New Collection',
      ctaText: 'Shop Now',
      ctaLink: '/products',
      bgColor: '#C99484',
      order: 1,
      image: '',
    ),
    BannerSlideModel(
      id: 2,
      title: 'Second Banner Slide',
      subtitle: 'Summer Sale',
      ctaText: 'Explore',
      ctaLink: '/sale',
      bgColor: '#84A9C9',
      order: 2,
      image: '',
    ),
  ];

  group('BannerSlider Timer & Visibility Tests', () {
    testWidgets('hero slide controls expose labels and move between slides', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerSlider(banners: sampleBanners, isActive: false),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.byTooltip('Next slide'), findsOneWidget);
      expect(find.byTooltip('Previous slide'), findsOneWidget);
      await tester.tap(find.byTooltip('Next slide'));
      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.text('2 / 2'), findsOneWidget);
      await tester.tap(find.byTooltip('Previous slide'));
      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.text('1 / 2'), findsOneWidget);
    });
    testWidgets('Advances to next slide after 7 seconds when active', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerSlider(banners: sampleBanners, isActive: true),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('1 / 2'), findsOneWidget);

      // Fast-forward by 7 seconds
      await tester.pump(const Duration(seconds: 7));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('2 / 2'), findsOneWidget);
    });

    testWidgets(
      'Periodic timer stops completely when isActive is false (scrolled offstage)',
      (tester) async {
        final activeNotifier = ValueNotifier<bool>(true);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ValueListenableBuilder<bool>(
                valueListenable: activeNotifier,
                builder: (context, isActive, _) => TickerMode(
                  enabled: isActive,
                  child: Offstage(
                    offstage: !isActive,
                    child: BannerSlider(
                      banners: sampleBanners,
                      isActive: isActive,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(find.text('1 / 2'), findsOneWidget);

        // Simulate user scrolling hero offstage
        activeNotifier.value = false;
        await tester.pump();

        // Fast-forward 21 seconds (3 timer cycles)
        await tester.pump(const Duration(seconds: 21));

        // Should still be on slide 1 because timer was paused
        activeNotifier.value = true;
        await tester.pump();
        expect(find.text('1 / 2'), findsOneWidget);

        // Once active, advancing 7 seconds switches to slide 2
        await tester.pump(const Duration(seconds: 7));
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('2 / 2'), findsOneWidget);
      },
    );

    testWidgets('Periodic timer pauses on pointer hover', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BannerSlider(banners: sampleBanners, isActive: true),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('1 / 2'), findsOneWidget);

      // Simulate mouse entering the slider
      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      await gesture.moveTo(tester.getCenter(find.byType(BannerSlider)));
      await tester.pump();

      // Fast-forward 14 seconds while mouse is hovering
      await tester.pump(const Duration(seconds: 14));

      // Should still be on slide 1 because hover paused the timer
      expect(find.text('1 / 2'), findsOneWidget);

      // Move mouse completely away outside slider bounds
      await gesture.moveTo(const Offset(-100, -100));
      await tester.pump();

      // Fast-forward 7 seconds after mouse leaves
      await tester.pump(const Duration(seconds: 7));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('2 / 2'), findsOneWidget);
      await gesture.removePointer();
    });
  });
}
