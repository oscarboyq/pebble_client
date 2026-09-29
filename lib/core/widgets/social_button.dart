import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final String iconAsset;
  const SocialButton({
    super.key,
    required this.label,
    this.onTap,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            SvgPicture.asset(iconAsset, width: 18, height: 18),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}
