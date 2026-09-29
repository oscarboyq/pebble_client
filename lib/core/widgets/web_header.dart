import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/feature/cart/providers/cart_drawer_provider.dart';
import 'package:pebble_type/feature/cart/providers/cart_provider.dart';

const _navLinks = [
  _NavLink('Home', AppRoutes.dashboard),
  _NavLink('Shop', AppRoutes.home),
  _NavLink('Wishlist', AppRoutes.wishlist),
  _NavLink('Orders', AppRoutes.orders),
];

class WebHeader extends ConsumerWidget {
  const WebHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final cartCount = cartAsync.value?.items.length ?? 0;
    final location = GoRouterState.of(context).matchedLocation;

    return Container(
      height: 64,

      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 40),

          // ── Logo ───────────────────────────────────────────────
          GestureDetector(
            onTap: () => context.go(AppRoutes.dashboard),
            child: const Text(
              'PEBBLE',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
                color: AppColors.primary,
              ),
            ),
          ),

          const Spacer(),

          // ── Nav links ─────────────────────────────────────────
          Row(
            children: _navLinks.map((link) {
              final isActive =
                  location == link.path ||
                  (link.path != AppRoutes.dashboard &&
                      location.startsWith(link.path));
              return _HeaderNavLink(
                label: link.label,
                path: link.path,
                isActive: isActive,
              );
            }).toList(),
          ),

          const Spacer(),

          // ── Action icons ──────────────────────────────────────
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search, color: AppColors.textPrimary),
            onPressed: () => context.go(AppRoutes.home),
          ),
          IconButton(
            tooltip: 'Wishlist',
            icon: const Icon(
              Icons.favorite_border,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.go(AppRoutes.wishlist),
          ),
          IconButton(
            tooltip: 'Cart',
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              backgroundColor: AppColors.primary,
              textColor: AppColors.surface,
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: AppColors.textPrimary,
              ),
            ),
            onPressed: () => ref.read(cartDrawerOpenProvider.notifier).state =
                !ref.read(cartDrawerOpenProvider),
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(
              Icons.person_outline,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.go(AppRoutes.profile),
          ),

          const SizedBox(width: 24),
        ],
      ),
    );
  }
}

class _HeaderNavLink extends StatefulWidget {
  final String label;
  final String path;
  final bool isActive;
  const _HeaderNavLink({
    required this.label,
    required this.path,
    required this.isActive,
  });

  @override
  State<_HeaderNavLink> createState() => __HeaderNavLinkState();
}

class __HeaderNavLinkState extends State<_HeaderNavLink> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final underlineVisible = widget.isActive || _hovered;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(widget.path),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: widget.isActive
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: widget.isActive
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 1.5,
                width: underlineVisible ? 20 : 0,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink {
  final String label;
  final String path;
  const _NavLink(this.label, this.path);
}
