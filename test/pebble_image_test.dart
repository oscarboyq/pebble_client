import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/core/widgets/pebble_image.dart';

void main() {
  group('PebbleImage Widget Tests', () {
    testWidgets('renders placeholder when imageUrl is null or empty',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PebbleImage(imageUrl: null, width: 100, height: 100),
                PebbleImage(imageUrl: '', width: 100, height: 100),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.image_outlined), findsNWidgets(2));
    });

    testWidgets('renders custom placeholder when provided and imageUrl is empty',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PebbleImage(
              imageUrl: '',
              placeholder: Text('Custom Placeholder'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Placeholder'), findsOneWidget);
    });

    testWidgets('renders custom error widget when image fails to load',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PebbleImage(
              imageUrl: 'https://example.com/nonexistent.jpg',
              errorWidget: Text('Error Fallback'),
            ),
          ),
        ),
      );

      // In widget tests, network images trigger errorBuilder immediately
      await tester.pump();
      expect(find.text('Error Fallback'), findsOneWidget);
    });

    testWidgets('applies borderRadius when specified', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PebbleImage(
              imageUrl: '',
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );

      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, BorderRadius.circular(16));
    });

    test('PebbleImage.provider returns ResizeImage with appropriate bounds', () {
      final provider = PebbleImage.provider('https://example.com/photo.jpg', cacheWidth: 500);
      expect(provider, isA<ResizeImage>());
      final resize = provider as ResizeImage;
      expect(resize.width, 500);
    });
  });
}
