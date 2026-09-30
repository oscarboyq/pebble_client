import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/theme/app_text_styles.dart';
import 'package:pebble_type/core/services/order_service.dart';
import 'package:pebble_type/feature/orders/models/order_model.dart';
import 'package:pebble_type/feature/orders/providers/order_provider.dart';

class OrderConfirmationPage extends ConsumerStatefulWidget {
  final int? orderId;
  const OrderConfirmationPage({super.key, this.orderId});

  @override
  ConsumerState<OrderConfirmationPage> createState() =>
      _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends ConsumerState<OrderConfirmationPage> {
  OrderModel? _loadedOrder;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final cached = ref.read(lastOrderProvider);
    if (widget.orderId != null && cached?.id != widget.orderId) {
      _loading = true;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final order = await OrderService.getOrder(widget.orderId!);
      if (mounted) {
        setState(() {
          _loadedOrder = order;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cached = ref.watch(lastOrderProvider);
    final order = (widget.orderId == null || cached?.id == widget.orderId)
        ? cached ?? _loadedOrder
        : _loadedOrder;

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order confirmation')),
        body: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Order details are unavailable.'),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.orders),
                      child: const Text('View My Orders'),
                    ),
                  ],
                ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingLg),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - AppDimensions.spacingLg * 2,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
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
                      Text(
                        'Order #${order.id}',
                        style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXl),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppDimensions.spacingMd),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusLg,
                          ),
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
                      const Text(
                        'You can follow this order from your account as the store updates it.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),
                      SizedBox(
                        width: double.infinity,
                        height: AppDimensions.buttonHeight,
                        child: ElevatedButton(
                          onPressed: () => context.push(
                            '${AppRoutes.orderDetail}/${order.id}',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd,
                              ),
                            ),
                          ),
                          child: Text(
                            'Track This Order',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.home),
                        child: const Text('Continue Shopping'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
