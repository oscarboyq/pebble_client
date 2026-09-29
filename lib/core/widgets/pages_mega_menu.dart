import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/providers/header_provider.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/providers/home_provider.dart';

class PagesMegaMenu extends ConsumerWidget {
  final PagesMenuModel? menu;

  const PagesMegaMenu({super.key, this.menu});

  static const List<_PageLinkItem> _defaultLinks = [
    _PageLinkItem(label: 'Our Story', route: '/pages/our-story'),
    _PageLinkItem(label: 'FAQs', route: '/pages/faqs'),
    _PageLinkItem(label: 'Contact Us', route: '/pages/contact'),
    _PageLinkItem(label: 'Find A Store', route: '/pages/find-a-store'),
    _PageLinkItem(label: 'Our Journal', route: '/pages/our-journal'),
    _PageLinkItem(label: 'Help Center', route: '/pages/help-center'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeProvider);
    final activeMenu = menu ?? homeAsync.value?.pagesMenu;

    final whoWeAreTitle = activeMenu?.setting.whoWeAreTitle.isNotEmpty == true
        ? activeMenu!.setting.whoWeAreTitle
        : 'Who We Are';
    final whoWeAreText = activeMenu?.setting.whoWeAreText.isNotEmpty == true
        ? activeMenu!.setting.whoWeAreText
        : 'We create simple, well-made essentials that balance comfort and style, giving kids the freedom to explore, play, and grow every day.';

    final cards = (activeMenu != null && activeMenu.cards.isNotEmpty)
        ? activeMenu.cards
        : [
            PagesMenuCardModel(
              id: 1,
              title: 'Our Story',
              image:
                  'https://pebble-little.myshopify.com/cdn/shop/files/menu-collection-banner-3-v2.webp',
              route: '/pages/our-story',
              order: 0,
            ),
            PagesMenuCardModel(
              id: 2,
              title: 'Our Journal',
              image:
                  'https://pebble-little.myshopify.com/cdn/shop/files/menu-collection-banner-4-v2.webp',
              route: '/pages/our-journal',
              order: 1,
            ),
          ];

    final links = (activeMenu != null && activeMenu.links.isNotEmpty)
        ? activeMenu.links
              .map((l) => _PageLinkItem(label: l.label, route: l.route))
              .toList()
        : _defaultLinks;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppDimensions.headerMaxWidth,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Column 1 (Left): Brand Editorial Statement ─────
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.only(right: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        whoWeAreTitle,
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        whoWeAreText,
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 14,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          _PebbleBadgeChip(
                            icon: Icons.eco_outlined,
                            label: 'Everyday Comfort',
                          ),
                          _PebbleBadgeChip(
                            icon: Icons.child_care_outlined,
                            label: 'Made for Play',
                          ),
                          _PebbleBadgeChip(
                            icon: Icons.all_inclusive_outlined,
                            label: 'Conscious Living',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Column 2 (Center): Dual Visual Cards ───────────
              Expanded(
                flex: 5,
                child: Row(
                  children: [
                    if (cards.isNotEmpty)
                      Expanded(
                        child: _EditorialCard(
                          title: cards[0].title,
                          imageUrl:
                              cards[0].image ??
                              'https://pebble-little.myshopify.com/cdn/shop/files/menu-collection-banner-3-v2.webp',
                          route: cards[0].route,
                        ),
                      ),
                    if (cards.length > 1) ...[
                      const SizedBox(width: 20),
                      Expanded(
                        child: _EditorialCard(
                          title: cards[1].title,
                          imageUrl:
                              cards[1].image ??
                              'https://pebble-little.myshopify.com/cdn/shop/files/menu-collection-banner-4-v2.webp',
                          route: cards[1].route,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 36),
              const SizedBox(
                height: 240,
                child: VerticalDivider(width: 1, color: AppColors.border),
              ),
              const SizedBox(width: 36),

              // ── Column 3 (Right): Vertical Navigation Links ────
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Pebble',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...links.map(
                      (link) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: _PageTextLink(link: link),
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

class _PageLinkItem {
  final String label;
  final String route;

  const _PageLinkItem({required this.label, required this.route});
}

class _PageTextLink extends ConsumerStatefulWidget {
  final _PageLinkItem link;

  const _PageTextLink({required this.link});

  @override
  ConsumerState<_PageTextLink> createState() => _PageTextLinkState();
}

class _PageTextLinkState extends ConsumerState<_PageTextLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          ref.read(activeMegaMenuProvider.notifier).state = null;
          _navigateTo(context, widget.link.route);
        },
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 15,
            fontWeight: _isHovered ? FontWeight.w700 : FontWeight.w500,
            color: _isHovered ? AppColors.accentWarm : AppColors.textPrimary,
          ),
          child: Text(widget.link.label),
        ),
      ),
    );
  }
}

class _PebbleBadgeChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PebbleBadgeChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accentWarm),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialCard extends ConsumerStatefulWidget {
  final String title;
  final String imageUrl;
  final String route;

  const _EditorialCard({
    required this.title,
    required this.imageUrl,
    required this.route,
  });

  @override
  ConsumerState<_EditorialCard> createState() => _EditorialCardState();
}

class _EditorialCardState extends ConsumerState<_EditorialCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          ref.read(activeMegaMenuProvider.notifier).state = null;
          _navigateTo(context, widget.route);
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E5E5)),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image with subtle hover scale
                AnimatedScale(
                  scale: _isHovered ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) {
                      return Container(
                        color: const Color(0xFFEAEAEA),
                        child: Center(
                          child: Icon(
                            Icons.auto_stories_outlined,
                            size: 36,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Subtle gradient overlay for text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                        stops: const [0.5, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // Bottom Content Bar
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: GoogleFonts.bricolageGrotesque(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _isHovered
                              ? AppColors.accentWarm
                              : Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: _isHovered
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _navigateTo(BuildContext context, String route) {
  try {
    context.go(route);
  } catch (_) {
    context.go('/products');
  }
}
