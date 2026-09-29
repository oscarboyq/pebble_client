import 'package:flutter/material.dart';
import 'package:pebble_type/core/constants/app_colors.dart';

class StarRating extends StatelessWidget {
  final int rating; // current value 1–5
  final int maxStars;
  final double size;
  final bool interactive;
  final void Function(int)? onChanged;

  const StarRating({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.size = 20,
    this.interactive = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (i) {
        final filled = i < rating;
        return GestureDetector(
          onTap: interactive ? () => onChanged?.call(i + 1) : null,
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: filled ? const Color(0xFFFFC107) : AppColors.border,
          ),
        );
      }),
    );
  }
}
