import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/home/widgets/hot_this_week_section.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

void main() {
  final dummyCategory = CategoryModel(
    id: 1,
    name: 'Kids',
    slug: 'kids',
    gender: 'all',
  );

  final bestSellers = [
    ProductModel(
      id: 1,
      category: dummyCategory,
      name: 'Logo Polo Red',
      slug: 'logo-polo-red',
      description: 'Classic polo',
      price: '45.00',
      compareAtPrice: null,
      sku: 'LPR-1',
      badge: 'New',
      videoUrl: '',
      weight: null,
      isActive: true,
      createdAt: DateTime.now(),
      images: [
        ProductImageModel(
          id: 1,
          image: 'https://example.com/polo1.jpg',
          altText: 'Logo Polo Red Front',
          isPrimary: true,
          order: 0,
        ),
        ProductImageModel(
          id: 2,
          image: 'https://example.com/polo2.jpg',
          altText: 'Logo Polo Red Back',
          isPrimary: false,
          order: 1,
        ),
      ],
      videoFile: '',
      variants: [
        ProductVariantModel(id: 1, color: 'Red', size: 'M', stock: 10),
      ],
    ),
    ProductModel(
      id: 2,
      category: dummyCategory,
      name: 'Backpacks Kids',
      slug: 'backpacks-kids',
      description: 'Durable backpack',
      price: '22.00',
      compareAtPrice: '32.00',
      sku: 'BK-1',
      badge: 'Sale',
      videoUrl: '',
      weight: null,
      isActive: true,
      createdAt: DateTime.now(),
      images: [
        ProductImageModel(
          id: 3,
          image: 'https://example.com/bp1.jpg',
          altText: 'Backpack Kids',
          isPrimary: true,
          order: 0,
        ),
      ],
      videoFile: '',
      variants: [
        ProductVariantModel(id: 2, color: 'Green', size: 'One Size', stock: 5),
      ],
    ),
  ];

  final newArrivals = [
    ProductModel(
      id: 3,
      category: dummyCategory,
      name: 'Basic Tee',
      slug: 'basic-tee',
      description: 'Soft cotton tee',
      price: '22.00',
      compareAtPrice: '32.00',
      sku: 'BT-1',
      badge: 'Sale',
      videoUrl: '',
      weight: null,
      isActive: true,
      createdAt: DateTime.now(),
      images: [
        ProductImageModel(
          id: 4,
          image: 'https://example.com/tee1.jpg',
          altText: 'Basic Tee',
          isPrimary: true,
          order: 0,
        ),
      ],
      videoFile: '',
      variants: [
        ProductVariantModel(id: 3, color: 'Blue', size: 'S', stock: 12),
      ],
    ),
  ];

  testWidgets('HotThisWeekSection renders header, tabs, and product cards',
      (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: HotThisWeekSection(
              bestSellers: bestSellers,
              newArrivals: newArrivals,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Header and Tabs
    expect(find.text('Hot This Week'), findsOneWidget);
    expect(find.text('Best Sellers'), findsOneWidget);
    expect(find.text('New Arrivals'), findsOneWidget);

    // 2. By default, Best Sellers is active
    expect(find.text('Logo Polo Red'), findsOneWidget);
    expect(find.text('Backpacks Kids'), findsOneWidget);
    expect(find.text('Basic Tee'), findsNothing);

    // 3. Verify Sale & New Badges and prices
    expect(find.text('New'), findsOneWidget);
    expect(find.text('Sale'), findsOneWidget);
    expect(find.text('\$45.00'), findsOneWidget);
    expect(find.text('\$32.00'), findsOneWidget);

    // 4. Switch to New Arrivals tab
    await tester.tap(find.text('New Arrivals'));
    await tester.pumpAndSettle();

    expect(find.text('Basic Tee'), findsOneWidget);
    expect(find.text('Logo Polo Red'), findsNothing);
  });
}
