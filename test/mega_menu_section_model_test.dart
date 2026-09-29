import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';

void main() {
  group('MegaMenuSectionModel display modes', () {
    test('defaults to categories mode', () {
      final section = MegaMenuSectionModel.fromJson({
        'title': 'New Arrivals',
        'categories': [
          {'id': 1, 'name': 'T-Shirts', 'slug': 't-shirts'},
        ],
      });

      expect(section.displayMode, 'categories');
      expect(section.showsProducts, isFalse);
      expect(section.categories.length, 1);
      expect(section.products, isEmpty);
    });

    test('parses products display mode with product list', () {
      final section = MegaMenuSectionModel.fromJson({
        'title': 'New Arrivals',
        'display_mode': 'products',
        'categories': [],
        'products': [
          {
            'id': 10,
            'name': 'Stripe Shorts',
            'slug': 'stripe-shorts',
            'description': '',
            'price': '24.00',
            'sku': '',
            'badge': 'New',
            'is_active': true,
            'created_at': '2026-09-01T00:00:00Z',
            'images': [],
            'variants': [],
            'category': {'id': 1, 'name': 'Shorts', 'slug': 'shorts'},
          },
        ],
      });

      expect(section.displayMode, 'products');
      expect(section.showsProducts, isTrue);
      expect(section.products.length, 1);
      expect(section.products.first.slug, 'stripe-shorts');
    });
  });

  group('ShopMenuModel sections', () {
    test('exposes sections with display mode and products', () {
      final shopMenu = ShopMenuModel.fromJson({
        'new_arrivals': {
          'title': 'New Arrivals',
          'display_mode': 'products',
          'categories': [],
          'products': [],
        },
        'best_sellers': {
          'title': 'Best Sellers',
          'display_mode': 'categories',
          'categories': [
            {'id': 2, 'name': 'Sets', 'slug': 'sets'},
          ],
        },
      });

      expect(shopMenu.sections['new_arrivals']!.showsProducts, isTrue);
      expect(shopMenu.sections['best_sellers']!.showsProducts, isFalse);
      expect(shopMenu.categoriesFor('best_sellers').length, 1);
    });
  });
}
