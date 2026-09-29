import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/cart/models/cart_model.dart';
import 'package:pebble_type/feature/cart/pages/cart_page.dart';
import 'package:pebble_type/feature/cart/providers/cart_provider.dart';
import 'package:pebble_type/feature/orders/pages/checkout_page.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

class _CartFixture extends CartNotifier {
  @override
  Future<CartModel> build() async {
    final product = ProductModel(
      id: 1,
      category: CategoryModel(id: 1, name: 'T-Shirts', slug: 't-shirts'),
      name: 'Basic Tee',
      slug: 'basic-tee',
      description: '',
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
      variants: [],
    );
    return CartModel(
      id: 1,
      items: [
        CartItemModel(
          id: 1,
          product: product,
          quantity: 2,
          unitPrice: 24,
          lineTotal: 48,
          addedAt: DateTime(2026),
        ),
      ],
      itemCount: 2,
      subtotal: 48,
      discount: 4.8,
      total: 43.2,
      appliedOffer: const CartOfferModel(type: 'bundle', name: 'Bundle saving'),
      updatedAt: DateTime(2026),
    );
  }
}

void main() {
  for (final width in [360.0, 768.0, 1280.0]) {
    for (final page in ['cart', 'checkout']) {
      testWidgets('$page quote fits at ${width.toInt()}px', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [cartProvider.overrideWith(_CartFixture.new)],
            child: MaterialApp(
              home: page == 'cart' ? const CartPage() : const CheckoutPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Bundle saving'), findsOneWidget);
        expect(find.text('\$43.20'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
