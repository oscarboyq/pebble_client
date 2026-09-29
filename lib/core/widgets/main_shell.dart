import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/core/widgets/cart_drawer.dart';
import 'package:pebble_type/core/widgets/collections_mega_menu.dart';
import 'package:pebble_type/core/widgets/features_mega_menu.dart';
import 'package:pebble_type/core/widgets/pages_mega_menu.dart';
import 'package:pebble_type/core/widgets/pebble_header.dart';
import 'package:pebble_type/core/widgets/mega_menu.dart';
import 'package:pebble_type/core/widgets/mobile_nav_drawer.dart';
import 'package:pebble_type/core/widgets/search_overlay.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/providers/header_provider.dart';
import 'package:pebble_type/feature/cart/providers/cart_drawer_provider.dart';
import 'package:pebble_type/feature/cart/providers/cart_provider.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/providers/home_provider.dart';

class MainShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});
  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _megaMenuController;
  late final Animation<double> _megaMenuOpacity;
  late final Animation<Offset> _megaMenuSlide;
  late final Animation<double> _megaMenuSize;

  @override
  void initState() {
    super.initState();
    _megaMenuController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
      reverseDuration: Duration(milliseconds: 250),
    );

    final curve = CurvedAnimation(
      parent: _megaMenuController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _megaMenuOpacity = Tween<double>(begin: 0, end: 1).animate(curve);
    _megaMenuSlide = Tween<Offset>(
      begin: Offset(0, -0.035),
      end: Offset.zero,
    ).animate(curve);
    _megaMenuSize = Tween<double>(begin: 0, end: 1).animate(curve);
  }

  @override
  void dispose() {
    _megaMenuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    final cartCount = cartAsync.value?.items.length ?? 0;
    final isWide = context.isWide;

    if (isWide) {
      final promoText = ref.watch(homeProvider).value?.promoBar?.text;
      final isDrawerOpen = ref.watch(cartDrawerOpenProvider);
      final activeMenu = ref.watch(activeMegaMenuProvider);
      ref.listen<String?>(activeMegaMenuProvider, (previous, next) {
        if (next != null) {
          _megaMenuController.forward();
        } else {
          _megaMenuController.reverse();
        }
      });
      if (activeMenu != null && _megaMenuController.value == 0 && !_megaMenuController.isAnimating) {
        _megaMenuController.forward();
      } else if (activeMenu == null && _megaMenuController.value > 0 && !_megaMenuController.isAnimating) {
        _megaMenuController.reverse();
      }
      final homeAsync = ref.watch(homeProvider);
      final isSearchOpen = ref.watch(isSearchOpenProvider);
      final isScrolled = ref.watch(isHeaderScrolledProvider);

      final promoBarHeight = (promoText != null && promoText.isNotEmpty)
          ? 36.0
          : 0.0;

      String currentLocation = '/';
      try {
        currentLocation = GoRouterState.of(context).matchedLocation;
      } catch (_) {}
      final isHome = currentLocation == AppRoutes.dashboard || currentLocation == '/';
      final isShop = currentLocation == AppRoutes.home;
      final hasHeroBanner = isHome || isShop;
      final isDocked = hasHeroBanner ? isScrolled : true;
      final isFloating = !isDocked && activeMenu != 'features';

      return Scaffold(
        body: Stack(
          children: [
            // ── Main content column ──────────────────────────
            Column(
              children: [
                if (promoText != null && promoText.isNotEmpty)
                  _PromoAnnouncement(text: promoText),
                // On pages without hero banner, show header in flow
                if (!hasHeroBanner) const PebbleHeader(),
                Expanded(child: widget.navigationShell),
              ],
            ),

            // ── Mega menu Backdrop Scrim ──────────────────────
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 280),
                opacity: activeMenu != null ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: activeMenu == null,
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(activeMegaMenuProvider.notifier).state = null,
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
            ),

            // ── Floating Header Overlay (Home & Collection Pages) ──────────
            if (hasHeroBanner)
              Positioned(
                top: promoBarHeight,
                left: 0,
                right: 0,
                child: const PebbleHeader(),
              ),

            // ── Mega menu OVERLAY ───────────────────────────
            Positioned(
              top: promoBarHeight + (hasHeroBanner && !isScrolled ? 72 : 64),
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: activeMenu == null,
                child: AnimatedBuilder(
                  animation: _megaMenuController,
                  builder: (context, child) {
                    return ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: _megaMenuSize.value,
                        child: FadeTransition(
                          opacity: _megaMenuOpacity,
                          child: SlideTransition(
                            position: _megaMenuSlide,
                            child: child,
                          ),
                        ),
                      ),
                    );
                  },
                  child: MouseRegion(
                    onEnter: (_) {
                      // Mouse entered mega menu — keep it open
                    },
                    onExit: (_) {
                      // Mouse left mega menu — close it
                      ref.read(activeMegaMenuProvider.notifier).state = null;
                    },
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: isFloating
                              ? AppDimensions.headerMaxWidth
                              : double.infinity,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: isFloating
                              ? (isWide ? 24 : 16)
                              : 0,
                        ),
                        child: Material(
                          color: activeMenu == 'features'
                              ? Colors.transparent
                              : Colors.white,
                          elevation: activeMenu == 'features' ? 0 : 8,
                          shadowColor: Colors.black.withValues(alpha: 0.12),
                          borderRadius: isFloating
                              ? const BorderRadius.vertical(
                                  bottom: Radius.circular(20),
                                )
                              : BorderRadius.zero,
                          clipBehavior: activeMenu == 'features'
                              ? Clip.none
                              : Clip.antiAlias,
                          child: Builder(
                        builder: (context) {
                          if (activeMenu == 'pages') {
                            return PagesMegaMenu(
                              menu: homeAsync.value?.pagesMenu,
                            );
                          }
                          if (activeMenu == 'features') {
                            return FeaturesMegaMenu(
                              items: homeAsync.value?.featuresMenu,
                            );
                          }
                          if (activeMenu == 'collections') {
                            return CollectionsMegaMenu(
                              menu: homeAsync.value?.collectionsMenu ??
                                  CollectionsMenuModel.fromJson(null),
                            );
                          }
                          return homeAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (homeData) {

                              if (activeMenu != 'shop') {
                                return const SizedBox.shrink();
                              }

                              return MegaMenu(
                                categories: homeData.featuredCategories,
                                shopMenu: homeData.shopMenu,
                                bannerImage: homeData.banners.isNotEmpty
                                    ? homeData.banners.first.image
                                    : '',
                                bannerCtaText: homeData.banners.isNotEmpty
                                    ? homeData.banners.first.ctaText.isNotEmpty
                                          ? homeData.banners.first.ctaText
                                          : 'Shop Now'
                                    : 'Shop Now',
                                bannerCtaLink: homeData.banners.isNotEmpty
                                    ? homeData.banners.first.ctaLink
                                    : '',
                                navKey: activeMenu ?? 'shop',
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

            // ── Scrim ─────────────────────────────────────────
            AnimatedOpacity(
              duration: const Duration(milliseconds: 280),
              opacity: isDrawerOpen ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: !isDrawerOpen,
                child: GestureDetector(
                  onTap: () =>
                      ref.read(cartDrawerOpenProvider.notifier).state = false,
                  child: Container(color: Colors.black.withValues(alpha: 0.4)),
                ),
              ),
            ),

            // ── Cart drawer ──────────────────────────────────
            AnimatedPositioned(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: isDrawerOpen ? 0 : -420,
              width: 420,
              child: const CartDrawer(),
            ),

            // ── Search overlay ───────────────────────────────
            if (isSearchOpen) const SearchOverlay(),
          ],
        ),
      );
    }

    // ── Mobile layout ────────────────────────────────────────
    final isMobileDrawerOpen = ref.watch(mobileNavDrawerOpenProvider);
    final isSearchOpenMobile = ref.watch(isSearchOpenProvider);

    return Scaffold(
      body: Stack(
        children: [
          widget.navigationShell,

          // ── Mobile Nav Drawer Scrim ────────────────────────
          AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isMobileDrawerOpen ? 1.0 : 0.0,
            child: IgnorePointer(
              ignoring: !isMobileDrawerOpen,
              child: GestureDetector(
                onTap: () =>
                    ref.read(mobileNavDrawerOpenProvider.notifier).state = false,
                child: Container(color: Colors.black.withValues(alpha: 0.45)),
              ),
            ),
          ),

          // ── Mobile Nav Drawer (slide from left) ────────────
          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            left: isMobileDrawerOpen ? 0 : -340,
            width: 320,
            child: const MobileNavDrawer(),
          ),

          // ── Search overlay ───────────────────────────────
          if (isSearchOpenMobile) const SearchOverlay(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: (index) => widget.navigationShell.goBranch(
            index,
            initialLocation: index == widget.navigationShell.currentIndex,
          ),
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          elevation: 0,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primary),
              label: 'Home',
            ),
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view, color: AppColors.primary),
              label: 'Shop',
            ),
            const NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite, color: AppColors.primary),
              label: 'Wishlist',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_bag_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cartCount > 0,
                label: Text('$cartCount'),
                child: const Icon(Icons.shopping_bag, color: AppColors.primary),
              ),
              label: 'Cart',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Promo announcement bar ─────────────────────────────────────
class _PromoAnnouncement extends StatelessWidget {
  final String text;
  const _PromoAnnouncement({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
