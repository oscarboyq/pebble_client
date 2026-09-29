import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/core/services/product_service.dart';
import 'package:pebble_type/feature/products/widgets/product_color_swatch.dart';

void main() {
  test('facet response keeps counts beside labels', () {
    final facets = ProductFacets.fromJson({
      'colors': [
        {'value': 'Blue', 'count': 8},
      ],
      'sizes': [
        {'value': '3Y', 'count': 41},
      ],
      'categories': [
        {'value': 'shirts', 'count': 7},
      ],
      'price': {'max': 66},
    });
    expect(facets.colorCounts['Blue'], 8);
    expect(facets.sizeCounts['3Y'], 41);
    expect(facets.categoryCounts['shirts'], 7);
  });

  testWidgets('combined swatch has a paint surface and two colors', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: ProductColorSwatch(name: 'Cream/Brown', width: 20, height: 20),
        ),
      ),
    );
    expect(tester.getSize(find.byType(ProductColorSwatch)), const Size(20, 20));
    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(ProductColorSwatch),
        matching: find.byType(CustomPaint),
      ),
    );
    expect(paint.painter, isNotNull);
    final colors = ProductColorPalette.forName('Cream/Brown');
    expect(colors, hasLength(2));
    expect(colors.first, isNot(colors.last));
  });
}
