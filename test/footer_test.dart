import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pebble_type/core/services/api_client.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/providers/home_provider.dart';
import 'package:pebble_type/core/widgets/footer.dart';

class _TestHomeNotifier extends HomeNotifier {
  static HomePageData? data;
  @override
  Future<HomePageData> build() async => data ?? HomePageData(
    banners: const [], featuredCategories: const [], newArrivals: const [],
    bestSellers: const [], shopMenu: ShopMenuModel.fromJson(null),
    collectionsMenu: CollectionsMenuModel.fromJson(null),
  );
}

void main() {
  group('AppFooter Widget Tests', () {
    tearDown(() => _TestHomeNotifier.data = null);
    testWidgets('renders owner managed footer copy and links', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));
      _TestHomeNotifier.data = HomePageData(
        hasManagedFooter: true,
        footerSettings: {'newsletter_heading': 'Join the Pebble club',
          'copyright_text': '© Pebble Studio'},
        footerLinks: [
          {'column': 'company', 'label': 'Our journal', 'route': '/pages/journal'},
          {'column': 'legal', 'label': 'Privacy', 'route': '/pages/privacy'},
        ],
        banners: const [], featuredCategories: const [], newArrivals: const [],
        bestSellers: const [], shopMenu: ShopMenuModel.fromJson(null),
        collectionsMenu: CollectionsMenuModel.fromJson(null),
      );
      await tester.pumpWidget(ProviderScope(
        overrides: [homeProvider.overrideWith(_TestHomeNotifier.new)],
        child: const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: AppFooter()))),
      ));
      await tester.pump();
      expect(find.text('Join the Pebble club'), findsOneWidget);
      expect(find.text('Our journal'), findsOneWidget);
      expect(find.text('© Pebble Studio'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
    });
    testWidgets('renders all key sections and elements in desktop layout',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));

      await tester.pumpWidget(
        ProviderScope(overrides: [homeProvider.overrideWith(_TestHomeNotifier.new)], child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppFooter(),
            ),
          ),
        )),
      );

      // Verify Integrated Newsletter headline
      expect(
        find.text('Subscribe for updates,\ntips & exclusive offers'),
        findsOneWidget,
      );

      // Verify email input field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter your email'), findsOneWidget);

      // Verify disclaimer text
      expect(find.textContaining('By subscribing you agree to the'), findsOneWidget);
      expect(find.textContaining('Terms of Use'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);

      // Verify 4 navigation column titles
      expect(find.text('Company'), findsOneWidget);
      expect(find.text('Collection'), findsOneWidget);
      expect(find.text('Get Help'), findsOneWidget);
      expect(find.text('Follow Us on Instagram'), findsOneWidget);

      // Verify sample nav links
      expect(find.text('Our Story'), findsOneWidget);
      expect(find.text('Just Dropped'), findsOneWidget);
      expect(find.text('Help Center'), findsOneWidget);
      expect(find.text('@littlepebble.co'), findsOneWidget);

      // Verify legal links
      expect(find.text('Accessibility'), findsOneWidget);
      expect(find.text('Terms of Service'), findsOneWidget);

      // Verify sub-footer elements
      expect(
        find.text('© 2026 Pebble Little, Powered by Shopify'),
        findsOneWidget,
      );
      expect(find.text('USD/ EN'), findsOneWidget);
      expect(find.text('VISA'), findsOneWidget);
      expect(find.text('PayPal'), findsOneWidget);
    });

    testWidgets('email subscription interaction displays confirmation state',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));
      var intercepted = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
              (call) async => null);
      final interceptor = InterceptorsWrapper(onRequest: (options, handler) {
        if (options.path.endsWith('home/newsletter/')) {
          intercepted = true;
          handler.resolve(Response(requestOptions: options, statusCode: 201,
              data: {'subscribed': true}));
        } else {
          handler.next(options);
        }
      });
      ApiClient.dio.interceptors.add(interceptor);
      addTearDown(() => ApiClient.dio.interceptors.remove(interceptor));

      await tester.pumpWidget(
        ProviderScope(overrides: [homeProvider.overrideWith(_TestHomeNotifier.new)], child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppFooter(),
            ),
          ),
        )),
      );

      // Enter an email address
      await tester.enterText(find.byType(TextField), 'test@pebblelittle.com');
      await tester.pump();

      // Submit via button or text action
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pumpAndSettle();

      // Verify success message appears
      expect(intercepted, isTrue);
      expect(find.text('Thank you for subscribing!'), findsOneWidget);
    });

    testWidgets('renders cleanly without overflow in mobile layout',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));

      await tester.pumpWidget(
        ProviderScope(overrides: [homeProvider.overrideWith(_TestHomeNotifier.new)], child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AppFooter(),
            ),
          ),
        )),
      );

      // Verify Newsletter headline in mobile
      expect(
        find.text('Subscribe for updates,\ntips & exclusive offers'),
        findsOneWidget,
      );

      // Verify 4 navigation columns still render in responsive layout
      expect(find.text('Company'), findsOneWidget);
      expect(find.text('Collection'), findsOneWidget);
      expect(find.text('Get Help'), findsOneWidget);
      expect(find.text('Follow Us on Instagram'), findsOneWidget);

      // Verify sub-footer
      expect(
        find.text('© 2026 Pebble Little, Powered by Shopify'),
        findsOneWidget,
      );
      expect(find.text('USD/ EN'), findsOneWidget);
    });
  });
}
