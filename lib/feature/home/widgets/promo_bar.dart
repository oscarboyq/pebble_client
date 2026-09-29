import 'package:flutter/material.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';

class PromoBar extends StatelessWidget {
  final PromoBarModel promoBar;
  const PromoBar({super.key, required this.promoBar});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        promoBar.text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
