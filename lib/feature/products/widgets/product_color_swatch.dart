import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Visual colors for the variant names currently used by the catalog.
/// Combined names such as Cream/Brown are shown with a diagonal split.
class ProductColorPalette {
  static List<Color> forName(String name) {
    final parts = name.split('/');
    return parts.map(_singleColor).toList();
  }

  static Color _singleColor(String name) {
    switch (name.trim().toLowerCase()) {
      case 'black':
        return const Color(0xFF171717);
      case 'white':
        return Colors.white;
      case 'cream':
      case 'ivory':
      case 'off-white':
        return const Color(0xFFF2E9DA);
      case 'blue':
        return const Color(0xFF93B9DE);
      case 'navy':
        return const Color(0xFF244969);
      case 'green':
        return const Color(0xFF208E70);
      case 'forest green':
        return const Color(0xFF285D43);
      case 'olive':
        return const Color(0xFF858D5E);
      case 'sage':
        return const Color(0xFF84A999);
      case 'mint':
        return const Color(0xFF9DDAC8);
      case 'red':
        return const Color(0xFFBD3038);
      case 'cherry':
      case 'burgundy':
      case 'wine':
        return const Color(0xFF67212E);
      case 'pink':
        return const Color(0xFFE9ACC7);
      case 'dusty rose':
        return const Color(0xFFC9919E);
      case 'fade rose':
        return const Color(0xFFB96F7B);
      case 'brown':
      case 'chocolate':
        return const Color(0xFF967159);
      case 'beige':
      case 'tan':
      case 'khaki':
        return const Color(0xFFE8DCC4);
      case 'mud':
        return const Color(0xFF82715D);
      case 'grey':
      case 'gray':
      case 'charcoal':
        return const Color(0xFFBFC1C2);
      case 'purple':
      case 'violet':
      case 'lilac':
        return const Color(0xFF9878B1);
      case 'orange':
      case 'coral':
        return const Color(0xFFE49A56);
      case 'yellow':
      case 'mustard':
        return const Color(0xFFF0D55E);
      default:
        final hex = name.trim().replaceFirst('#', '');
        if (hex.length == 6) {
          final value = int.tryParse('FF$hex', radix: 16);
          if (value != null) return Color(value);
        }
        return const Color(0xFFD3D3D3);
    }
  }
}

class ProductColorSwatch extends StatelessWidget {
  final String name;
  final double width;
  final double height;
  final bool selected;

  const ProductColorSwatch({
    super.key,
    required this.name,
    this.width = 18,
    this.height = 18,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = ProductColorPalette.forName(name);
    return Semantics(
      label: '$name color',
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? Colors.black
                : Colors.black.withValues(alpha: 0.16),
            width: selected ? 2 : 1,
          ),
        ),
        child: CustomPaint(painter: _SwatchPainter(colors)),
      ),
    );
  }
}

class _SwatchPainter extends CustomPainter {
  final List<Color> colors;

  const _SwatchPainter(this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) return;
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.first);
    if (colors.length > 1) {
      final split = Path()
        ..moveTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(split, Paint()..color = colors[1]);
    }
  }

  @override
  bool shouldRepaint(covariant _SwatchPainter oldDelegate) =>
      !listEquals(oldDelegate.colors, colors);
}
