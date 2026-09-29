import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/providers/header_provider.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';

class CollectionsMegaMenu extends StatelessWidget {
  final CollectionsMenuModel menu;

  const CollectionsMegaMenu({super.key, required this.menu});

  static final List<CollectionsMenuColumnModel> _defaultColumns = [
    CollectionsMenuColumnModel(
      id: 1,
      title: 'Featured',
      order: 0,
      links: [
        CollectionsMenuLinkModel(
          id: 1,
          label: 'New Arrivals',
          route: '/products?sort=newest',
          order: 0,
        ),
        CollectionsMenuLinkModel(
          id: 2,
          label: 'Best Sellers',
          route: '/products?sort=best_selling',
          order: 1,
        ),
        CollectionsMenuLinkModel(
          id: 3,
          label: 'Winter Seasonal',
          route: '/products',
          order: 2,
        ),
        CollectionsMenuLinkModel(
          id: 4,
          label: 'Comfort Style',
          route: '/products',
          order: 3,
        ),
        CollectionsMenuLinkModel(
          id: 5,
          label: 'Everyday Essentials',
          route: '/products',
          order: 4,
        ),
      ],
    ),
    CollectionsMenuColumnModel(
      id: 2,
      title: "Boy's",
      order: 1,
      links: [
        CollectionsMenuLinkModel(
          id: 6,
          label: 'Shorts',
          route: '/products?category=shorts',
          order: 0,
        ),
        CollectionsMenuLinkModel(
          id: 7,
          label: 'Shirts',
          route: '/products?category=shirts',
          order: 1,
        ),
        CollectionsMenuLinkModel(
          id: 8,
          label: 'T-Shirts',
          route: '/products?category=t-shirts',
          order: 2,
        ),
        CollectionsMenuLinkModel(
          id: 9,
          label: 'Sweaters',
          route: '/collections/sweaters',
          order: 3,
        ),
        CollectionsMenuLinkModel(
          id: 10,
          label: 'Coats & Jackets',
          route: '/products?category=coats-jackets',
          order: 4,
        ),
        CollectionsMenuLinkModel(
          id: 11,
          label: 'Pants',
          route: '/collections/pants',
          order: 5,
        ),
      ],
    ),
    CollectionsMenuColumnModel(
      id: 3,
      title: "Girl's",
      order: 2,
      links: [
        CollectionsMenuLinkModel(
          id: 12,
          label: 'The New',
          route: '/products?sort=newest',
          order: 0,
        ),
        CollectionsMenuLinkModel(
          id: 13,
          label: 'Pants',
          route: '/collections/pants',
          order: 1,
        ),
        CollectionsMenuLinkModel(
          id: 14,
          label: 'Shirts',
          route: '/products?category=shirts',
          order: 2,
        ),
        CollectionsMenuLinkModel(
          id: 15,
          label: 'Coats & Jackets',
          route: '/products?category=coats-jackets',
          order: 3,
        ),
        CollectionsMenuLinkModel(
          id: 16,
          label: 'Dresses',
          route: '/collections/girls-dresses',
          order: 4,
        ),
        CollectionsMenuLinkModel(
          id: 17,
          label: 'Sweaters',
          route: '/collections/sweaters',
          order: 5,
        ),
      ],
    ),
  ];

  static final List<CollectionsMenuPromoModel> _defaultPromos = [
    CollectionsMenuPromoModel(
      id: 1,
      title: 'Summer Sale Campaign',
      image:
          'https://pebble-little.myshopify.com/cdn/shop/files/menu-collection-banner-1-v2.webp',
      route: '/products?sale=true',
      order: 0,
    ),
    CollectionsMenuPromoModel(
      id: 2,
      title: 'Talkative Child',
      image:
          'https://pebble-little.myshopify.com/cdn/shop/files/menu-collection-banner-2-v2.webp',
      route: '/collections/all',
      order: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final displayColumns = menu.columns.isNotEmpty
        ? menu.columns
        : _defaultColumns;
    final displayPromos = menu.promos.isNotEmpty ? menu.promos : _defaultPromos;

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
              // ── Left: 3 text columns ────────────────────────────
              Expanded(
                flex: 4,
                child: _CollectionsColumns(columns: displayColumns),
              ),
              const SizedBox(width: 36),
              const SizedBox(
                height: 260,
                child: VerticalDivider(width: 1, color: AppColors.border),
              ),
              const SizedBox(width: 36),

              // ── Right: 2 promo cards side-by-side ───────────────
              Expanded(flex: 4, child: _PromoCards(promos: displayPromos)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionsColumns extends StatelessWidget {
  final List<CollectionsMenuColumnModel> columns;

  const _CollectionsColumns({required this.columns});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns.take(3).map((column) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  column.title,
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),
                ...column.links
                    .take(8)
                    .map(
                      (link) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _CollectionTextLink(link: link),
                      ),
                    ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CollectionTextLink extends ConsumerStatefulWidget {
  final CollectionsMenuLinkModel link;

  const _CollectionTextLink({required this.link});

  @override
  ConsumerState<_CollectionTextLink> createState() =>
      _CollectionTextLinkState();
}

class _CollectionTextLinkState extends ConsumerState<_CollectionTextLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          final route = widget.link.route.trim();
          if (route.isEmpty) return;
          ref.read(activeMegaMenuProvider.notifier).state = null;
          context.go(route);
        },
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 14,
            fontWeight: _hovered ? FontWeight.w700 : FontWeight.w500,
            color: _hovered ? AppColors.accentWarm : AppColors.textPrimary,
          ),
          child: Text(widget.link.label),
        ),
      ),
    );
  }
}

class _PromoCards extends StatelessWidget {
  final List<CollectionsMenuPromoModel> promos;

  const _PromoCards({required this.promos});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: promos.take(2).map((promo) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: _PromoCard(promo: promo),
          ),
        );
      }).toList(),
    );
  }
}

class _PromoCard extends ConsumerStatefulWidget {
  final CollectionsMenuPromoModel promo;

  const _PromoCard({required this.promo});

  @override
  ConsumerState<_PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends ConsumerState<_PromoCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          final route = widget.promo.route.trim();
          if (route.isEmpty) return;
          ref.read(activeMegaMenuProvider.notifier).state = null;
          context.go(route);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1.38,
                child: AnimatedScale(
                  scale: _hovered ? 1.04 : 1.0,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  child: widget.promo.image.isNotEmpty
                      ? Image.network(
                          widget.promo.image,
                          fit: BoxFit.cover,
                          cacheWidth: 600,
                          gaplessPlayback: true,
                          errorBuilder: (_, __, ___) =>
                              Container(color: const Color(0xFFEEEEEE)),
                        )
                      : Container(color: const Color(0xFFEEEEEE)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.promo.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _hovered
                          ? AppColors.accentWarm
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _hovered ? Colors.black : const Color(0xFFEEEEEE),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: _hovered ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
