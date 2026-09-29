import 'dart:async';
import 'package:flutter/material.dart';

/// Lightweight, throttled visibility observer that notifies when a widget
/// enters or exits the visible scrollable viewport.
///
/// Designed specifically to pause 60fps animations, tickers, and videos
/// when scrolled off-screen without incurring per-frame layout or tree overhead.
class AutoPauseVisibility extends StatefulWidget {
  final Widget child;
  final ValueChanged<bool> onVisibilityChanged;
  final Duration throttleDuration;

  const AutoPauseVisibility({
    super.key,
    required this.child,
    required this.onVisibilityChanged,
    this.throttleDuration = const Duration(milliseconds: 150),
  });

  @override
  State<AutoPauseVisibility> createState() => _AutoPauseVisibilityState();
}

class _AutoPauseVisibilityState extends State<AutoPauseVisibility> {
  ScrollPosition? _scrollPosition;
  Timer? _throttleTimer;
  bool? _lastVisibility;
  double? _cachedContentY;
  double? _lastHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedContentY = null;
    final newPosition = Scrollable.maybeOf(context)?.position;
    if (newPosition != _scrollPosition) {
      _scrollPosition?.removeListener(_onScroll);
      _scrollPosition = newPosition;
      _scrollPosition?.addListener(_onScroll);
    }
  }

  @override
  void didUpdateWidget(covariant AutoPauseVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      _cachedContentY = null;
      _lastHeight = null;
    }
  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    _scrollPosition?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (_throttleTimer?.isActive ?? false) return;
    _throttleTimer = Timer(widget.throttleDuration, () {
      if (mounted) _checkVisibility();
    });
  }

  void _checkVisibility() {
    if (!mounted) return;

    final currentPixels = _scrollPosition?.pixels ?? 0.0;

    // Cache content coordinate relative to scrollable; lazy-evaluated only once
    if (_cachedContentY == null || _lastHeight == null) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.attached || !renderBox.hasSize) return;
      _lastHeight = renderBox.size.height;
      _cachedContentY = currentPixels + renderBox.localToGlobal(Offset.zero).dy;
    }

    final height = _lastHeight!;
    final itemTop = _cachedContentY! - currentPixels;
    final itemBottom = itemTop + height;
    final viewportHeight = MediaQuery.sizeOf(context).height;

    // Generous buffer of 200px so animations start slightly before arriving on screen
    final isVisible = itemBottom >= -200.0 && itemTop <= (viewportHeight + 200.0);

    if (isVisible != _lastVisibility) {
      _lastVisibility = isVisible;
      widget.onVisibilityChanged(isVisible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
