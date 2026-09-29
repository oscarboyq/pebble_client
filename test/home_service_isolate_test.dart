import 'dart:isolate';
import 'package:flutter_test/flutter_test.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';

void main() {
  group('HomeService Background Isolate Deserialization Tests', () {
    test(
      'Isolate.run successfully parses HomePageData JSON without blocking',
      () async {
        final mockData = <String, dynamic>{
          'banners': [
            {
              'id': 1,
              'title': 'Test Banner',
              'subtitle': 'Subtitle',
              'image': '/media/banner.jpg',
              'cta_text': 'Shop Now',
              'cta_link': '/collections/all',
              'bg_color': '#C99484',
              'order': 0,
            },
          ],
          'promo_bar': {'id': 1, 'text': 'Free Shipping on orders over \$50'},
          'store_settings': {
            'store_name': 'Pebble Test',
            'promo_bar_enabled': true,
            'promo_bar_text': 'Free Shipping',
            'hero_transition': 'fade_zoom',
          },
          'shop_menu': null,
          'collections_menu': null,
          'featured_categories': [
            {
              'id': 101,
              'name': 'Outerwear',
              'slug': 'outerwear',
              'image': '/media/cat.jpg',
              'gender': 'boys',
              'display_count': 12,
              'is_featured': true,
            },
          ],
          'best_sellers': [],
          'new_arrivals': [],
          'new_in_showcase': [],
          'new_in_showcase_settings': {
            'button_text': 'Explore Outerwear',
            'cta_link': '/collections/outerwear',
            'is_active': true,
          },
          'outfit_highlights': [],
          'layered_scrolling': [],
          'lookbook_cards': [],
          'products_highlight': null,
          'product_suggestion': null,
          'products_bundle': null,
          'testimonials_parallax': null,
          'our_story': null,
          'brand_pillars': [],
          'flex_carousel': null,
        };

        // Offload to worker isolate
        final parsedData = await Isolate.run(
          () => HomePageData.fromJson(mockData),
        );

        expect(parsedData, isNotNull);
        expect(parsedData.banners.length, equals(1));
        expect(parsedData.banners.first.title, equals('Test Banner'));
        expect(
          parsedData.promoBar?.text,
          equals('Free Shipping on orders over \$50'),
        );
        expect(parsedData.featuredCategories.length, equals(1));
        expect(parsedData.featuredCategories.first.name, equals('Outerwear'));
        expect(parsedData.newInCtaLink, '/collections/outerwear');
        expect(parsedData.newInCtaText, 'Explore Outerwear');
      },
    );
  });
}
