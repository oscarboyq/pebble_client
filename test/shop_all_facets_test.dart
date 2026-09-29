import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/core/services/product_service.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/models/filter_model.dart';
import 'package:pebble_type/feature/products/providers/product_providers.dart';
import 'package:pebble_type/feature/products/widgets/filter_sheet.dart';
import 'package:pebble_type/feature/products/widgets/filter_sidebar.dart';

void main() {
  testWidgets('Shop All shows real facets and filters by product type', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        shopAllFacetsProvider.overrideWith(
          (ref) async => const ProductFacets(
            colors: ['Cream/Brown'],
            sizes: ['3Y'],
            productTypes: ['T-Shirts', 'Hoodies'],
            colorCounts: {'Cream/Brown': 2},
            sizeCounts: {'3Y': 3},
            productTypeCounts: {'T-Shirts': 4, 'Hoodies': 2},
            availabilityCounts: {'in_stock': 6, 'out_of_stock': 1},
            maxPrice: 66,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: FilterSidebar(
              categories: [
                CategoryModel(
                  id: 1,
                  name: 'T-Shirts',
                  slug: 't-shirts',
                  productCount: 6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cream/Brown'), findsOneWidget);
    expect(find.text('3Y'), findsOneWidget);
    expect(find.text('Product type'), findsOneWidget);
    await tester.ensureVisible(find.text('Hoodies'));
    await tester.tap(find.text('Hoodies'));
    await tester.pump();
    expect(container.read(productFilterProvider).productType, 'Hoodies');
  });

  testWidgets('mobile sheet returns the selected product type', (tester) async {
    ProductFilter? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                selected = await showModalBottomSheet<ProductFilter>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const FilterSheet(
                    initial: ProductFilter(),
                    productTypes: ['T-Shirts', 'Hoodies'],
                    sizes: ['3Y'],
                    colors: ['Cream'],
                  ),
                );
              },
              child: const Text('Open filters'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Hoodies'));
    await tester.tap(find.text('Hoodies'));
    await tester.ensureVisible(find.text('Apply Filters'));
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();
    expect(selected?.productType, 'Hoodies');
  });
}
