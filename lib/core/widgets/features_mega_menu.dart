import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/providers/header_provider.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/home/providers/home_provider.dart';

class FeaturesMegaMenu extends ConsumerStatefulWidget {
  final List<FeaturesMenuItemModel>? items;

  const FeaturesMegaMenu({super.key, this.items});

  @override
  ConsumerState<FeaturesMegaMenu> createState() => _FeaturesMegaMenuState();
}

class _FeaturesMegaMenuState extends ConsumerState<FeaturesMegaMenu> {
  // Default to 0 so the first flyout ("Collections >") is open on hover, matching Screenshot 4
  int? _hoveredIndex = 0;

  static final List<FeaturesMenuItemModel> _defaultItems = [
    FeaturesMenuItemModel(
      id: 1,
      title: 'Collections',
      route: '/collections',
      order: 0,
      subItems: [
        FeaturesMenuSubItemModel(
          id: 1,
          title: 'Collection List',
          route: '/collections',
          order: 0,
        ),
        FeaturesMenuSubItemModel(
          id: 2,
          title: 'Minimal',
          route: '/collections',
          order: 1,
        ),
        FeaturesMenuSubItemModel(
          id: 3,
          title: 'With Collection Cards',
          route: '/collections',
          order: 2,
        ),
        FeaturesMenuSubItemModel(
          id: 4,
          title: 'With banner',
          route: '/collections',
          order: 3,
        ),
        FeaturesMenuSubItemModel(
          id: 5,
          title: 'With full wide banner',
          route: '/collections',
          order: 4,
        ),
      ],
    ),
    FeaturesMenuItemModel(
      id: 2,
      title: 'Product Gallery',
      route: '/products',
      order: 1,
      subItems: [
        FeaturesMenuSubItemModel(
          id: 6,
          title: 'Vertical Thumbnails',
          route: '/products',
          order: 0,
        ),
        FeaturesMenuSubItemModel(
          id: 7,
          title: 'Inside Thumbnails',
          route: '/products',
          order: 1,
        ),
        FeaturesMenuSubItemModel(
          id: 8,
          title: '2 Columns',
          route: '/products',
          order: 2,
        ),
      ],
    ),
    FeaturesMenuItemModel(
      id: 3,
      title: 'Product Flash Sale',
      route: '/products?sale=true',
      order: 2,
      subItems: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final homeAsync = ref.watch(homeProvider);
    final menuItems = (widget.items != null && widget.items!.isNotEmpty)
        ? widget.items!
        : (homeAsync.value?.featuresMenu.isNotEmpty == true
            ? homeAsync.value!.featuresMenu
            : _defaultItems);

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppDimensions.headerMaxWidth),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              // Position directly beneath the "Features ▾" button (offset ~280px from left)
              padding: const EdgeInsets.only(left: 280),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Primary Dropdown Panel ─────────────────────
                  Container(
                    width: 230,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(menuItems.length, (index) {
                        final item = menuItems[index];
                        final isHovered = _hoveredIndex == index;
                        final hasSubItems = item.subItems.isNotEmpty;

                        return MouseRegion(
                          onEnter: (_) => setState(() => _hoveredIndex = index),
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              ref.read(activeMegaMenuProvider.notifier).state =
                                  null;
                              _navigateTo(context, item.route);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isHovered
                                    ? const Color(0xFFF7F7F7)
                                    : Colors.transparent,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: GoogleFonts.bricolageGrotesque(
                                        fontSize: 14,
                                        fontWeight: isHovered
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isHovered
                                            ? AppColors.accentWarm
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (hasSubItems) ...[
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: isHovered
                                          ? AppColors.accentWarm
                                          : const Color(0xFF888888),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // ── Cascading Submenu Flyout ───────────────────
                  if (_hoveredIndex != null &&
                      _hoveredIndex! < menuItems.length &&
                      menuItems[_hoveredIndex!].subItems.isNotEmpty)
                    Positioned(
                      left: 234,
                      top: _hoveredIndex! * 44.0,
                      child: MouseRegion(
                        onEnter: (_) {},
                        child: Container(
                          width: 230,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 20,
                                offset: const Offset(4, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: menuItems[_hoveredIndex!].subItems.map((
                              sub,
                            ) {
                              return _FlyoutSubItemTile(
                                subItem: sub,
                                onSelected: () {
                                  ref
                                      .read(activeMegaMenuProvider.notifier)
                                      .state = null;
                                  _navigateTo(context, sub.route);
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlyoutSubItemTile extends ConsumerStatefulWidget {
  final FeaturesMenuSubItemModel subItem;
  final VoidCallback onSelected;

  const _FlyoutSubItemTile({
    required this.subItem,
    required this.onSelected,
  });

  @override
  ConsumerState<_FlyoutSubItemTile> createState() => _FlyoutSubItemTileState();
}

class _FlyoutSubItemTileState extends ConsumerState<_FlyoutSubItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onSelected,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFF7F7F7) : Colors.transparent,
          ),
          child: Text(
            widget.subItem.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 14,
              fontWeight: _isHovered ? FontWeight.w700 : FontWeight.w500,
              color: _isHovered ? AppColors.accentWarm : AppColors.textPrimary,
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
