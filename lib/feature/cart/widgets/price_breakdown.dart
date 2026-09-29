import 'package:flutter/material.dart';
import 'package:pebble_type/feature/cart/models/cart_model.dart';

/// Displays the exact quote returned by the pricing API.
class PriceBreakdown extends StatelessWidget {
  final CartModel cart;

  const PriceBreakdown({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    final secondary = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.68);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _row('Subtotal', cart.subtotal, color: secondary),
        if (cart.discount > 0) ...[
          const SizedBox(height: 8),
          _row(
            cart.appliedOffer?.name ?? 'Discount',
            -cart.discount,
            color: secondary,
          ),
        ],
        if (cart.couponError != null) ...[
          const SizedBox(height: 8),
          Text(
            cart.couponError!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
        const SizedBox(height: 10),
        const Divider(height: 1),
        const SizedBox(height: 10),
        _row('Total', cart.total, bold: true),
      ],
    );
  }

  Widget _row(String label, double amount, {Color? color, bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 17 : 13,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: color,
    );
    final prefix = amount < 0 ? '-' : '';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(label, style: style, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 12),
        Text('$prefix\$${amount.abs().toStringAsFixed(2)}', style: style),
      ],
    );
  }
}
