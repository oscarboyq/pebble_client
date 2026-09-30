import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/feature/orders/models/order_model.dart';

class OrderTrackingTimeline extends StatelessWidget {
  final OrderModel order;
  const OrderTrackingTimeline({super.key, required this.order});

  static const _steps = [
    (
      'pending',
      'Order placed',
      'We received your order.',
      Icons.receipt_long_outlined,
    ),
    (
      'confirmed',
      'Confirmed',
      'Your order is being prepared.',
      Icons.check_circle_outline,
    ),
    (
      'shipped',
      'Shipped',
      'Your order is on its way.',
      Icons.local_shipping_outlined,
    ),
    ('delivered', 'Delivered', 'Your order has arrived.', Icons.home_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexWhere((step) => step.$1 == order.status);
    final cancelled = order.status == 'cancelled';
    final visibleSteps = cancelled ? _steps.take(1).toList() : _steps;
    final events = {
      for (final event in order.statusEvents) event.status: event,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Track your order',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          const Text(
            'Updates appear here as your order progresses.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 22),
          for (var index = 0; index < visibleSteps.length; index++)
            _StepRow(
              label: visibleSteps[index].$2,
              description: visibleSteps[index].$3,
              icon: visibleSteps[index].$4,
              event: events[visibleSteps[index].$1],
              completed: cancelled ? index == 0 : index <= currentIndex,
              current: !cancelled && index == currentIndex,
              last: index == visibleSteps.length - 1 && !cancelled,
            ),
          if (cancelled)
            _StepRow(
              label: 'Cancelled',
              description: 'This order was cancelled.',
              icon: Icons.cancel_outlined,
              event: events['cancelled'],
              completed: true,
              current: true,
              last: true,
              cancelled: true,
            ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final OrderStatusEventModel? event;
  final bool completed;
  final bool current;
  final bool last;
  final bool cancelled;

  const _StepRow({
    required this.label,
    required this.description,
    required this.icon,
    required this.event,
    required this.completed,
    required this.current,
    required this.last,
    this.cancelled = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = cancelled ? AppColors.error : const Color(0xFF24815C);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed ? activeColor : const Color(0xFFEDEDED),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: completed ? Colors.white : AppColors.textSecondary,
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: completed ? activeColor : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: current ? FontWeight.w700 : FontWeight.w600,
                      color: completed
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (event != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      DateFormat(
                        'MMM d, yyyy · h:mm a',
                      ).format(event!.occurredAt.toLocal()),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (event!.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(event!.note, style: const TextStyle(fontSize: 12)),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
