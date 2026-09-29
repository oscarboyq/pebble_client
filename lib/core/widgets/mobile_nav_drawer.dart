import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/providers/header_provider.dart';
import 'package:pebble_type/feature/home/providers/home_provider.dart';

class MobileNavDrawer extends ConsumerStatefulWidget {
  const MobileNavDrawer({super.key});

  @override
  ConsumerState<MobileNavDrawer> createState() => _MobileNavDrawerState();
}

class _MobileNavDrawerState extends ConsumerState<MobileNavDrawer> {
  String? _expandedSection = 'shop';

  void _toggleSection(String section) {
    setState(() {
      _expandedSection = _expandedSection == section ? null : section;
    });
  }

  void _closeAndNavigate(String route) {
    ref.read(mobileNavDrawerOpenProvider.notifier).state = false;
    try {
      context.go(route);
    } catch (_) {
      context.go('/products');
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeProvider);
    final homeData = homeAsync.value;

    return Material(
      color: AppColors.surface,
      child: SizedBox(
        width: 320,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              // ── Top Header ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PEBBLE',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () {
                        ref.read(mobileNavDrawerOpenProvider.notifier).state =
                            false;
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),

              // ── Scrollable Menu Accordions ────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  children: [
                    // 1. Shop Accordion
                    _AccordionTile(
                      title: 'Shop',
                      isExpanded: _expandedSection == 'shop',
                      onTap: () => _toggleSection('shop'),
                      children: [
                        _DrawerSubLink(
                          label: 'New Arrivals',
                          badge: 'NEW',
                          onTap: () =>
                              _closeAndNavigate('/products?sort=newest'),
                        ),
                        _DrawerSubLink(
                          label: 'Best Sellers',
                          badge: 'HOT',
                          onTap: () =>
                              _closeAndNavigate('/products?sort=best_selling'),
                        ),
                        _DrawerSubLink(
                          label: 'All Clothing',
                          onTap: () =>
                              _closeAndNavigate('/collections/clothing'),
                        ),
                        _DrawerSubLink(
                          label: 'Shop All',
                          onTap: () => _closeAndNavigate('/collections/all'),
                        ),
                        if (homeData != null &&
                            homeData.shopMenu
                                .categoriesFor('new_arrivals')
                                .isNotEmpty) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 8,
                            ),
                            child: Text(
                              'CATEGORIES',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          ...homeData.shopMenu
                              .categoriesFor('new_arrivals')
                              .take(8)
                              .map(
                                (cat) => _DrawerSubLink(
                                  label: cat.name,
                                  onTap: () => _closeAndNavigate(
                                    '/products?category=${cat.slug}',
                                  ),
                                ),
                              ),
                        ],
                      ],
                    ),

                    // 2. Collections Accordion
                    _AccordionTile(
                      title: 'Collections',
                      isExpanded: _expandedSection == 'collections',
                      onTap: () => _toggleSection('collections'),
                      children: [
                        _DrawerSubLink(
                          label: 'Winter Seasonal',
                          onTap: () => _closeAndNavigate('/products'),
                        ),
                        _DrawerSubLink(
                          label: 'Comfort Style',
                          onTap: () => _closeAndNavigate('/products'),
                        ),
                        _DrawerSubLink(
                          label: 'Everyday Comfort',
                          onTap: () => _closeAndNavigate('/products'),
                        ),
                        _DrawerSubLink(
                          label: "Boy's Collection",
                          onTap: () =>
                              _closeAndNavigate('/products?gender=boys'),
                        ),
                        _DrawerSubLink(
                          label: "Girl's Collection",
                          onTap: () =>
                              _closeAndNavigate('/products?gender=girls'),
                        ),
                      ],
                    ),

                    // 3. Pages Accordion
                    _AccordionTile(
                      title: 'Pages',
                      isExpanded: _expandedSection == 'pages',
                      onTap: () => _toggleSection('pages'),
                      children: [
                        _DrawerSubLink(
                          label: 'Our Story',
                          onTap: () => _closeAndNavigate('/pages/our-story'),
                        ),
                        _DrawerSubLink(
                          label: 'FAQs',
                          onTap: () => _closeAndNavigate('/pages/faqs'),
                        ),
                        _DrawerSubLink(
                          label: 'Contact Us',
                          onTap: () => _closeAndNavigate('/pages/contact'),
                        ),
                        _DrawerSubLink(
                          label: 'Find A Store',
                          onTap: () => _closeAndNavigate('/pages/find-a-store'),
                        ),
                        _DrawerSubLink(
                          label: 'Our Journal',
                          onTap: () => _closeAndNavigate('/pages/our-journal'),
                        ),
                        _DrawerSubLink(
                          label: 'Help Center',
                          onTap: () => _closeAndNavigate('/pages/help-center'),
                        ),
                        _DrawerSubLink(
                          label: 'Size & Fit Guide',
                          onTap: () => _closeAndNavigate('/pages/size-guide'),
                        ),
                        _DrawerSubLink(
                          label: 'Returns & Refunds',
                          onTap: () =>
                              _closeAndNavigate('/pages/returns-refunds'),
                        ),
                      ],
                    ),

                    // 4. Features Accordion
                    _AccordionTile(
                      title: 'Features',
                      isExpanded: _expandedSection == 'features',
                      onTap: () => _toggleSection('features'),
                      children: [
                        _DrawerSubLink(
                          label: '3-Step Outfit Builder',
                          badge: 'TRY IT',
                          onTap: () => _closeAndNavigate('/'),
                        ),
                        _DrawerSubLink(
                          label: 'Mix Your Style (Layered Cards)',
                          onTap: () => _closeAndNavigate('/'),
                        ),
                        _DrawerSubLink(
                          label: 'Lookbook Hotspots (Shop The Look)',
                          onTap: () => _closeAndNavigate('/'),
                        ),
                        _DrawerSubLink(
                          label: 'Bundle & Save (10% Off)',
                          onTap: () => _closeAndNavigate('/'),
                        ),
                        _DrawerSubLink(
                          label: 'Product Gallery Modes',
                          onTap: () => _closeAndNavigate('/products'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Footer ───────────────────────────────────────────
              const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _closeAndNavigate('/profile'),
                      child: Text(
                        'My Account',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'USD \$',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccordionTile extends StatelessWidget {
  final String title;
  final bool isExpanded;
  final VoidCallback onTap;
  final List<Widget> children;

  const _AccordionTile({
    required this.title,
    required this.isExpanded,
    required this.onTap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: AnimatedRotation(
            turns: isExpanded ? 0.25 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ),
          onTap: onTap,
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

class _DrawerSubLink extends StatelessWidget {
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _DrawerSubLink({required this.label, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentWarm.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentWarm,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
