import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/services/storage_service.dart';
import 'package:pebble_type/core/theme/app_text_styles.dart';
import 'package:pebble_type/feature/cart/models/cart_model.dart';
import 'package:pebble_type/feature/cart/providers/cart_provider.dart';
import 'package:pebble_type/feature/cart/widgets/price_breakdown.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text('Cart', style: AppTextStyles.pageTitle),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        actions: [
          cartAsync.value != null
              ? TextButton(
                  onPressed: () => ref.read(cartProvider.notifier).clearCart(),
                  child: Text(
                    'Clear',
                    style: TextStyle(color: AppColors.error),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
      body: cartAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, stackTrace) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Failed to load cart.',
                  style: TextStyle(color: AppColors.error),
                ),
                SizedBox(height: AppDimensions.spacingMd),
                TextButton(
                  onPressed: () => ref.invalidate(cartProvider),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        },
        data: (cart) {
          if (cart.items.isEmpty) return _EmptyCart();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: _CartContent(cart),
            ),
          );
        },
      ),
    );
  }
}

// empty state  ----------------------------------------------------------

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64, color: AppColors.border),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            'Your cart is empty',
            style: AppTextStyles.bodyLg.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text('Add some products to get started', style: AppTextStyles.bodyMd),
        ],
      ),
    );
  }
}

// Cart content + sticky total bar -----------------------------------------------------

class _CartContent extends ConsumerWidget {
  final CartModel cart;
  const _CartContent(this.cart);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compactHeight =
        MediaQuery.sizeOf(context).height -
            MediaQuery.viewInsetsOf(context).bottom <
        550;
    if (compactHeight) {
      return ListView(
        children: [
          ...cart.items.map(
            (item) => Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: _CartItemCard(item: item),
            ),
          ),
          _CouponEntry(cart: cart),
          _OrderSummary(cart: cart),
        ],
      );
    }
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(AppDimensions.spacingMd),
            itemBuilder: (_, index) => _CartItemCard(item: cart.items[index]),
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.spacingMd),
            itemCount: cart.items.length,
          ),
        ),
        _CouponEntry(cart: cart),
        _OrderSummary(cart: cart),
      ],
    );
  }
}

class _CouponEntry extends ConsumerStatefulWidget {
  final CartModel cart;
  const _CouponEntry({required this.cart});

  @override
  ConsumerState<_CouponEntry> createState() => _CouponEntryState();
}

class _CouponEntryState extends ConsumerState<_CouponEntry> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Enter a coupon code.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(cartProvider.notifier).applyCoupon(code);
      _controller.clear();
    } catch (error) {
      final data = error is DioException ? error.response?.data : null;
      if (mounted) {
        setState(
          () => _error = data is Map && data['detail'] is String
              ? data['detail'] as String
              : 'Could not apply this coupon.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _remove() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(cartProvider.notifier).removeCoupon();
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not remove the coupon.');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.cart.couponCode.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Coupon: ${widget.cart.couponCode}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: _busy ? null : _remove,
                  child: const Text('Remove'),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_busy,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _apply(),
                    decoration: const InputDecoration(
                      labelText: 'Coupon code',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _busy ? null : _apply,
                  child: const Text('Apply'),
                ),
              ],
            ),
          if (_error != null)
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

// Individual cart item widget -----------------------------------------------------

class _CartItemCard extends ConsumerWidget {
  final CartItemModel item;
  const _CartItemCard({required this.item});

  Future<void> _changeQuantity(
    BuildContext context,
    WidgetRef ref,
    int quantity,
  ) async {
    try {
      await ref
          .read(cartProvider.notifier)
          .updateItem(itemId: item.id, quantity: quantity);
    } catch (error) {
      final data = error is DioException ? error.response?.data : null;
      final message = data is Map && data['detail'] is String
          ? data['detail'] as String
          : 'Could not update this quantity.';
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: SizedBox(
              width: 80,
              height: 80,
              child: item.product.primaryImageUrl != null
                  ? Image.network(
                      item.product.primaryImageUrl!,
                      fit: BoxFit.cover,
                      cacheWidth: 200,
                      gaplessPlayback: true,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),
          //info --------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppTextStyles.bodyLg,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.variant != null) ...[
                  const SizedBox(height: AppDimensions.spacingXm),
                  Text(
                    '${item.variant!.color} · ${item.variant!.size}',
                    style: AppTextStyles.bodyMd,
                  ),
                ],
                const SizedBox(height: AppDimensions.spacingSm),
                Text(
                  '\$${item.unitPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                // Quantity controls + remove button --------------------------------------------------------
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: item.quantity > 1
                          ? () =>
                                _changeQuantity(context, ref, item.quantity - 1)
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingMd,
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: AppTextStyles.bodyLg.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: () =>
                          _changeQuantity(context, ref, item.quantity + 1),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Remove ${item.product.name}',
                      onPressed: () => notifier.removeItem(item.id),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                        size: 20,
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

  Widget _placeholder() {
    return Container(
      color: AppColors.background,
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.border,
        size: 32,
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(
            color: onTap != null
                ? AppColors.border
                : AppColors.border.withAlpha(80),
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap != null
              ? AppColors.textPrimary
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// Order Summary bar -----------------------------------------------------

class _OrderSummary extends StatelessWidget {
  final CartModel cart;
  const _OrderSummary({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
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
        children: [
          PriceBreakdown(cart: cart),
          const SizedBox(height: AppDimensions.spacingMd),
          SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeight,
            child: ElevatedButton(
              onPressed: () async {
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
                foregroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
