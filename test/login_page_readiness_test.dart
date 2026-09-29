import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/auth/pages/login_page.dart';

void main() {
  testWidgets('buyer sign-in starts empty with a recovery link', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginPage())),
    );
    await tester.pumpAndSettle();

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .toList();
    expect(fields, hasLength(2));
    expect(
      fields.every((field) => field.controller?.text.isEmpty ?? true),
      isTrue,
    );
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Google'), findsNothing);
    expect(find.text('Apple'), findsNothing);
    expect(find.text('Facebook'), findsNothing);
  });
}
