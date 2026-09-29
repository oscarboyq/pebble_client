import 'package:pebble_type/core/services/api_client.dart';

class WishlistService {
  static Future<List<String>> getWishlistSlugs() async {
    final response = await ApiClient.dio.get('wishlist/slugs/');
    return (response.data as List<dynamic>).cast<String>();
  }

  static Future<bool> toggle(String productSlug) async {
    final response = await ApiClient.dio.post('wishlist/$productSlug/toggle/');
    return response.data['wishlisted'] as bool;
  }
}
