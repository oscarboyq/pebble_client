import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/home/widgets/explore_categories_section.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

void main() {
  testWidgets('ExploreCategoriesSection displays boy categories and switches to girl categories',
      (tester) async {
    final categories = [
      // 8 Boy's categories
      CategoryModel(id: 1, name: 'Sweaters', slug: 'sweaters', gender: 'boys', productCount: 25),
      CategoryModel(id: 2, name: 'Sets', slug: 'sets', gender: 'boys', productCount: 30),
      CategoryModel(id: 3, name: 'Outerwear', slug: 'outerwear', gender: 'boys', productCount: 18),
      CategoryModel(id: 4, name: 'Shirts', slug: 'shirts', gender: 'boys', productCount: 35),
      CategoryModel(id: 5, name: 'T-Shirts', slug: 't-shirts', gender: 'boys', productCount: 21),
      CategoryModel(id: 6, name: 'Accessories', slug: 'accessories', gender: 'boys', productCount: 24),
      CategoryModel(id: 7, name: 'Pants', slug: 'pants', gender: 'boys', productCount: 28),
      CategoryModel(id: 8, name: 'Coats & Jackets', slug: 'coats-jackets', gender: 'boys', productCount: 20),
      // 7 Girl's categories
      CategoryModel(id: 9, name: 'Sweaters', slug: 'girls-sweaters', gender: 'girls', productCount: 20),
      CategoryModel(id: 10, name: 'Dresses', slug: 'girls-dresses', gender: 'girls', productCount: 16),
      CategoryModel(id: 11, name: 'Accessories', slug: 'girls-accessories', gender: 'girls', productCount: 24),
      CategoryModel(id: 12, name: 'Outerwear', slug: 'girls-outerwear', gender: 'girls', productCount: 18),
      CategoryModel(id: 13, name: 'Bags', slug: 'girls-bags', gender: 'girls', productCount: 21),
      CategoryModel(id: 14, name: 'Skirts', slug: 'girls-skirts', gender: 'girls', productCount: 22),
      CategoryModel(id: 15, name: 'Shoes', slug: 'girls-shoes', gender: 'girls', productCount: 23),
    ];

    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ExploreCategoriesSection(categories: categories),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Explore Categories'), findsOneWidget);

    // Verify Tabs
    expect(find.text("Boy's"), findsOneWidget);
    expect(find.text("Girl's"), findsOneWidget);

    // Verify Boy's categories are present
    expect(find.text('Sweaters'), findsOneWidget);
    expect(find.text('Sets'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);

    // Switch to Girl's
    await tester.tap(find.text("Girl's"));
    await tester.pumpAndSettle();

    // Verify Girl's category is present
    expect(find.text('Dresses'), findsOneWidget);
    expect(find.text('16'), findsOneWidget);
    expect(find.text('Bags'), findsOneWidget);
    expect(find.text('21'), findsOneWidget);
  });
}
