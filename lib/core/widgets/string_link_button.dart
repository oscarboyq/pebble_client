import 'package:flutter/material.dart';

class StringLinkButton extends StatelessWidget {
  final AlignmentGeometry alignment;
  final VoidCallback? onPressed;
  final String label;
  const StringLinkButton({
    super.key,
    required this.alignment,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: TextButton(
        style: TextButton.styleFrom(
          splashFactory: NoSplash.splashFactory,
          overlayColor: Colors.transparent,
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(fontSize: 13, decoration: TextDecoration.underline),
        ),
      ),
    );
  }
}
