import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';

// ── Provider: tracks whether the popup has been dismissed this session ─────────
final _popupDismissedProvider = StateProvider<bool>((ref) => true);

/// Wraps [child] and, after [delay], shows a modal promo popup once per session.
///
/// Place this as a parent of the page body where the popup should appear.
/// It uses a post-frame callback + Timer so the widget tree is fully built first.
class PromoPopupWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final Duration delay;

  const PromoPopupWrapper({
    super.key,
    required this.child,
    this.delay = const Duration(seconds: 120),
  });

  @override
  ConsumerState<PromoPopupWrapper> createState() => _PromoPopupWrapperState();
}

class _PromoPopupWrapperState extends ConsumerState<PromoPopupWrapper> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _timer = Timer(widget.delay, () {
        if (!mounted) return;
        final dismissed = ref.read(_popupDismissedProvider);
        if (!dismissed) _show();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _show() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) => _PromoDialog(
        onDismiss: () {
          ref.read(_popupDismissedProvider.notifier).state = true;
          Navigator.of(dialogContext).pop();
        },
      ),
    ).then((_) {
      if (mounted) {
        ref.read(_popupDismissedProvider.notifier).state = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ── Dialog ────────────────────────────────────────────────────────────────────
class _PromoDialog extends StatefulWidget {
  final VoidCallback onDismiss;
  const _PromoDialog({required this.onDismiss});

  @override
  State<_PromoDialog> createState() => _PromoDialogState();
}

class _PromoDialogState extends State<_PromoDialog> {
  final _emailCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) return;
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 80,
        vertical: isMobile ? 40 : 80,
      ),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: isMobile
              ? _buildContent(isMobile: true)
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left: image panel
                      Expanded(
                        child: Container(
                          color: const Color(0xFF2C2C2C),
                          child: const _ImagePanel(),
                        ),
                      ),
                      // Right: form
                      Expanded(child: _buildContent(isMobile: false)),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildContent({required bool isMobile}) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppDimensions.spacingXl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close ×
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onDismiss,
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(
                  Icons.close,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),

          if (_submitted) ...[
            // ── Success state ──────────────────────────────
            const Icon(
              Icons.check_circle_outline,
              color: AppColors.primary,
              size: 40,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            const Text(
              "You're on the list!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            const Text(
              'Use code WELCOME15 for 15% off your first order.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            _CodeBox(code: 'WELCOME15'),
            const SizedBox(height: AppDimensions.spacingLg),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                onPressed: widget.onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Shop now',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ] else ...[
            // ── Input state ────────────────────────────────
            // Eyebrow
            const Text(
              'EXCLUSIVE OFFER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            const Text(
              'Get 15% off your first order',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            const Text(
              'Join the Pebble community and receive exclusive deals, new arrivals, and style inspiration.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Your email address',
                hintStyle: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Claim My Discount',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            GestureDetector(
              onTap: widget.onDismiss,
              child: const Center(
                child: Text(
                  'No thanks, I\'ll pay full price',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Left image panel (desktop) ────────────────────────────────────────────────
class _ImagePanel extends StatelessWidget {
  const _ImagePanel();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background gradient simulating a lifestyle image
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3A3A3A), Color(0xFF1A1A1A)],
            ),
          ),
        ),
        // Centered icon placeholder
        const Center(
          child: Icon(
            Icons.shopping_bag_outlined,
            size: 72,
            color: Colors.white24,
          ),
        ),
        // Overlay text
        Positioned(
          left: 20,
          right: 20,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'PEBBLE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Thoughtfully crafted,\nbuilt to last.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Discount code copy box ────────────────────────────────────────────────────
class _CodeBox extends StatefulWidget {
  final String code;
  const _CodeBox({required this.code});

  @override
  State<_CodeBox> createState() => _CodeBoxState();
}

class _CodeBoxState extends State<_CodeBox> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Copy to clipboard
        setState(() => _copied = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _copied = false);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _copied
              ? AppColors.primary.withOpacity(0.08)
              : const Color(0xFFF5F3F0),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: _copied ? AppColors.primary : AppColors.border,
            width: _copied ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.code,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: AppColors.textPrimary,
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _copied
                  ? const Icon(
                      Icons.check,
                      key: ValueKey('check'),
                      color: AppColors.primary,
                      size: 18,
                    )
                  : const Icon(
                      Icons.copy_outlined,
                      key: ValueKey('copy'),
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
