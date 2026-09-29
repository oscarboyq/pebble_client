import 'package:pebble_type/core/config/api_config.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';

class BannerSlideModel {
  final int id;
  final String title;
  final String subtitle;
  final String image;
  final String ctaText;
  final String ctaLink;
  final String bgColor;
  final int order;

  BannerSlideModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.ctaText,
    required this.ctaLink,
    this.bgColor = '#C99484',
    required this.order,
  });

  factory BannerSlideModel.fromJson(Map<String, dynamic> json) {
    return BannerSlideModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      image: ApiConfig.resolveImageUrl(json['image'] as String? ?? ''),
      ctaText: json['cta_text'] as String? ?? '',
      ctaLink: json['cta_link'] as String? ?? '',
      bgColor: json['bg_color'] as String? ?? '#C99484',
      order: json['order'] as int? ?? 0,
    );
  }
}

class PromoBarModel {
  final int id;
  final String text;

  PromoBarModel({required this.id, required this.text});

  factory PromoBarModel.fromJson(Map<String, dynamic> json) {
    return PromoBarModel(id: json['id'] as int, text: json['text'] as String);
  }
}

class MegaMenuSectionModel {
  final String title;
  final String displayMode;
  final List<CategoryModel> categories;
  final List<ProductModel> products;
  final ShopMenuPromoModel? promo;

  MegaMenuSectionModel({
    required this.title,
    this.displayMode = 'categories',
    required this.categories,
    this.products = const [],
    this.promo,
  });

  bool get showsProducts => displayMode == 'products';

  factory MegaMenuSectionModel.fromJson(Map<String, dynamic> json) {
    return MegaMenuSectionModel(
      title: json['title'] as String? ?? '',
      displayMode: json['display_mode'] as String? ?? 'categories',
      categories: (json['categories'] as List? ?? [])
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      products: (json['products'] as List? ?? [])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      promo: json['promo'] is Map<String, dynamic>
          ? ShopMenuPromoModel.fromJson(json['promo'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ShopMenuPromoModel {
  final String eyebrow;
  final String title;
  final String ctaText;
  final String ctaLink;
  final String? image;
  final String bgColor;

  ShopMenuPromoModel({
    required this.eyebrow,
    required this.title,
    required this.ctaText,
    required this.ctaLink,
    this.image,
    required this.bgColor,
  });

  factory ShopMenuPromoModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ShopMenuPromoModel(
        eyebrow: 'NEW COLLECTION',
        title: 'The Cozy Crew',
        ctaText: 'Shop Now',
        ctaLink: '/products',
        bgColor: '#84A999',
      );
    }
    return ShopMenuPromoModel(
      eyebrow: json['eyebrow'] as String? ?? 'NEW COLLECTION',
      title: json['title'] as String? ?? 'The Cozy Crew',
      ctaText: json['cta_text'] as String? ?? 'Shop Now',
      ctaLink: json['cta_link'] as String? ?? '/products',
      image: json['image'] != null && (json['image'] as String).isNotEmpty
          ? ApiConfig.resolveImageUrl(json['image'] as String)
          : null,
      bgColor: json['bg_color'] as String? ?? '#84A999',
    );
  }
}

class ShopMenuModel {
  final Map<String, MegaMenuSectionModel> sections;
  final ShopMenuPromoModel? promo;

  ShopMenuModel({required this.sections, this.promo});

  factory ShopMenuModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ShopMenuModel(sections: {}, promo: null);

    final sectionsMap = <String, MegaMenuSectionModel>{};
    ShopMenuPromoModel? promoModel;

    json.forEach((key, value) {
      if (key == 'promo') {
        if (value is Map<String, dynamic>) {
          promoModel = ShopMenuPromoModel.fromJson(value);
        }
      } else if (value is Map<String, dynamic>) {
        sectionsMap[key] = MegaMenuSectionModel.fromJson(value);
      }
    });

    return ShopMenuModel(sections: sectionsMap, promo: promoModel);
  }

  List<CategoryModel> categoriesFor(String key) {
    return sections[key]?.categories ?? const [];
  }

  ShopMenuPromoModel? promoFor(String key) {
    return sections[key]?.promo;
  }
}

class CollectionsMenuLinkModel {
  final int id;
  final String label;
  final String route;
  final int order;

  CollectionsMenuLinkModel({
    required this.id,
    required this.label,
    required this.route,
    required this.order,
  });

  factory CollectionsMenuLinkModel.fromJson(Map<String, dynamic> json) {
    return CollectionsMenuLinkModel(
      id: json['id'] as int,
      label: json['label'] as String? ?? '',
      route: json['route'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }
}

class CollectionsMenuColumnModel {
  final int id;
  final String title;
  final int order;
  final List<CollectionsMenuLinkModel> links;

  CollectionsMenuColumnModel({
    required this.id,
    required this.title,
    required this.order,
    required this.links,
  });

  factory CollectionsMenuColumnModel.fromJson(Map<String, dynamic> json) {
    return CollectionsMenuColumnModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      links: (json['links'] as List? ?? [])
          .map(
            (e) => CollectionsMenuLinkModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class CollectionsMenuPromoModel {
  final int id;
  final String title;
  final String image;
  final String route;
  final int order;

  CollectionsMenuPromoModel({
    required this.id,
    required this.title,
    required this.image,
    required this.route,
    required this.order,
  });

  factory CollectionsMenuPromoModel.fromJson(Map<String, dynamic> json) {
    return CollectionsMenuPromoModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      image: ApiConfig.resolveImageUrl(json['image'] as String? ?? ''),
      route: json['route'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }
}

class CollectionsMenuModel {
  final List<CollectionsMenuColumnModel> columns;
  final List<CollectionsMenuPromoModel> promos;

  CollectionsMenuModel({required this.columns, required this.promos});

  factory CollectionsMenuModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CollectionsMenuModel(columns: const [], promos: const []);
    }

    return CollectionsMenuModel(
      columns: (json['columns'] as List? ?? [])
          .map(
            (e) =>
                CollectionsMenuColumnModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      promos: (json['promos'] as List? ?? [])
          .map(
            (e) =>
                CollectionsMenuPromoModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class PagesMenuSettingModel {
  final String whoWeAreTitle;
  final String whoWeAreText;

  PagesMenuSettingModel({
    required this.whoWeAreTitle,
    required this.whoWeAreText,
  });

  factory PagesMenuSettingModel.fromJson(Map<String, dynamic>? json) {
    return PagesMenuSettingModel(
      whoWeAreTitle: json?['who_we_are_title'] as String? ?? 'Who We Are',
      whoWeAreText:
          json?['who_we_are_text'] as String? ??
          'We create simple, well-made essentials that balance comfort and style, giving kids the freedom to explore, play, and grow every day.',
    );
  }
}

class PagesMenuCardModel {
  final int id;
  final String title;
  final String? image;
  final String route;
  final int order;

  PagesMenuCardModel({
    required this.id,
    required this.title,
    this.image,
    required this.route,
    required this.order,
  });

  factory PagesMenuCardModel.fromJson(Map<String, dynamic> json) {
    return PagesMenuCardModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      image: json['image'] != null && (json['image'] as String).isNotEmpty
          ? ApiConfig.resolveImageUrl(json['image'] as String)
          : null,
      route: json['route'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }
}

class PagesMenuLinkModel {
  final int id;
  final String label;
  final String route;
  final int order;

  PagesMenuLinkModel({
    required this.id,
    required this.label,
    required this.route,
    required this.order,
  });

  factory PagesMenuLinkModel.fromJson(Map<String, dynamic> json) {
    return PagesMenuLinkModel(
      id: json['id'] as int? ?? 0,
      label: json['label'] as String? ?? '',
      route: json['route'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }
}

class PagesMenuModel {
  final PagesMenuSettingModel setting;
  final List<PagesMenuCardModel> cards;
  final List<PagesMenuLinkModel> links;

  PagesMenuModel({
    required this.setting,
    required this.cards,
    required this.links,
  });

  factory PagesMenuModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return PagesMenuModel(
        setting: PagesMenuSettingModel.fromJson(null),
        cards: const [],
        links: const [],
      );
    }
    return PagesMenuModel(
      setting: PagesMenuSettingModel.fromJson(
        json['setting'] as Map<String, dynamic>?,
      ),
      cards: (json['cards'] as List? ?? [])
          .map((e) => PagesMenuCardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      links: (json['links'] as List? ?? [])
          .map((e) => PagesMenuLinkModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FeaturesMenuSubItemModel {
  final int id;
  final String title;
  final String route;
  final int order;

  FeaturesMenuSubItemModel({
    required this.id,
    required this.title,
    required this.route,
    required this.order,
  });

  factory FeaturesMenuSubItemModel.fromJson(Map<String, dynamic> json) {
    return FeaturesMenuSubItemModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      route: json['route'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }
}

class FeaturesMenuItemModel {
  final int id;
  final String title;
  final String route;
  final int order;
  final List<FeaturesMenuSubItemModel> subItems;

  FeaturesMenuItemModel({
    required this.id,
    required this.title,
    required this.route,
    required this.order,
    required this.subItems,
  });

  factory FeaturesMenuItemModel.fromJson(Map<String, dynamic> json) {
    return FeaturesMenuItemModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      route: json['route'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      subItems: (json['sub_items'] as List? ?? [])
          .map(
            (e) => FeaturesMenuSubItemModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class StoreSettingsModel {
  final String storeName;
  final String? logo;
  final String contactEmail;
  final String heroTransition;

  StoreSettingsModel({
    required this.storeName,
    this.logo,
    required this.contactEmail,
    this.heroTransition = 'fade_zoom',
  });

  factory StoreSettingsModel.fromJson(Map<String, dynamic> json) {
    final rawLogo = json['logo'] as String?;
    return StoreSettingsModel(
      storeName: json['store_name'] as String? ?? 'little PEBBLE',
      logo: rawLogo != null && rawLogo.isNotEmpty
          ? ApiConfig.resolveImageUrl(rawLogo)
          : null,
      contactEmail: json['contact_email'] as String? ?? '',
      heroTransition: json['hero_transition'] as String? ?? 'fade_zoom',
    );
  }
}

class ShowcaseCardModel {
  final int id;
  final String title;
  final double price;
  final String lifestyleImage;
  final String thumbnailImage;
  final String productLink;
  final int order;

  ShowcaseCardModel({
    required this.id,
    required this.title,
    required this.price,
    required this.lifestyleImage,
    required this.thumbnailImage,
    required this.productLink,
    required this.order,
  });

  factory ShowcaseCardModel.fromJson(Map<String, dynamic> json) {
    return ShowcaseCardModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      lifestyleImage: ApiConfig.resolveImageUrl(
        json['lifestyle_image'] as String? ?? '',
      ),
      thumbnailImage: ApiConfig.resolveImageUrl(
        json['thumbnail_image'] as String? ?? '',
      ),
      productLink: json['product_link'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }
}

class OutfitHighlightModel {
  final int id;
  final String title;
  final String subheading;
  final String heading;
  final String description;
  final String thumbnailImage;
  final String lifestyleImage;
  final String buttonText;
  final String linkUrl;
  final int order;

  OutfitHighlightModel({
    required this.id,
    required this.title,
    required this.subheading,
    required this.heading,
    required this.description,
    required this.thumbnailImage,
    required this.lifestyleImage,
    required this.buttonText,
    required this.linkUrl,
    required this.order,
  });

  factory OutfitHighlightModel.fromJson(Map<String, dynamic> json) {
    return OutfitHighlightModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      subheading: json['subheading'] as String? ?? '',
      heading: json['heading'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnailImage: ApiConfig.resolveImageUrl(
        json['thumbnail_image'] as String? ?? '',
      ),
      lifestyleImage: ApiConfig.resolveImageUrl(
        json['lifestyle_image'] as String? ?? '',
      ),
      buttonText: json['button_text'] as String? ?? 'Shop Now',
      linkUrl: json['link_url'] as String? ?? '',
      order: json['order'] as int? ?? 0,
    );
  }
}

class LayeredScrollingCardModel {
  final int id;
  final String label;
  final String subheading;
  final String heading;
  final String image;
  final String buttonText;
  final String linkUrl;
  final int order;

  LayeredScrollingCardModel({
    required this.id,
    required this.label,
    required this.subheading,
    required this.heading,
    required this.image,
    required this.buttonText,
    required this.linkUrl,
    required this.order,
  });

  factory LayeredScrollingCardModel.fromJson(Map<String, dynamic> json) {
    return LayeredScrollingCardModel(
      id: json['id'] as int? ?? 0,
      label: json['label'] as String? ?? '',
      subheading: json['subheading'] as String? ?? '',
      heading: json['heading'] as String? ?? '',
      image: ApiConfig.resolveImageUrl(json['image'] as String? ?? ''),
      buttonText: json['button_text'] as String? ?? 'Shop now',
      linkUrl: json['link_url'] as String? ?? '/collections/all',
      order: json['order'] as int? ?? 0,
    );
  }
}

class LookbookCardModel {
  final int id;
  final String title;
  final String image;
  final String itemCountLabel;
  final List<ProductModel> taggedProducts;
  final int order;

  LookbookCardModel({
    required this.id,
    required this.title,
    required this.image,
    required this.itemCountLabel,
    this.taggedProducts = const [],
    required this.order,
  });

  factory LookbookCardModel.fromJson(Map<String, dynamic> json) {
    return LookbookCardModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      image: ApiConfig.resolveImageUrl(json['image'] as String? ?? ''),
      itemCountLabel: json['item_count_label'] as String? ?? '2 items',
      taggedProducts: (json['tagged_products'] as List? ?? [])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      order: json['order'] as int? ?? 0,
    );
  }
}

class ProductsHighlightModel {
  final int id;
  final String tag;
  final String heading;
  final String description;
  final String buttonText;
  final String buttonLink;
  final String bannerImage;
  final String videoUrl;
  final String videoPoster;
  final List<ProductModel> carouselProducts;

  ProductsHighlightModel({
    required this.id,
    required this.tag,
    required this.heading,
    required this.description,
    required this.buttonText,
    required this.buttonLink,
    required this.bannerImage,
    required this.videoUrl,
    required this.videoPoster,
    this.carouselProducts = const [],
  });

  factory ProductsHighlightModel.fromJson(Map<String, dynamic> json) {
    return ProductsHighlightModel(
      id: json['id'] as int? ?? 0,
      tag: json['tag'] as String? ?? 'HOT ITEMS',
      heading: json['heading'] as String? ?? 'Shop The Winter\nSet',
      description: json['description'] as String? ?? '',
      buttonText: json['button_text'] as String? ?? 'Shop now',
      buttonLink:
          json['button_link'] as String? ?? '/products/denim-jeans-kids',
      bannerImage: ApiConfig.resolveImageUrl(
        json['banner_image'] as String? ?? '',
      ),
      videoUrl: json['video_url'] as String? ?? '',
      videoPoster: ApiConfig.resolveImageUrl(
        json['video_poster'] as String? ?? '',
      ),
      carouselProducts: (json['carousel_products'] as List? ?? [])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProductSuggestionStepModel {
  final int id;
  final int stepNumber;
  final String title;
  final String badge1;
  final String badge2;
  final List<ProductModel> products;
  final int order;

  ProductSuggestionStepModel({
    required this.id,
    required this.stepNumber,
    required this.title,
    required this.badge1,
    required this.badge2,
    this.products = const [],
    this.order = 0,
  });

  factory ProductSuggestionStepModel.fromJson(Map<String, dynamic> json) {
    return ProductSuggestionStepModel(
      id: json['id'] as int? ?? 0,
      stepNumber: json['step_number'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      badge1: json['badge_1'] as String? ?? '',
      badge2: json['badge_2'] as String? ?? '',
      products: (json['products'] as List? ?? [])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      order: json['order'] as int? ?? 0,
    );
  }
}

class ProductSuggestionModel {
  final int id;
  final String tag;
  final String heading;
  final List<ProductSuggestionStepModel> steps;

  ProductSuggestionModel({
    required this.id,
    required this.tag,
    required this.heading,
    this.steps = const [],
  });

  factory ProductSuggestionModel.fromJson(Map<String, dynamic> json) {
    return ProductSuggestionModel(
      id: json['id'] as int? ?? 0,
      tag: json['tag'] as String? ?? 'How you style it',
      heading:
          json['heading'] as String? ??
          'Dress up in 3 steps.\nPick - Pair - Play!',
      steps: (json['steps'] as List? ?? [])
          .map(
            (e) =>
                ProductSuggestionStepModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class ProductsBundleModel {
  final int id;
  final String tag;
  final String heading;
  final int discountPercentage;
  final String bannerImage;
  final double hotspot1X;
  final double hotspot1Y;
  final double hotspot2X;
  final double hotspot2Y;
  final List<ProductModel> bundleProducts;
  final String buttonText;

  ProductsBundleModel({
    required this.id,
    required this.tag,
    required this.heading,
    required this.discountPercentage,
    required this.bannerImage,
    required this.hotspot1X,
    required this.hotspot1Y,
    required this.hotspot2X,
    required this.hotspot2Y,
    this.bundleProducts = const [],
    required this.buttonText,
  });

  factory ProductsBundleModel.fromJson(Map<String, dynamic> json) {
    return ProductsBundleModel(
      id: json['id'] as int? ?? 0,
      tag: json['tag'] as String? ?? 'Bundle & Save',
      heading: json['heading'] as String? ?? 'Buy 2 Get 10% Off',
      discountPercentage: json['discount_percentage'] as int? ?? 10,
      bannerImage: ApiConfig.resolveImageUrl(
        json['banner_image'] as String? ?? '',
      ),
      hotspot1X: (json['hotspot_1_x'] as num?)?.toDouble() ?? 56.0,
      hotspot1Y: (json['hotspot_1_y'] as num?)?.toDouble() ?? 26.0,
      hotspot2X: (json['hotspot_2_x'] as num?)?.toDouble() ?? 40.0,
      hotspot2Y: (json['hotspot_2_y'] as num?)?.toDouble() ?? 62.0,
      bundleProducts: (json['bundle_products'] as List? ?? [])
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      buttonText: json['button_text'] as String? ?? 'Add all to cart',
    );
  }
}

class TestimonialItemModel {
  final int id;
  final String author;
  final String quote;
  final int rating;
  final String image;
  final ProductModel? product;
  final int columnIndex;
  final int order;

  TestimonialItemModel({
    required this.id,
    required this.author,
    required this.quote,
    required this.rating,
    required this.image,
    this.product,
    required this.columnIndex,
    required this.order,
  });

  factory TestimonialItemModel.fromJson(Map<String, dynamic> json) {
    return TestimonialItemModel(
      id: json['id'] as int? ?? 0,
      author: json['author'] as String? ?? '',
      quote: json['quote'] as String? ?? '',
      rating: json['rating'] as int? ?? 5,
      image: ApiConfig.resolveImageUrl(json['image'] as String? ?? ''),
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      columnIndex: json['column_index'] as int? ?? 0,
      order: json['order'] as int? ?? 0,
    );
  }
}

class TestimonialsParallaxModel {
  final int id;
  final String tag;
  final String heading;
  final List<TestimonialItemModel> testimonials;

  TestimonialsParallaxModel({
    required this.id,
    required this.tag,
    required this.heading,
    required this.testimonials,
  });

  factory TestimonialsParallaxModel.fromJson(Map<String, dynamic> json) {
    return TestimonialsParallaxModel(
      id: json['id'] as int? ?? 0,
      tag: json['tag'] as String? ?? 'What customers say',
      heading: json['heading'] as String? ?? 'Over 500\nHappy Reviews',
      testimonials: (json['testimonials'] as List? ?? [])
          .map((e) => TestimonialItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class OurStoryModel {
  final int id;
  final String tag;
  final String heading;
  final String description;
  final String buttonText;
  final String buttonLink;
  final String image;
  final String badge1Text;
  final String badge1Color;
  final String badge2Text;
  final String badge2Color;

  const OurStoryModel({
    required this.id,
    required this.tag,
    required this.heading,
    required this.description,
    required this.buttonText,
    required this.buttonLink,
    required this.image,
    required this.badge1Text,
    required this.badge1Color,
    required this.badge2Text,
    required this.badge2Color,
  });

  factory OurStoryModel.fromJson(Map<String, dynamic> json) {
    return OurStoryModel(
      id: json['id'] as int? ?? 0,
      tag: json['tag'] as String? ?? 'our story',
      heading:
          json['heading'] as String? ?? 'Delicate ruffles with soft finishes.',
      description: json['description'] as String? ?? '',
      buttonText: json['button_text'] as String? ?? 'Learn more',
      buttonLink: json['button_link'] as String? ?? '/pages/our-journal',
      image: ApiConfig.resolveImageUrl(json['image'] as String? ?? ''),
      badge1Text: json['badge_1_text'] as String? ?? 'Wow',
      badge1Color: json['badge_1_color'] as String? ?? '#BDE6EE',
      badge2Text: json['badge_2_text'] as String? ?? 'Playful',
      badge2Color: json['badge_2_color'] as String? ?? '#FFC8C8',
    );
  }
}

class BrandPillarItemModel {
  final int id;
  final String title;
  final String icon;
  final String buttonText;
  final String buttonLink;
  final int order;

  const BrandPillarItemModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.buttonText,
    required this.buttonLink,
    required this.order,
  });

  factory BrandPillarItemModel.fromJson(Map<String, dynamic> json) {
    return BrandPillarItemModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      icon: ApiConfig.resolveImageUrl(json['icon'] as String? ?? ''),
      buttonText: json['button_text'] as String? ?? 'shop',
      buttonLink: json['button_link'] as String? ?? '/collections/all',
      order: json['order'] as int? ?? 0,
    );
  }
}

class FlexCarouselCardModel {
  final int id;
  final String badge;
  final String heading;
  final String subtext;
  final String image;
  final int widthDesktopPercent;
  final String link;
  final int order;

  const FlexCarouselCardModel({
    required this.id,
    required this.badge,
    required this.heading,
    required this.subtext,
    required this.image,
    required this.widthDesktopPercent,
    required this.link,
    required this.order,
  });

  factory FlexCarouselCardModel.fromJson(Map<String, dynamic> json) {
    return FlexCarouselCardModel(
      id: json['id'] as int? ?? 0,
      badge: json['badge'] as String? ?? '',
      heading: json['heading'] as String? ?? '',
      subtext: json['subtext'] as String? ?? '',
      image: ApiConfig.resolveImageUrl(json['image'] as String? ?? ''),
      widthDesktopPercent: json['width_desktop_percent'] as int? ?? 30,
      link: json['link'] as String? ?? '/collections/all',
      order: json['order'] as int? ?? 0,
    );
  }
}

class FlexCarouselModel {
  final int id;
  final String heading;
  final List<FlexCarouselCardModel> cards;

  const FlexCarouselModel({
    required this.id,
    required this.heading,
    required this.cards,
  });

  factory FlexCarouselModel.fromJson(Map<String, dynamic> json) {
    return FlexCarouselModel(
      id: json['id'] as int? ?? 0,
      heading: json['heading'] as String? ?? 'Dress your explorer in comfort',
      cards: (json['cards'] as List? ?? [])
          .map((e) => FlexCarouselCardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HomePageData {
  final bool hasManagedHeader;
  final bool hasManagedMarquee;
  final bool hasManagedFooter;
  final List<String> marqueeItems;
  final List<Map<String, dynamic>> trustBadges;
  final List<Map<String, dynamic>> headerMenu;
  final Map<String, dynamic>? footerSettings;
  final List<Map<String, dynamic>> footerLinks;
  final List<Map<String, dynamic>> footerInstagramImages;
  final StoreSettingsModel? storeSettings;
  final PromoBarModel? promoBar;
  final List<BannerSlideModel> banners;
  final List<CategoryModel> featuredCategories;
  final List<ShowcaseCardModel> newInShowcase;
  final String newInCtaLink;
  final String newInCtaText;
  final bool newInCtaVisible;
  final List<OutfitHighlightModel> outfitHighlights;
  final List<LayeredScrollingCardModel> layeredCards;
  final List<LookbookCardModel> lookbookCards;
  final ProductsHighlightModel? productsHighlight;
  final ProductSuggestionModel? productSuggestion;
  final ProductsBundleModel? productsBundle;
  final TestimonialsParallaxModel? testimonialsParallax;
  final OurStoryModel? ourStory;
  final List<BrandPillarItemModel> brandPillars;
  final FlexCarouselModel? flexCarousel;
  final List<ProductModel> newArrivals;
  final List<ProductModel> bestSellers;
  final ShopMenuModel shopMenu;
  final CollectionsMenuModel collectionsMenu;
  final PagesMenuModel pagesMenu;
  final List<FeaturesMenuItemModel> featuresMenu;

  HomePageData({
    this.hasManagedHeader = false,
    this.hasManagedMarquee = false,
    this.hasManagedFooter = false,
    this.marqueeItems = const [],
    this.trustBadges = const [],
    this.headerMenu = const [],
    this.footerSettings,
    this.footerLinks = const [],
    this.footerInstagramImages = const [],
    this.storeSettings,
    this.promoBar,
    required this.banners,
    required this.featuredCategories,
    this.newInShowcase = const [],
    this.newInCtaLink = '/collections/outerwear',
    this.newInCtaText = 'Shop Now',
    this.newInCtaVisible = true,
    this.outfitHighlights = const [],
    this.layeredCards = const [],
    this.lookbookCards = const [],
    this.productsHighlight,
    this.productSuggestion,
    this.productsBundle,
    this.testimonialsParallax,
    this.ourStory,
    this.brandPillars = const [],
    this.flexCarousel,
    required this.newArrivals,
    required this.bestSellers,
    required this.shopMenu,
    required this.collectionsMenu,
    PagesMenuModel? pagesMenu,
    List<FeaturesMenuItemModel>? featuresMenu,
  }) : pagesMenu = pagesMenu ?? PagesMenuModel.fromJson(null),
       featuresMenu = featuresMenu ?? const [];

  factory HomePageData.fromJson(Map<String, dynamic> json) {
    return HomePageData(
      hasManagedHeader: json.containsKey('header_menu'),
      hasManagedMarquee: json.containsKey('marquee_items'),
      hasManagedFooter: json.containsKey('footer_settings'),
      marqueeItems: (json['marquee_items'] as List? ?? [])
          .map((item) => (item as Map<String, dynamic>)['text'] as String)
          .toList(),
      trustBadges: (json['trust_badges'] as List? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      headerMenu: (json['header_menu'] as List? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      footerSettings: json['footer_settings'] == null
          ? null
          : Map<String, dynamic>.from(json['footer_settings'] as Map),
      footerLinks: (json['footer_links'] as List? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      footerInstagramImages: (json['footer_instagram_images'] as List? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList(),
      storeSettings: json['store_settings'] != null
          ? StoreSettingsModel.fromJson(
              json['store_settings'] as Map<String, dynamic>,
            )
          : null,
      promoBar: json['promo_bar'] != null
          ? PromoBarModel.fromJson(json['promo_bar'] as Map<String, dynamic>)
          : null,
      banners: (json['banners'] as List)
          .map((e) => BannerSlideModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      featuredCategories: (json['featured_categories'] as List)
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      newInShowcase: (json['new_in_showcase'] as List? ?? [])
          .map((e) => ShowcaseCardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      newInCtaLink:
          (json['new_in_showcase_settings'] as Map?)?['cta_link'] as String? ??
          '/collections/outerwear',
      newInCtaText:
          (json['new_in_showcase_settings'] as Map?)?['button_text']
              as String? ??
          'Shop Now',
      newInCtaVisible:
          (json['new_in_showcase_settings'] as Map?)?['is_active'] as bool? ??
          true,
      outfitHighlights: (json['outfit_highlights'] as List? ?? [])
          .map((e) => OutfitHighlightModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      layeredCards: (json['layered_cards'] as List? ?? [])
          .map(
            (e) =>
                LayeredScrollingCardModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      lookbookCards: (json['lookbook_cards'] as List? ?? [])
          .map((e) => LookbookCardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      productsHighlight: json['products_highlight'] != null
          ? ProductsHighlightModel.fromJson(
              json['products_highlight'] as Map<String, dynamic>,
            )
          : null,
      productSuggestion: json['product_suggestion'] != null
          ? ProductSuggestionModel.fromJson(
              json['product_suggestion'] as Map<String, dynamic>,
            )
          : null,
      productsBundle: json['products_bundle'] != null
          ? ProductsBundleModel.fromJson(
              json['products_bundle'] as Map<String, dynamic>,
            )
          : null,
      testimonialsParallax: json['testimonials_parallax'] != null
          ? TestimonialsParallaxModel.fromJson(
              json['testimonials_parallax'] as Map<String, dynamic>,
            )
          : null,
      ourStory: json['our_story'] != null
          ? OurStoryModel.fromJson(json['our_story'] as Map<String, dynamic>)
          : null,
      brandPillars: (json['brand_pillars'] as List? ?? [])
          .map((e) => BrandPillarItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      flexCarousel: json['flex_carousel'] != null
          ? FlexCarouselModel.fromJson(
              json['flex_carousel'] as Map<String, dynamic>,
            )
          : null,
      newArrivals: (json['new_arrivals'] as List)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      bestSellers: (json['best_sellers'] as List)
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      shopMenu: ShopMenuModel.fromJson(
        json['shop_menu'] as Map<String, dynamic>?,
      ),
      collectionsMenu: CollectionsMenuModel.fromJson(
        json['collections_menu'] as Map<String, dynamic>?,
      ),
      pagesMenu: PagesMenuModel.fromJson(
        json['pages_menu'] as Map<String, dynamic>?,
      ),
      featuresMenu: (json['features_menu'] as List? ?? [])
          .map((e) => FeaturesMenuItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
