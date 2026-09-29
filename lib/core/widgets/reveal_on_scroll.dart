import 'package:flutter/material.dart';

/// Wraps [child] in a fade + slide-up animation that triggers once when the
/// widget scrolls into the visible viewport.
///
/// Usage:
/// ```dart
/// RevealOnScroll(
///   delay: const Duration(milliseconds: 120), // optional stagger
///   child: MyWidget(),
/// )
/// ```
class RevealOnScroll extends StatefulWidget {
  final Widget child;

  /// Stagger delay before the animation starts once visibility is detected.
  final Duration delay;

  /// Pixels to translate vertically at the start (positive = slides up from below).
  final double slideOffset;

  /// Total animation duration.
  final Duration duration;

  /// Easing curve.
  final Curve curve;

  const RevealOnScroll({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.slideOffset = 38.0,
    this.duration = const Duration(milliseconds: 560),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<RevealOnScroll> createState() => _RevealOnScrollState();
}

class _RevealOnScrollState extends State<RevealOnScroll>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _offset;

  bool _revealed = false;
  ScrollPosition? _position;
  double? _triggerScrollOffset;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _ctrl, curve: widget.curve);
    _offset = Tween<double>(
      begin: widget.slideOffset,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: widget.curve));

    // Check on first frame — items already visible on load should animate in
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _triggerScrollOffset = null;
    // Reattach listener if the nearest Scrollable changes (e.g. after navigation)
    _position?.removeListener(_check);
    _position = Scrollable.maybeOf(context)?.position;
    _position?.addListener(_check);
  }

  void _check() {
    if (_revealed || !mounted) return;

    final currentPixels = _position?.pixels ?? 0.0;
    if (_triggerScrollOffset != null) {
      if (currentPixels >= _triggerScrollOffset!) {
        _reveal();
      }
      return;
    }

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;

    final topY = box.localToGlobal(Offset.zero).dy;
    final viewH = MediaQuery.sizeOf(context).height;

    // Trigger when the top edge enters the bottom 95% of the screen
    if (topY < viewH * 0.95) {
      _reveal();
    } else {
      _triggerScrollOffset = currentPixels + topY - (viewH * 0.95);
    }
  }

  void _reveal() {
    _revealed = true;
    _position?.removeListener(_check);
    if (widget.delay == Duration.zero) {
      if (mounted) _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(0, _offset.value),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
