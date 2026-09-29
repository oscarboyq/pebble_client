import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/theme/app_text_styles.dart';
import 'package:pebble_type/feature/orders/providers/order_provider.dart';

class OrderConfirmationPage extends ConsumerWidget {
  const OrderConfirmationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(lastOrderProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF2E7D32),
                  size: 44,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingLg),
              Text(
                'Order Placed!',
                style: AppTextStyles.headlineLg,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              if (order != null)
                Text(
                  'Order #${order.id}',
                  style: AppTextStyles.bodyLg.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: AppDimensions.spacingXl),
              if (order != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Row('Shipping to', order.fullName),
                      _Row('Address', order.addressLine1),
                      _Row(
                        '',
                        '${order.city}, ${order.state} ${order.postalCode}',
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      _Row(
                        'Subtotal',
                        '\$${order.subtotalAmount.toStringAsFixed(2)}',
                      ),
                      if (order.discountAmount > 0)
                        _Row(
                          order.appliedOfferName.isEmpty
                              ? 'Discount'
                              : order.appliedOfferName,
                          '-\$${order.discountAmount.toStringAsFixed(2)}',
                        ),
                      _Row(
                        'Total',
                        '\$${order.totalAmount.toStringAsFixed(2)}',
                        bold: true,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppDimensions.spacingXl),
              TextButton(
                onPressed: () => context.push(AppRoutes.orders),
                child: const Text('View My Orders'),
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Continue Shopping',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _Row(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingXm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty)
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          Expanded(
            child: Text(
              value,
              style: bold
                  ? AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w600)
                  : AppTextStyles.bodyMd,
            ),
          ),
        ],
      ),
    );
  }
}
