import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/feature/orders/models/order_model.dart';
import 'package:pebble_type/feature/orders/pages/order_confirmation_page.dart';
import 'package:pebble_type/feature/orders/providers/order_provider.dart';

void main() {
  test(
    'order deep links return after login without allowing external destinations',
    () {
      expect(safeReturnPath('/orders/detail/28'), '/orders/detail/28');
      expect(safeReturnPath('//example.com/steal'), isNull);
      expect(safeReturnPath('https://example.com'), isNull);
      expect(safeReturnPath('/login'), isNull);
    },
  );

  testWidgets('small confirmation screen offers a direct tracking path', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final order = OrderModel(
      id: 28,
      status: 'pending',
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
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const OrderConfirmationPage(),
        ),
        GoRoute(
          path: '/orders/detail/:id',
          builder: (_, state) => Scaffold(
            body: Text('Tracking order ${state.pathParameters['id']}'),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [lastOrderProvider.overrideWith((ref) => order)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Track This Order'));
    await tester.tap(find.text('Track This Order'));
    await tester.pumpAndSettle();
    expect(find.text('Tracking order 28'), findsOneWidget);
  });
}
