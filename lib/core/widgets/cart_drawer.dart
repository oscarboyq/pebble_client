import 'package:flutter/material.dart';
import 'package:pebble_type/feature/cart/widgets/price_breakdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/services/storage_service.dart';
import 'package:pebble_type/core/theme/app_text_styles.dart';
import 'package:pebble_type/feature/cart/models/cart_model.dart';
import 'package:pebble_type/feature/cart/providers/cart_drawer_provider.dart';
import 'package:pebble_type/feature/cart/providers/cart_provider.dart';

/// Desktop slide-in cart drawer (420 px wide, right-anchored).
/// Hosted in MainShell via AnimatedPositioned inside a Stack.
class CartDrawer extends ConsumerWidget {
  const CartDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);

    return Material(
      elevation: 16,
      color: AppColors.surface,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────
          _DrawerHeader(),
          const Divider(height: 1, color: AppColors.border),

          // ── Body ────────────────────────────────────────────
          Expanded(
            child: cartAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (_, __) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Failed to load cart.',
                      style: TextStyle(color: AppColors.error),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    TextButton(
                      onPressed: () => ref.invalidate(cartProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (cart) => cart.items.isEmpty
                  ? const _EmptyDrawer()
                  : _DrawerItemList(items: cart.items),
            ),
          ),

          // ── Footer ──────────────────────────────────────────
          if (cartAsync.value != null && cartAsync.value!.items.isNotEmpty)
            _DrawerFooter(cart: cartAsync.value!),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _DrawerHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartProvider).value?.items.length ?? 0;

    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
        ),
        child: Row(
          children: [
            Text(
              'Your Cart',
              style: AppTextStyles.bodyLg.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: AppDimensions.spacingSm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
            const Spacer(),
            IconButton(
              tooltip: 'Close',
              icon: const Icon(Icons.close, color: AppColors.textPrimary),
              onPressed: () =>
                  ref.read(cartDrawerOpenProvider.notifier).state = false,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyDrawer extends StatelessWidget {
  const _EmptyDrawer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 52,
            color: AppColors.border,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'Your cart is empty',
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Add some products to get started',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Item list ─────────────────────────────────────────────────────────────────
class _DrawerItemList extends StatelessWidget {
  final List<CartItemModel> items;
  const _DrawerItemList({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(color: AppColors.border),
      itemBuilder: (_, i) => _DrawerItem(item: items[i]),
    );
  }
}

class _DrawerItem extends ConsumerWidget {
  final CartItemModel item;
  const _DrawerItem({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: SizedBox(
              width: 72,
              height: 72,
              child: item.product.primaryImageUrl != null
                  ? Image.network(
                      item.product.primaryImageUrl!,
                      fit: BoxFit.cover,
                      cacheWidth: 180,
                      gaplessPlayback: true,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.product.name,
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => notifier.removeItem(item.id),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (item.variant != null) ...[
                  const SizedBox(height: AppDimensions.spacingXm),
                  Text(
                    '${item.variant!.color} · ${item.variant!.size}',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.spacingSm),
                Row(
                  children: [
                    // Qty stepper
                    _QtyBtn(
                      icon: Icons.remove,
                      onTap: item.quantity > 1
                          ? () => notifier.updateItem(
                              itemId: item.id,
                              quantity: item.quantity - 1,
                            )
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '${item.quantity}',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _QtyBtn(
                      icon: Icons.add,
                      onTap: () => notifier.updateItem(
                        itemId: item.id,
                        quantity: item.quantity + 1,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${item.lineTotal.toStringAsFixed(2)}',
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    color: AppColors.background,
    child: const Icon(Icons.image_outlined, color: AppColors.border, size: 28),
  );
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          border: Border.all(
            color: onTap == null ? AppColors.border : AppColors.textSecondary,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 14,
          color: onTap == null ? AppColors.border : AppColors.textPrimary,
        ),
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────
class _DrawerFooter extends ConsumerWidget {
  final CartModel cart;
  const _DrawerFooter({required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingMd,
        AppDimensions.spacingMd,
        AppDimensions.spacingLg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PriceBreakdown(cart: cart),
          const SizedBox(height: 4),
          const Text(
            'Shipping details are entered at checkout. No payment is collected.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          // Checkout button
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeight,
            child: ElevatedButton(
              onPressed: () async {
                ref.read(cartDrawerOpenProvider.notifier).state = false;
                final token = await StorageService.getAccessToken();
                if (token == null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please sign in to proceed to checkout'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    context.push(AppRoutes.login);
                  }
                  return;
                }
                if (context.mounted) {
                  context.push(AppRoutes.checkout);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),

          // View full cart link
          GestureDetector(
            onTap: () {
              ref.read(cartDrawerOpenProvider.notifier).state = false;
              context.go(AppRoutes.cart);
            },
            child: const Text(
              'View full cart →',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
