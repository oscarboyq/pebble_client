import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Hero action with a trailing ink segment that grows across the pill.
class AnimatedArrowPill extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  const AnimatedArrowPill({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  State<AnimatedArrowPill> createState() => _AnimatedArrowPillState();
}

class _AnimatedArrowPillState extends State<AnimatedArrowPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _arrowController;
  bool _hovered = false;
  bool _focused = false;

  bool get _active => _hovered || _focused;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );
  }

  void _updateMotion() {
    if (_active && widget.onPressed != null) {
      if (!_arrowController.isAnimating) _arrowController.repeat();
    } else {
      _arrowController.stop();
      _arrowController.reset();
    }
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.bricolageGrotesque(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF111111),
    );
    final measurement = TextPainter(
      text: TextSpan(text: widget.label, style: textStyle),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final width = math.max(170.0, measurement.width + 76).clamp(170.0, 280.0);
    final enabled = widget.onPressed != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onHover: (value) {
            if (_hovered == value) return;
            setState(() => _hovered = value);
            _updateMotion();
          },
          onFocusChange: (value) {
            if (_focused == value) return;
            setState(() => _focused = value);
            _updateMotion();
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: width,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    key: const ValueKey('hero-cta-fill'),
                    duration: const Duration(milliseconds: 430),
                    curve: Curves.easeInOutCubic,
                    left: _active ? 0 : width - 38,
                    right: _active ? 0 : 8,
                    top: _active ? 0 : 8,
                    bottom: _active ? 0 : 8,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xFF080808),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 22, right: 42),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 260),
                          style: textStyle.copyWith(
                            color: _active
                                ? Colors.white
                                : const Color(0xFF111111),
                          ),
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    bottom: 8,
                    right: 10,
                    child: AnimatedBuilder(
                      animation: _arrowController,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(
                          _active ? -12 + 12 * _arrowController.value : 0,
                          0,
                        ),
                        child: child,
                      ),
                      child: const SizedBox(
                        width: 28,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
