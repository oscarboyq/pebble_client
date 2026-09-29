import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/constants/app_strings.dart';
import 'package:pebble_type/core/providers/header_provider.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/feature/cart/providers/cart_drawer_provider.dart';
import 'package:pebble_type/feature/cart/providers/cart_provider.dart';
import 'package:pebble_type/feature/home/providers/home_provider.dart';

class PebbleHeader extends ConsumerWidget {
  const PebbleHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = context.isWide;
    final cartAsync = ref.watch(cartProvider);
    final cartCount = cartAsync.value?.items.length ?? 0;
    final activeMenu = ref.watch(activeMegaMenuProvider);
    final isScrolled = ref.watch(isHeaderScrolledProvider);
    final homeData = ref.watch(homeProvider).value;
    final storeSettings = homeData?.storeSettings;
    final headerItems = homeData?.headerMenu ?? const <Map<String, dynamic>>[];
    String? menuLabel(String key, String fallback) {
      if (headerItems.isEmpty && homeData?.hasManagedHeader != true) {
        return fallback;
      }
      for (final item in headerItems) {
        if (item['key'] == key) return '${item['label']}';
      }
      return null;
    }

    // Check if on home page
    String currentLocation = '/';
    try {
      currentLocation = GoRouterState.of(context).matchedLocation;
    } catch (_) {}
    final isHome =
        currentLocation == AppRoutes.dashboard || currentLocation == '/';
    final isShop = currentLocation == AppRoutes.home;
    final hasHeroBanner = isHome || isShop;
    final isDocked = hasHeroBanner ? isScrolled : true;
    final hasActiveMenu = activeMenu != null && !isDocked;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final targetMaxWidth = isDocked
        ? screenWidth
        : AppDimensions.headerMaxWidth.clamp(0.0, screenWidth);

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOutCubic,
        height: isDocked ? 64 : 60,
        constraints: BoxConstraints(maxWidth: targetMaxWidth),
        margin: EdgeInsets.only(
          left: isDocked ? 0 : (isWide ? 24 : 16),
          right: isDocked ? 0 : (isWide ? 24 : 16),
          top: isDocked ? 0 : 12,
          bottom: isDocked ? 0 : (hasActiveMenu ? 0 : 12),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isWide ? (isDocked ? 36 : 20) : 12,
        ),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isDocked
              ? BorderRadius.zero
              : (hasActiveMenu
                    ? const BorderRadius.vertical(top: Radius.circular(20))
                    : BorderRadius.circular(50)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: hasActiveMenu ? 0.04 : 0.08,
              ),
              blurRadius: isDocked ? 14 : 18,
              offset: Offset(0, isDocked ? 2 : (hasActiveMenu ? 0 : 4)),
            ),
          ],
        ),
        child: Row(
          children: [
            if (isWide) ...[
              // ── Left: Navigation Links with Down Arrows ───────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (menuLabel('shop', AppStrings.shop) != null)
                    _NavDropdownItem(
                      label: menuLabel('shop', AppStrings.shop)!,
                      isOpen: activeMenu == 'shop',
                      onTap: () {
                        final current = ref.read(activeMegaMenuProvider);
                        ref.read(activeMegaMenuProvider.notifier).state =
                            current == 'shop' ? null : 'shop';
                      },
                      onEnter: () {
                        ref.read(activeMegaMenuProvider.notifier).state =
                            'shop';
                      },
                    ),
                  const SizedBox(width: 4),
                  if (menuLabel('collections', AppStrings.collections) != null)
                    _NavDropdownItem(
                      label: menuLabel('collections', AppStrings.collections)!,
                      isOpen: activeMenu == 'collections',
                      onTap: () {
                        final current = ref.read(activeMegaMenuProvider);
                        ref.read(activeMegaMenuProvider.notifier).state =
                            current == 'collections' ? null : 'collections';
                      },
                      onEnter: () {
                        ref.read(activeMegaMenuProvider.notifier).state =
                            'collections';
                      },
                    ),
                  const SizedBox(width: 4),
                  if (menuLabel('pages', AppStrings.pages) != null)
                    _NavDropdownItem(
                      label: menuLabel('pages', AppStrings.pages)!,
                      isOpen: activeMenu == 'pages',
                      onTap: () {
                        final current = ref.read(activeMegaMenuProvider);
                        ref.read(activeMegaMenuProvider.notifier).state =
                            current == 'pages' ? null : 'pages';
                      },
                      onEnter: () {
                        ref.read(activeMegaMenuProvider.notifier).state =
                            'pages';
                      },
                    ),
                  const SizedBox(width: 4),
                  if (menuLabel('features', AppStrings.features) != null)
                    _NavDropdownItem(
                      label: menuLabel('features', AppStrings.features)!,
                      isOpen: activeMenu == 'features',
                      onTap: () {
                        final current = ref.read(activeMegaMenuProvider);
                        ref.read(activeMegaMenuProvider.notifier).state =
                            current == 'features' ? null : 'features';
                      },
                      onEnter: () {
                        ref.read(activeMegaMenuProvider.notifier).state =
                            'features';
                      },
                    ),
                ],
              ),
            ] else ...[
              // ── Mobile Menu Button ──────────────────────────────
              IconButton(
                icon: const Icon(
                  Icons.menu_rounded,
                  color: AppColors.textPrimary,
                ),
                tooltip: 'Menu',
                onPressed: () {
                  final current = ref.read(mobileNavDrawerOpenProvider);
                  ref.read(mobileNavDrawerOpenProvider.notifier).state =
                      !current;
                },
              ),
            ],

            // ── Center: Logo Branding ──────────────────────────────
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.dashboard),
                  child: _PebbleBrandLogo(logoUrl: storeSettings?.logo),
                ),
              ),
            ),

            // ── Right: Search Pill + Actions ───────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isWide) ...[
                  // Search Pill Input
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Builder(
                      builder: (searchContext) => GestureDetector(
                        onTap: () {
                          final box =
                              searchContext.findRenderObject() as RenderBox?;
                          if (box != null && box.hasSize) {
                            ref.read(searchAnchorProvider.notifier).state =
                                box.localToGlobal(Offset.zero) & box.size;
                          }
                          ref.read(activeMegaMenuProvider.notifier).state =
                              null;
                          ref.read(isSearchOpenProvider.notifier).state = true;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'What are you looking for?',
                                style: GoogleFonts.bricolageGrotesque(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF757575),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(
                                Icons.search,
                                size: 18,
                                color: Color(0xFF111111),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ] else ...[
                  IconButton(
                    tooltip: 'Search',
                    icon: const Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () {
                      ref.read(activeMegaMenuProvider.notifier).state = null;
                      ref.read(searchAnchorProvider.notifier).state = null;
                      ref.read(isSearchOpenProvider.notifier).state = true;
                    },
                  ),
                ],

                // Profile Icon
                IconButton(
                  tooltip: 'Profile',
                  icon: const Icon(
                    Icons.person_outline,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  onPressed: () => context.go(AppRoutes.profile),
                ),

                // Cart Icon with Badge
                IconButton(
                  tooltip: 'Cart',
                  icon: Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text(
                      '$cartCount',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    backgroundColor: AppColors.primary,
                    textColor: Colors.white,
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: AppColors.textPrimary,
                      size: 20,
                    ),
                  ),
                  onPressed: () =>
                      ref.read(cartDrawerOpenProvider.notifier).state = !ref
                          .read(cartDrawerOpenProvider),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dropdown Nav Item with Down Chevron ──────────────────────────────
class _NavDropdownItem extends StatelessWidget {
  final String label;
  final bool isOpen;
  final VoidCallback onTap;
  final VoidCallback onEnter;

  const _NavDropdownItem({
    required this.label,
    required this.isOpen,
    required this.onTap,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.opaque,
      onEnter: (_) => onEnter(),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isOpen ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isOpen ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: isOpen
                    ? Colors.white
                    : AppColors.textPrimary.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Brand Logo (Dynamic backend logo or Styled Pebble typography) ────
class _PebbleBrandLogo extends StatelessWidget {
  final String? logoUrl;
  const _PebbleBrandLogo({this.logoUrl});

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return Image.network(
        logoUrl!,
        height: 28,
        cacheHeight: 84,
        gaplessPlayback: true,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _defaultTextLogo(),
      );
    }
    return _defaultTextLogo();
  }

  Widget _defaultTextLogo() {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'little ',
            style: GoogleFonts.caveat(
              fontSize: 26,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF111111),
            ),
          ),
          TextSpan(
            text: 'PEBBLE',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: const Color(0xFF111111),
            ),
          ),
        ],
      ),
    );
  }
}
