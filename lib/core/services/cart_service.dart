import 'package:pebble_type/core/services/api_client.dart';
import 'package:pebble_type/feature/cart/models/cart_model.dart';

class CartService {
  static Future<CartModel> getCart() async {
    final response = await ApiClient.dio.get('cart/');
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<CartModel> addItem({
    required String productSlung,
    int? variantId,
    int quantity = 1,
  }) async {
    final response = await ApiClient.dio.post(
      'cart/items/',
      data: {
        'product_slug': productSlung,
        if (variantId != null) 'variant_id': variantId,
        'quantity': quantity,
      },
    );
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<CartModel> addBundle({
    required int bundleId,
    required List<int> variantIds,
  }) async {
    final response = await ApiClient.dio.post(
      'cart/bundles/',
      data: {'bundle_id': bundleId, 'variant_ids': variantIds},
    );
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<CartModel> updateItem({
    required int itemId,
    required int quantity,
  }) async {
    final response = await ApiClient.dio.patch(
      'cart/items/$itemId/',
      data: {'quantity': quantity},
    );
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<CartModel> removeItem(int itemId) async {
    final response = await ApiClient.dio.delete('cart/items/$itemId/');
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<CartModel> clearCart() async {
    final response = await ApiClient.dio.delete('cart/clear/');
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<CartModel> applyCoupon(String code) async {
    final response = await ApiClient.dio.post(
      'cart/coupon/',
      data: {'code': code},
    );
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<CartModel> removeCoupon() async {
    final response = await ApiClient.dio.delete('cart/coupon/');
    return CartModel.fromJson(response.data as Map<String, dynamic>);
  }
}
