import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pebble_type/core/constants/app_colors.dart';

/// Displays a live DD : HH : MM : SS countdown to [targetDate].
/// When the target passes, shows "Sale Ended".
class CountdownTimer extends StatefulWidget {
  /// The date/time to count down to.
  final DateTime targetDate;

  /// Small label shown above the digits (e.g. "Sale ends in").
  final String label;

  /// Text colour for the digit blocks. Defaults to white.
  final Color? digitColor;

  /// Background colour of each digit block. Defaults to primary.
  final Color? blockColor;

  const CountdownTimer({
    super.key,
    required this.targetDate,
    this.label = 'Sale ends in',
    this.digitColor,
    this.blockColor,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _remaining = _calcRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final next = _calcRemaining();
      if (mounted) setState(() => _remaining = next);
      if (next == Duration.zero) _timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Duration _calcRemaining() {
    final diff = widget.targetDate.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return Text(
        'Sale Ended',
        style: TextStyle(
          color: widget.digitColor ?? Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: (widget.digitColor ?? Colors.white).withOpacity(0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Block(
              value: days,
              unit: 'Days',
              color: widget.blockColor,
              textColor: widget.digitColor,
            ),
            _Sep(color: widget.digitColor),
            _Block(
              value: hours,
              unit: 'Hrs',
              color: widget.blockColor,
              textColor: widget.digitColor,
            ),
            _Sep(color: widget.digitColor),
            _Block(
              value: minutes,
              unit: 'Min',
              color: widget.blockColor,
              textColor: widget.digitColor,
            ),
            _Sep(color: widget.digitColor),
            _Block(
              value: seconds,
              unit: 'Sec',
              color: widget.blockColor,
              textColor: widget.digitColor,
            ),
          ],
        ),
      ],
    );
  }
}

class _Block extends StatelessWidget {
  final int value;
  final String unit;
  final Color? color;
  final Color? textColor;
  const _Block({
    required this.value,
    required this.unit,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.primary;
    final fg = textColor ?? Colors.white;
    return Container(
      width: 48,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              color: fg,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(
              color: fg.withOpacity(0.75),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Sep extends StatelessWidget {
  final Color? color;
  const _Sep({this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          color: (color ?? Colors.white).withOpacity(0.6),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
