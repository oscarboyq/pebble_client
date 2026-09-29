import 'package:flutter/material.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/core/widgets/countdown_timer.dart';

/// Dark full-width banner shown below the hero slider.
/// Contains a sale message on the left and a live countdown on the right.
class SaleCountdownBanner extends StatelessWidget {
  /// Target end-date for the sale. Defaults to 3 days from build time.
  final DateTime? saleEnd;

  const SaleCountdownBanner({super.key, this.saleEnd});

  @override
  Widget build(BuildContext context) {
    final target = saleEnd ?? DateTime.now().add(const Duration(days: 3));
    final isWide = context.isWide;

    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A1A),
      padding: EdgeInsets.symmetric(
        vertical: isWide ? 22 : 16,
        horizontal: isWide ? 40 : 20,
      ),
      child: isWide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _LeftText(),
                CountdownTimer(
                  targetDate: target,
                  label: 'Sale ends in',
                  digitColor: Colors.white,
                  blockColor: Colors.white.withOpacity(0.12),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LeftText(),
                const SizedBox(height: 12),
                CountdownTimer(
                  targetDate: target,
                  label: 'Sale ends in',
                  digitColor: Colors.white,
                  blockColor: Colors.white.withOpacity(0.12),
                ),
              ],
            ),
    );
  }
}

class _LeftText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: const [
        Text(
          '🔥  LIMITED TIME SALE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Up to 40% off selected styles. While stocks last.',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
      ],
    );
  }
}
