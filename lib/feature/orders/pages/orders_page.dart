import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/theme/app_text_styles.dart';
import 'package:pebble_type/feature/orders/models/order_model.dart';
import 'package:pebble_type/feature/orders/providers/order_provider.dart';
import 'package:pebble_type/feature/orders/widgets/order_status_badge.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          'My Orders',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: orderAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Failed to load orders.',
                style: TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              TextButton(
                onPressed: () => ref.invalidate(ordersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppColors.border,
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  Text(
                    'No orders yet',
                    style: AppTextStyles.bodyLg.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    'Your orders will appear here',
                    style: AppTextStyles.bodyMd,
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => ref.refresh(ordersProvider.future),
            child: ListView.separated(
              padding: EdgeInsets.all(AppDimensions.spacingMd),
              itemBuilder: (_, index) => Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: _OrderCard(
                    order: orders[index],
                    onOpen: () async {
                      await context.push(
                        '${AppRoutes.orderDetail}/${orders[index].id}',
                      );
                      if (context.mounted) ref.invalidate(ordersProvider);
                    },
                  ),
                ),
              ),
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppDimensions.spacingMd),
              itemCount: orders.length,
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onOpen;
  const _OrderCard({required this.order, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        padding: EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id}',
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                OrderStatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              '${order.items.length} item${order.items.length == 1 ? '' : 's'}',
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(order.createdAt),
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '\$${order.totalAmount.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyLg.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Track order  →',
                style: AppTextStyles.bodyMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
