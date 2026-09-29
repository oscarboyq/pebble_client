import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/providers/header_provider.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/core/widgets/footer.dart';
import 'package:pebble_type/core/widgets/promo_popup.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/providers/home_provider.dart';
import 'package:pebble_type/feature/home/widgets/banner_slider.dart';
import 'package:pebble_type/feature/home/widgets/explore_categories_section.dart';
import 'package:pebble_type/feature/home/widgets/new_in_showcase_section.dart';
import 'package:pebble_type/feature/home/widgets/outfit_highlight_section.dart';
import 'package:pebble_type/feature/home/widgets/hot_this_week_section.dart';
import 'package:pebble_type/feature/home/widgets/layered_cards_section.dart';
import 'package:pebble_type/feature/home/widgets/neon_marquee_section.dart';
import 'package:pebble_type/feature/home/widgets/product_suggestion_section.dart';
import 'package:pebble_type/feature/home/widgets/products_bundle_section.dart';
import 'package:pebble_type/feature/home/widgets/products_highlight_section.dart';
import 'package:pebble_type/feature/home/widgets/promo_bar.dart';
import 'package:pebble_type/feature/home/widgets/style_comfort_lookbook_section.dart';
import 'package:pebble_type/feature/home/widgets/testimonials_parallax_section.dart';
import 'package:pebble_type/feature/home/widgets/our_story_section.dart';
import 'package:pebble_type/feature/home/widgets/brand_pillars_marquee_section.dart';
import 'package:pebble_type/feature/home/widgets/flex_carousel_section.dart';
import 'package:pebble_type/feature/home/widgets/trust_badges_section.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ValueNotifier<bool> _isHeroVisible = ValueNotifier<bool>(true);
  final Set<String> _prewarmedUrls = <String>{};

  @override
  void dispose() {
    _isHeroVisible.dispose();
    super.dispose();
  }

  void _prewarmAboveTheFoldImages(HomePageData data) {
    if (data.banners.isNotEmpty) {
      for (final banner in data.banners.take(2)) {
        if (banner.image.isNotEmpty && _prewarmedUrls.add(banner.image)) {
          precacheImage(
            NetworkImage(banner.image),
            context,
            onError: (_, _) {},
          );
        }
      }
    }
    for (final cat in data.featuredCategories.take(6)) {
      if (cat.image != null &&
          cat.image!.isNotEmpty &&
          _prewarmedUrls.add(cat.image!)) {
        precacheImage(NetworkImage(cat.image!), context, onError: (_, _) {});
      }
    }
    final logo = data.storeSettings?.logo;
    if (logo != null && logo.isNotEmpty && _prewarmedUrls.add(logo)) {
      precacheImage(NetworkImage(logo), context, onError: (_, _) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeProvider);
    final isWide = context.isWide;

    return Scaffold(
      backgroundColor: AppColors.background,
      // Mobile only: show top app bar with logo + search icon
      appBar: isWide
          ? null
          : AppBar(
              backgroundColor: AppColors.heroWarmTerracotta,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              centerTitle: true,
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'little ',
                      style: GoogleFonts.caveat(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: 'PEBBLE',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    ref.read(searchAnchorProvider.notifier).state = null;
                    ref.read(isSearchOpenProvider.notifier).state = true;
                  },
                ),
              ],
            ),
      body: homeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load home page'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(homeProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          _prewarmAboveTheFoldImages(data);
          final screenHeight = MediaQuery.sizeOf(context).height;
          final bannerHeight = isWide
              ? (screenHeight * 0.975).clamp(700.0, 1100.0)
              : (screenHeight * 0.88).clamp(580.0, 850.0);

          return PromoPopupWrapper(
            child: RefreshIndicator(
              onRefresh: () async => ref.read(homeProvider.notifier).refresh(),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.axis == Axis.vertical) {
                    final pixels = notification.metrics.pixels;
                    final isScrolled = pixels > 35;
                    if (ref.read(isHeaderScrolledProvider) != isScrolled) {
                      ref.read(isHeaderScrolledProvider.notifier).state =
                          isScrolled;
                    }
                    final heroVisible = pixels < bannerHeight;
                    if (_isHeroVisible.value != heroVisible) {
                      _isHeroVisible.value = heroVisible;
                    }
                  }
                  return false;
                },
                child: CustomScrollView(
                  scrollCacheExtent: const ScrollCacheExtent.pixels(600.0),
                  slivers: [
                    // Promo bar — mobile only (desktop shows it in MainShell)
                    if (!isWide && data.promoBar != null)
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: PromoBar(promoBar: data.promoBar!),
                        ),
                      ),

                    // Keep the interactive hero in the scroll tree so its CTA
                    // receives pointer and keyboard input.
                    SliverToBoxAdapter(
                      child: RepaintBoundary(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: _isHeroVisible,
                          builder: (context, isVisible, _) => TickerMode(
                            enabled: isVisible,
                            child: BannerSlider(
                              banners: data.banners,
                              transition:
                                  data.storeSettings?.heroTransition ??
                                  'fade_zoom',
                              isActive: isVisible,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── 1. Explore Categories (Curtain Reveal Top Cap with rounded corners & shadow) ──
                    SliverToBoxAdapter(
                      child: RepaintBoundary(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 28,
                                offset: const Offset(0, -6),
                              ),
                            ],
                          ),
                          child: ExploreCategoriesSection(
                            categories: data.featuredCategories,
                          ),
                        ),
                      ),
                    ),

                    // ── 2. New In Showcase Cards (3-Column Zig-Zag Pebble Layout) ──
                    if (data.newInShowcase.isNotEmpty)
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: Container(
                            color: AppColors.background,
                            child: NewInShowcaseSection(
                              cards: data.newInShowcase,
                              ctaLink: data.newInCtaLink,
                              ctaText: data.newInCtaText,
                              showCta: data.newInCtaVisible,
                            ),
                          ),
                        ),
                      ),

                    // ── 3. "Outfit For" Interactive Collection Highlight (Move/Glow/Study/Roam) ──
                    if (data.outfitHighlights.isNotEmpty)
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: Container(
                            color: AppColors.background,
                            child: OutfitHighlightSection(
                              items: data.outfitHighlights,
                            ),
                          ),
                        ),
                      ),

                    // ── 4. "Hot This Week" Interactive Product Tabs (Best Sellers / New Arrivals) ──
                    SliverToBoxAdapter(
                      child: RepaintBoundary(
                        child: Container(
                          color: AppColors.background,
                          child: HotThisWeekSection(
                            bestSellers: data.bestSellers,
                            newArrivals: data.newArrivals,
                          ),
                        ),
                      ),
                    ),

                    // ── 5. "Mix Your Style" Layered Stacking Cards ──
                    if (data.layeredCards.isNotEmpty)
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: Container(
                            color: AppColors.background,
                            child: LayeredCardsSection(
                              cards: data.layeredCards,
                            ),
                          ),
                        ),
                      ),

                    // ── 6. Full-Width Neon Lime Marquee Ticker ──
                    if (data.marqueeItems.isNotEmpty || !data.hasManagedMarquee)
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: NeonMarqueeSection(items: data.marqueeItems),
                        ),
                      ),

                    // ── 7. "Style & Comfort" Headline & Lookbook Showcase ──
                    if (data.lookbookCards.isNotEmpty)
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: Container(
                            color: AppColors.background,
                            child: StyleComfortLookbookSection(
                              cards: data.lookbookCards,
                            ),
                          ),
                        ),
                      ),

                    // ── 8. "Shop The Winter Set" Products Highlight ──
                    if (data.productsHighlight != null)
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: Container(
                            color: AppColors.background,
                            child: ProductsHighlightSection(
                              highlight: data.productsHighlight!,
                            ),
                          ),
                        ),
                      ),

                    // ── 9. "How you style it" Product Suggestion (3-Step Accordion) ──
                    if (data.productSuggestion != null)
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: Container(
                            color: AppColors.background,
                            child: ProductSuggestionSection(
                              suggestion: data.productSuggestion!,
                            ),
                          ),
                        ),
                      ),

                    // ── 10. "Bundle & Save" Products Bundle (Lifestyle Hotspots) ──
                    if (data.productsBundle != null)
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: Container(
                            color: AppColors.background,
                            child: ProductsBundleSection(
                              bundle: data.productsBundle!,
                            ),
                          ),
                        ),
                      ),

                    // ── 11. "What customers say" Testimonials Parallax (Over 500 Happy Reviews) ──
                    if (data.testimonialsParallax != null)
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: TestimonialsParallaxSection(
                            testimonialsData: data.testimonialsParallax!,
                          ),
                        ),
                      ),

                    // ── 12. "Our Story" ("Delicate ruffles with soft finishes.") ──
                    if (data.ourStory != null)
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: Container(
                            color: AppColors.background,
                            child: OurStorySection(story: data.ourStory!),
                          ),
                        ),
                      ),

                    // ── 13. Brand Pillars Marquee Ticker ──
                    if (data.brandPillars.isNotEmpty)
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: BrandPillarsMarqueeSection(
                            pillars: data.brandPillars,
                          ),
                        ),
                      ),

                    // ── 14. "Dress your explorer in comfort" Flex Carousel Section ──
                    if (data.flexCarousel != null)
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: Container(
                            color: AppColors.background,
                            child: FlexCarouselSection(
                              carouselData: data.flexCarousel!,
                            ),
                          ),
                        ),
                      ),

                    // ── 15. Pre-Footer Trust Badges / Brand Features ──
                    if (data.trustBadges.isNotEmpty)
                      SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: Container(
                            color: AppColors.background,
                            child: TrustBadgesSection(badges: data.trustBadges),
                          ),
                        ),
                      ),

                    // ── 16. Authentic Dark Pebble Footer & Integrated Newsletter ──
                    if (data.footerSettings != null || !data.hasManagedFooter)
                      const SliverToBoxAdapter(
                        child: RepaintBoundary(child: AppFooter()),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
