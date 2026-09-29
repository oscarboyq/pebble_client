// Holds the last placed order for the confirmation page
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pebble_type/core/services/order_service.dart';
import 'package:pebble_type/feature/orders/models/order_model.dart';

final lastOrderProvider = StateProvider<OrderModel?>((ref) => null);

final ordersProvider = FutureProvider<List<OrderModel>>((ref) async {
  return await OrderService.getOrders();
});
