import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/providers/home_provider.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/pages/product_detail_page.dart';
import 'package:pebble_type/feature/products/providers/product_providers.dart';
import 'package:pebble_type/feature/reviews/providers/review_provider.dart';
import 'package:pebble_type/feature/wishlist/providers/wishlist_provider.dart';

class _EmptyHome extends HomeNotifier {
  @override
  Future<HomePageData> build() async => HomePageData(
    banners: const [],
    featuredCategories: const [],
    newArrivals: const [],
    bestSellers: const [],
    shopMenu: ShopMenuModel.fromJson(null),
    collectionsMenu: CollectionsMenuModel.fromJson(null),
  );
}

class _EmptyWishlist extends WishlistNotifier {
  @override
  Future<Set<String>> build() async => {};
}

void main() {
  final product = ProductModel(
    id: 1,
    category: CategoryModel(id: 1, name: 'T-Shirts', slug: 't-shirts'),
    name: 'Basic Tee',
    slug: 'basic-tee',
    description: 'Soft cotton tee.',
    price: '24.00',
    compareAtPrice: null,
    sku: 'BASIC',
    badge: '',
    videoUrl: '',
    videoFile: '',
    weight: null,
    isActive: true,
    createdAt: DateTime(2026),
    images: [],
    variants: const [
      ProductVariantModel(id: 1, color: 'Blue', size: '4Y', stock: 10),
    ],
  );

  for (final width in [360.0, 768.0, 1280.0]) {
    testWidgets('product and curated rails fit at ${width.toInt()}px', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final intents = <String>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productDetailProvider.overrideWith((ref, slug) async => product),
            recommendedProvider.overrideWith((ref, args) async {
              intents.add(args.intent);
              return [product];
            }),
            reviewsProvider.overrideWith((ref, slug) async => []),
            homeProvider.overrideWith(_EmptyHome.new),
            wishlistProvider.overrideWith(_EmptyWishlist.new),
          ],
          child: const MaterialApp(home: ProductDetailPage(slug: 'basic-tee')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Basic Tee'), findsWidgets);
      if (width >= 600) {
        await tester.scrollUntilVisible(
          find.text('You May Also Like'),
          400,
          scrollable: find.byType(Scrollable).first,
          maxScrolls: 30,
        );
        await tester.pumpAndSettle();
      }
      expect(intents, containsAll(['outfit', 'related']));
      expect(tester.takeException(), isNull);
    });
  }

  for (final width in [360.0, 1280.0]) {
    testWidgets(
      'product without a variant cannot be purchased at ${width.toInt()}px',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final unavailable = ProductModel(
          id: 2,
          category: product.category,
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
              productDetailProvider.overrideWith(
                (ref, slug) async => unavailable,
              ),
              recommendedProvider.overrideWith((ref, args) async => []),
              reviewsProvider.overrideWith((ref, slug) async => []),
              homeProvider.overrideWith(_EmptyHome.new),
              wishlistProvider.overrideWith(_EmptyWishlist.new),
            ],
            child: const MaterialApp(
              home: ProductDetailPage(slug: 'campus-spirit-e-cap'),
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
}
