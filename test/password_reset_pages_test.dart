import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/auth/pages/password_reset_pages.dart';

void main() {
  testWidgets('recovery request validates email before sending', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordPage()));
    await tester.tap(find.text('Send reset link'));
    await tester.pump();
    expect(find.text('Enter a valid email address'), findsOneWidget);
  });

  testWidgets('reset form rejects mismatched passwords locally', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ResetPasswordPage(uid: 'uid', token: 'token'),
      ),
    );
    await tester.enterText(
      find.byType(TextFormField).first,
      'LongSecurePass12!',
    );
    await tester.enterText(find.byType(TextFormField).last, 'DifferentPass12!');
    await tester.tap(find.text('Update password'));
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}
