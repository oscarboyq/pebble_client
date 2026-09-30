import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/orders/models/order_model.dart';
import 'package:pebble_type/feature/orders/widgets/order_tracking_timeline.dart';

OrderModel sampleOrder(String status) => OrderModel(
  id: 12,
  status: status,
  fullName: 'Buyer',
  phone: '123',
  addressLine1: '1 Main St',
  addressLine2: '',
  city: 'City',
  state: 'State',
  postalCode: '12345',
  country: 'US',
  totalAmount: 40,
  items: [],
  createdAt: DateTime.utc(2026, 9, 29),
  statusEvents: [
    OrderStatusEventModel(status: 'pending', occurredAt: DateTime.utc(2026, 9, 29)),
    OrderStatusEventModel(
      status: status,
      occurredAt: DateTime.utc(2026, 9, 30),
      note: 'Your package is ready.',
    ),
  ],
);

void main() {
  testWidgets('shows dated store milestones at mobile width', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: SingleChildScrollView(child: OrderTrackingTimeline(order: sampleOrder('shipped'))),
    )));

    expect(find.text('Track your order'), findsOneWidget);
    expect(find.text('Order placed'), findsOneWidget);
    expect(find.text('Shipped'), findsOneWidget);
    expect(find.text('Your package is ready.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cancelled order stops the delivery progression', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: OrderTrackingTimeline(order: sampleOrder('cancelled')),
    )));

    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Shipped'), findsNothing);
    expect(find.text('Delivered'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
