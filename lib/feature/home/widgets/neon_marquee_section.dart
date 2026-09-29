import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/widgets/auto_pause_visibility.dart';

/// Full-width vibrant neon lime/yellow marquee ticker banner.
/// Matches Shopify reference custom_section_8WifFy (`color-scheme-6`).
class NeonMarqueeSection extends StatefulWidget {
  final List<String> items;
  const NeonMarqueeSection({super.key, this.items = const []});

  @override
  State<NeonMarqueeSection> createState() => _NeonMarqueeSectionState();
}

class _NeonMarqueeSectionState extends State<NeonMarqueeSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final GlobalKey _cycleKey = GlobalKey();
  double _singleCycleWidth = 720.0;
  bool _isVisible = true;
  bool _isHovered = false;

  static const List<String> _fallbackItems = [
    'Comfort Products',
    'PEBBLE',
    'Everyday Comfort',
    'PEBBLE',
    'Made for Play',
    'PEBBLE',
  ];

  @override
  void initState() {
    super.initState();
    // 20s linear infinite loop matching reference data-duration="20.0"
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = _cycleKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.attached && box.hasSize && box.size.width > 0) {
        setState(() {
          _singleCycleWidth = box.size.width;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(bool isVisible) {
    _isVisible = isVisible;
    _syncAnimationState();
  }

  void _onEnter(PointerEvent _) {
    _isHovered = true;
    _syncAnimationState();
  }

  void _onExit(PointerEvent _) {
    _isHovered = false;
    _syncAnimationState();
  }

  void _syncAnimationState() {
    if (_isVisible && !_isHovered) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutoPauseVisibility(
      onVisibilityChanged: _onVisibilityChanged,
      child: MouseRegion(
        onEnter: _onEnter,
        onExit: _onExit,
        cursor: SystemMouseCursors.basic,
        child: Container(
          width: double.infinity,
          color: const Color(
            0xFFF6FD7C,
          ), // Exact color-scheme-6 RGB(246, 253, 124)
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: ClipRect(
            child: RepaintBoundary(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final offset = -(_controller.value * _singleCycleWidth);
                    return Transform.translate(
                      offset: Offset(offset, 0),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // First cycle measured with GlobalKey
                      Row(
                        key: _cycleKey,
                        mainAxisSize: MainAxisSize.min,
                        children: _buildCycleItems(),
                      ),
                      // Duplicated cycles to ensure uninterrupted seamless infinite loop
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _buildCycleItems(),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _buildCycleItems(),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _buildCycleItems(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCycleItems() {
    final items = widget.items.isEmpty ? _fallbackItems : widget.items;
    return items.map((text) {
      final isPebble = text == 'PEBBLE';
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: isPebble
                ? GoogleFonts.bricolageGrotesque(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: 1.5,
                  )
                : const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    letterSpacing: 0.5,
                  ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ],
      );
    }).toList();
  }
}
