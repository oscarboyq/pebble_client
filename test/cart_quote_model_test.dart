import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/cart/models/cart_model.dart';

void main() {
  test('cart parses server quote and selected offer', () {
    final cart = CartModel.fromJson({
      'id': 1,
      'items': <dynamic>[],
      'subtotal': 67.0,
      'discount': 6.7,
      'total': 60.3,
      'applied_offer': {'type': 'bundle', 'name': 'Buy 2 Get 10% Off', 'pairs': 1},
      'coupon_code': 'SAVE5',
      'coupon_error': null,
      'item_count': 2,
      'updated_at': '2026-09-27T00:00:00Z',
    });

    expect(cart.subtotal, 67.0);
    expect(cart.discount, 6.7);
    expect(cart.total, 60.3);
    expect(cart.appliedOffer?.name, 'Buy 2 Get 10% Off');
    expect(cart.appliedOffer?.pairs, 1);
    expect(cart.couponCode, 'SAVE5');
  });

  test('cart still parses older responses without pricing fields', () {
    final cart = CartModel.fromJson({
      'id': 1,
      'items': <dynamic>[],
      'total': 20.0,
      'item_count': 0,
      'updated_at': '2026-09-27T00:00:00Z',
    });
    expect(cart.subtotal, 20.0);
    expect(cart.discount, 0.0);
    expect(cart.appliedOffer, isNull);
  });
}
