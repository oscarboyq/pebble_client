import 'package:flutter/material.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;
  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'confirmed' => (const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      'shipped' => (const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
      'delivered' => (const Color(0xFFEDE7F6), const Color(0xFF4527A0)),
      'cancelled' => (const Color(0xFFFFEBEE), AppColors.error),
      _ => (const Color(0xFFFFF8E1), const Color(0xFFF57F17)), // pending
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
