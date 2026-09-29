import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pebble_type/core/services/cart_service.dart';
import 'package:pebble_type/core/services/storage_service.dart';
import 'package:pebble_type/feature/cart/models/cart_model.dart';

class CartNotifier extends AsyncNotifier<CartModel> {
  @override
  Future<CartModel> build() async {
    final token = await StorageService.getAccessToken();
    if (token == null) {
      return CartModel.empty();
    }
    try {
      return await CartService.getCart();
    } catch (_) {
      return CartModel.empty();
    }
  }

  Future<bool> addItem({
    required String productSlung,
    int? variantId,
    int quantity = 1,
  }) async {
    final token = await StorageService.getAccessToken();
    if (token == null) {
      return false;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => CartService.addItem(
        productSlung: productSlung,
        variantId: variantId,
        quantity: quantity,
      ),
    );
    return !state.hasError;
  }

  Future<bool> addBundle({
    required int bundleId,
    required List<int> variantIds,
  }) async {
    final token = await StorageService.getAccessToken();
    if (token == null) return false;
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => CartService.addBundle(bundleId: bundleId, variantIds: variantIds),
    );
    return !state.hasError;
  }

  Future<void> updateItem({required int itemId, required int quantity}) async {
    state = AsyncData(
      await CartService.updateItem(itemId: itemId, quantity: quantity),
    );
  }

  Future<void> removeItem(int itemId) async {
    state = AsyncData(await CartService.removeItem(itemId));
  }

  Future<void> clearCart() async {
    state = await AsyncValue.guard(() => CartService.clearCart());
  }

  Future<void> applyCoupon(String code) async {
    state = AsyncData(await CartService.applyCoupon(code));
  }

  Future<void> removeCoupon() async {
    state = AsyncData(await CartService.removeCoupon());
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, CartModel>(
  CartNotifier.new,
);

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).value?.itemCount ?? 0;
});
