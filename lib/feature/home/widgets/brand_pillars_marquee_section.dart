import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/widgets/auto_pause_visibility.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';

/// 1:1 Implementation of Shopify Pebble Brand Pillars Marquee Ticker
/// (template--20816638214282__custom_section_AYwNN4).
///
/// Features:
/// - Background: signature Pebble neon lime #F6FD7C (color-scheme-6)
/// - Continuous horizontal auto-scrolling marquee ticker
/// - Pause marquee movement on hover (pointer enter / leave)
/// - Authentic pillar items:
///   - 32x32 genuine icon (StarFour, DropSimple, Heart)
///   - Title (e.g. "Comfort Products", "Organic Cotton", "Safety for Skin")
///   - White pill "shop" button navigating to /collections/all
class BrandPillarsMarqueeSection extends StatefulWidget {
  final List<BrandPillarItemModel> pillars;
  final Color? backgroundColor;

  const BrandPillarsMarqueeSection({
    super.key,
    required this.pillars,
    this.backgroundColor,
  });

  @override
  State<BrandPillarsMarqueeSection> createState() =>
      _BrandPillarsMarqueeSectionState();
}

class _BrandPillarsMarqueeSectionState extends State<BrandPillarsMarqueeSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final GlobalKey _cycleKey = GlobalKey();
  double _singleCycleWidth = 900.0;
  bool _isVisible = true;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    // 20s linear infinite loop matching reference data-duration="20.0"
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureCycle();
    });
  }

  void _measureCycle() {
    final box = _cycleKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.attached && box.hasSize && box.size.width > 0) {
      if (mounted) {
        setState(() {
          _singleCycleWidth = box.size.width;
        });
      }
    }
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
    if (widget.pillars.isEmpty) {
      return const SizedBox.shrink();
    }

    final bgColor = widget.backgroundColor ?? const Color(0xFFF6FD7C);

    return AutoPauseVisibility(
      onVisibilityChanged: _onVisibilityChanged,
      child: MouseRegion(
        onEnter: _onEnter,
        onExit: _onExit,
        cursor: SystemMouseCursors.basic,
        child: Container(
          width: double.infinity,
          color: bgColor,
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
                        children: _buildCycleItems(context),
                      ),
                      // Duplicated cycles to ensure seamless loop
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _buildCycleItems(context),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _buildCycleItems(context),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: _buildCycleItems(context),
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

  List<Widget> _buildCycleItems(BuildContext context) {
    final items = <Widget>[];

    for (final pillar in widget.pillars) {
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 32x32 genuine icon
              _buildIcon(pillar.icon),
              const SizedBox(width: 12),

              // Title text
              Text(
                pillar.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 18),

              // White pill "shop" button
              _PillarShopButton(
                text: pillar.buttonText.isNotEmpty ? pillar.buttonText : 'shop',
                onTap: () {
                  final link = pillar.buttonLink.trim();
                  if (link.isNotEmpty) {
                    context.go(link);
                  }
                },
              ),
            ],
          ),
        ),
      );
    }

    return items;
  }

  Widget _buildIcon(String iconUrl) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Image.network(
        iconUrl,
        width: 32,
        height: 32,
        cacheWidth: 96,
        gaplessPlayback: true,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.star_rounded,
          size: 28,
          color: Colors.black87,
        ),
      ),
    );
  }
}

/// Secondary white pill button for brand pillar marquee
class _PillarShopButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _PillarShopButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_PillarShopButton> createState() => _PillarShopButtonState();
}

class _PillarShopButtonState extends State<_PillarShopButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFFF1F5F9) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.12 : 0.04),
                blurRadius: _isHovered ? 6 : 2,
                offset: Offset(0, _isHovered ? 2 : 1),
              ),
            ],
          ),
          child: Text(
            widget.text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
