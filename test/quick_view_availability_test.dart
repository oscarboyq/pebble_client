import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/providers/product_providers.dart';
import 'package:pebble_type/feature/products/widgets/quick_view_sheet.dart';

void main() {
  testWidgets(
    'quick view disables cart action for a product without variants',
    (tester) async {
      final product = ProductModel(
        id: 2,
        category: CategoryModel(
          id: 1,
          name: 'Accessories',
          slug: 'accessories',
        ),
        name: 'Campus Spirit E Cap',
        slug: 'campus-spirit-e-cap',
        description: '',
        price: '45.00',
        compareAtPrice: null,
        sku: 'CAP',
        badge: '',
        videoUrl: '',
        videoFile: '',
        weight: null,
        isActive: true,
        createdAt: DateTime(2026),
        images: [],
        variants: [],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productDetailProvider.overrideWith((ref, slug) async => product),
          ],
          child: const MaterialApp(
            home: Scaffold(body: QuickViewSheet(slug: 'campus-spirit-e-cap')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Unavailable'),
      );
      expect(button.onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}
