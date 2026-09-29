import 'package:pebble_type/core/services/api_client.dart';
import 'package:pebble_type/feature/orders/models/order_model.dart';

class OrderService {
  static Future<OrderModel> placeOrder({
    required String fullName,
    required String phone,
    required String addressLine1,
    String addressLine2 = '',
    required String city,
    required String state,
    required String postalCode,
    String country = 'united states',
  }) async {
    final response = await ApiClient.dio.post(
      'orders/place/',
      data: {
        'full_name': fullName,
        'phone': phone,
        'address_line1': addressLine1,
        'address_line2': addressLine2,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'country': country,
      },
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<List<OrderModel>> getOrders() async {
    final response = await ApiClient.dio.get('orders/');
    return (response.data as List<dynamic>)
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<OrderModel> getOrder(int id) async {
    final response = await ApiClient.dio.get('orders/$id/');
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }
}
