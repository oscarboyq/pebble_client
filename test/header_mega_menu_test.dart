import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/core/providers/header_provider.dart';
import 'package:pebble_type/core/widgets/collections_mega_menu.dart';
import 'package:pebble_type/core/widgets/features_mega_menu.dart';
import 'package:pebble_type/core/widgets/mega_menu.dart';
import 'package:pebble_type/core/widgets/mobile_nav_drawer.dart';
import 'package:pebble_type/core/widgets/pages_mega_menu.dart';
import 'package:pebble_type/core/widgets/pebble_header.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/pages/static_info_page.dart';
import 'package:pebble_type/feature/content/providers/content_providers.dart';
import 'package:pebble_type/feature/content/models/content_models.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

void main() {
  testWidgets(
    'MegaMenu (Shop) renders tabs, category items, and Cozy Crew promo banner',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final testShopMenu = ShopMenuModel(
        sections: {
          'new_arrivals': MegaMenuSectionModel(
            title: 'New Arrivals',
            categories: [
              CategoryModel(id: 1, name: 'New In', slug: 'new-in'),
              CategoryModel(id: 2, name: 'Tops', slug: 'tops'),
              CategoryModel(id: 3, name: 'Bottoms', slug: 'bottoms'),
              CategoryModel(id: 4, name: 'Dresses', slug: 'dresses'),
            ],
          ),
          'best_sellers': MegaMenuSectionModel(
            title: 'Best Sellers',
            categories: [
              CategoryModel(
                id: 5,
                name: 'Popular Outerwear',
                slug: 'outerwear',
              ),
              CategoryModel(id: 6, name: 'Popular Sandals', slug: 'sandals'),
            ],
          ),
        },
        promo: ShopMenuPromoModel(
          eyebrow: 'NEW COLLECTION',
          title: 'The Cozy Crew',
          ctaText: 'Shop Now',
          ctaLink: '/products',
          bgColor: '#84A999',
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MegaMenu(
                categories: testShopMenu.categoriesFor('new_arrivals'),
                shopMenu: testShopMenu,
                bannerImage: '',
                bannerCtaText: 'Shop Now',
                bannerCtaLink: '/products',
                navKey: 'shop',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Sidebar Tabs
      expect(find.text('New Arrivals'), findsOneWidget);
      expect(find.text('Best Sellers'), findsOneWidget);
      expect(find.text('Clothing'), findsOneWidget);
      expect(find.text('Shop All'), findsOneWidget);

      // Verify Category Grid items
      expect(find.text('New In'), findsOneWidget);
      expect(find.text('Tops'), findsOneWidget);
      expect(find.text('Bottoms'), findsOneWidget);
      expect(find.text('Dresses'), findsOneWidget);

      // Verify Promo Banner Card
      expect(find.text('NEW COLLECTION'), findsOneWidget);
      expect(find.text('The Cozy Crew'), findsOneWidget);
      expect(find.text('Shop Now'), findsOneWidget);

      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(-10, -10));
      await mouse.moveTo(tester.getCenter(find.text('Best Sellers')));
      await tester.pumpAndSettle();
      expect(find.text('Popular Outerwear'), findsOneWidget);
      expect(find.text('Popular Sandals'), findsOneWidget);
      await mouse.removePointer();
    },
  );

  testWidgets(
    'CollectionsMegaMenu renders 3 columns and promo cards matching Screenshot 2',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CollectionsMegaMenu(
                menu: CollectionsMenuModel(columns: [], promos: []),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify 3 Column Headers
      expect(find.text('Featured'), findsOneWidget);
      expect(find.text("Boy's"), findsOneWidget);
      expect(find.text("Girl's"), findsOneWidget);

      // Verify Column Links
      expect(find.text('New Arrivals'), findsOneWidget);
      expect(find.text('Winter Seasonal'), findsOneWidget);
      expect(find.text('Everyday Essentials'), findsOneWidget);
      expect(find.text('Shorts'), findsOneWidget);
      expect(find.text('Pants'), findsNWidgets(2));

      // Verify 2 Promo Cards
      expect(find.text('Summer Sale Campaign'), findsOneWidget);
      expect(find.text('Talkative Child'), findsOneWidget);
    },
  );

  testWidgets(
    'PagesMegaMenu renders navigation links, brand philosophy, and cards',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: PagesMegaMenu())),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Zone 1 links
      expect(find.text('Explore Pebble'), findsOneWidget);
      expect(find.text('Our Story'), findsNWidgets(2)); // link + card title
      expect(find.text('FAQs'), findsOneWidget);
      expect(find.text('Contact Us'), findsOneWidget);
      expect(find.text('Find A Store'), findsOneWidget);
      expect(find.text('Our Journal'), findsNWidgets(2)); // link + card title

      // Verify Zone 2 "Who We Are"
      expect(find.text('Who We Are'), findsOneWidget);
      expect(
        find.textContaining('simple, well-made essentials'),
        findsOneWidget,
      );
      expect(find.text('Everyday Comfort'), findsOneWidget);
      expect(find.text('Made for Play'), findsOneWidget);
    },
  );

  testWidgets(
    'FeaturesMegaMenu renders compact flyout with cascading submenus',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1440, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: FeaturesMegaMenu())),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Primary Dropdown items
      expect(find.text('Collections'), findsOneWidget);
      expect(find.text('Product Gallery'), findsOneWidget);
      expect(find.text('Product Flash Sale'), findsOneWidget);

      // Verify default active cascading submenu (Collections items)
      expect(find.text('Collection List'), findsOneWidget);
      expect(find.text('Minimal'), findsOneWidget);
      expect(find.text('With Collection Cards'), findsOneWidget);
      expect(find.text('With banner'), findsOneWidget);
      expect(find.text('With full wide banner'), findsOneWidget);
    },
  );

  testWidgets(
    'PebbleHeader transforms active menu item to solid black pill with white text',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [activeMegaMenuProvider.overrideWith((ref) => 'shop')],
          child: const MaterialApp(home: Scaffold(body: PebbleHeader())),
        ),
      );
      await tester.pumpAndSettle();

      // Verify navigation items exist
      expect(find.text('Shop'), findsOneWidget);
      expect(find.text('Collections'), findsOneWidget);
      expect(find.text('Pages'), findsOneWidget);
      expect(find.text('Features'), findsOneWidget);

      // Verify the Shop container has black background
      final animatedContainerFinder = find.byType(AnimatedContainer);
      expect(animatedContainerFinder, findsWidgets);

      // Find the AnimatedContainer whose decoration has black color
      bool foundBlackPill = false;
      for (final element in tester.widgetList<AnimatedContainer>(
        animatedContainerFinder,
      )) {
        final decoration = element.decoration as BoxDecoration?;
        if (decoration?.color == Colors.black) {
          foundBlackPill = true;
          expect(decoration?.borderRadius, BorderRadius.circular(24));
          break;
        }
      }
      expect(foundBlackPill, isTrue);
    },
  );

  testWidgets('MobileNavDrawer renders all 4 accordion sections and toggles', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: MobileNavDrawer())),
      ),
    );
    await tester.pumpAndSettle();

    // Verify brand header
    expect(find.text('PEBBLE'), findsOneWidget);

    // Verify top accordions
    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Collections'), findsOneWidget);
    expect(find.text('Pages'), findsOneWidget);
    expect(find.text('Features'), findsOneWidget);

    // By default 'shop' is expanded
    expect(find.text('New Arrivals'), findsOneWidget);

    // Tap 'Pages' to expand
    await tester.tap(find.text('Pages'));
    await tester.pumpAndSettle();

    expect(find.text('Our Story'), findsOneWidget);
    expect(find.text('Contact Us'), findsOneWidget);
  });

  testWidgets(
    'StaticInfoPage renders page breadcrumbs, title, and editorial body',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            pageDetailProvider.overrideWith(
              (ref, slug) async => PageModel(
                id: 1,
                title: 'Our Story',
                slug: 'our-story',
                body: '<p>Everyday clothes for childhood adventures.</p>',
              ),
            ),
          ],
          child: const MaterialApp(home: StaticInfoPage(slug: 'our-story')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Pages'), findsOneWidget);
      expect(find.text('Our Story'), findsNWidgets(2)); // breadcrumb + title
      expect(find.textContaining('childhood adventures'), findsOneWidget);
      expect(find.text('Back to Shop'), findsOneWidget);
    },
  );

  testWidgets('StaticInfoPage does not invent policy copy when the API fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pageDetailProvider.overrideWith((ref, slug) async {
            throw Exception('offline');
          }),
        ],
        child: const MaterialApp(home: StaticInfoPage(slug: 'orders-shipping')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('This page is unavailable.'), findsOneWidget);
    expect(find.textContaining('3 to 5 business days'), findsNothing);
  });
}
