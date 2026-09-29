import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/widgets/auto_pause_visibility.dart';
import 'package:pebble_type/core/widgets/reveal_on_scroll.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';

/// 1:1 Implementation of Shopify Pebble "Our Story" Section
/// (template--20816638214282__custom_section_cjGfXN).
///
/// Features:
/// - 50/50 responsive layout (Desktop side-by-side flex row, mobile stacked)
/// - Left column: Subheading tag, display headline in Bricolage Grotesque,
///   story paragraph, and black pill button with circular white arrow icon
/// - Right column: 1:1 image with dual floating animated badges:
///   - "Wow": pastel cyan capsule rotated 20deg with gentle vertical floating
///   - "Playful": pastel pink circle rotated -24deg with counter-phase floating
class OurStorySection extends StatefulWidget {
  final OurStoryModel story;

  const OurStorySection({
    super.key,
    required this.story,
  });

  @override
  State<OurStorySection> createState() => _OurStorySectionState();
}

class _OurStorySectionState extends State<OurStorySection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  void _onVisibilityChanged(bool isVisible) {
    if (isVisible) {
      if (!_floatController.isAnimating) {
        _floatController.repeat();
      }
    } else {
      if (_floatController.isAnimating) {
        _floatController.stop();
      }
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 900;

    return AutoPauseVisibility(
      onVisibilityChanged: _onVisibilityChanged,
      child: Container(
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.symmetric(
          vertical: isDesktop ? 88.0 : 48.0,
          horizontal: isDesktop ? 48.0 : 20.0,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1360),
            child: isDesktop ? _buildDesktop(context) : _buildMobile(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Left Column: Story Content ──
        Expanded(
          flex: 5,
          child: RevealOnScroll(
            child: Padding(
              padding: const EdgeInsets.only(right: 32.0),
              child: _buildStoryText(context, isDesktop: true),
            ),
          ),
        ),
        const SizedBox(width: 40),

        // ── Right Column: Image with Floating Badges ──
        Expanded(
          flex: 5,
          child: RevealOnScroll(
            child: _buildImageWithBadges(context, isDesktop: true),
          ),
        ),
      ],
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStoryText(context, isDesktop: false),
        const SizedBox(height: 40),
        _buildImageWithBadges(context, isDesktop: false),
      ],
    );
  }

  Widget _buildStoryText(BuildContext context, {required bool isDesktop}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tag
        Text(
          widget.story.tag.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),

        // Display Headline
        Text(
          widget.story.heading,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: isDesktop ? 48 : 32,
            fontWeight: FontWeight.w800,
            height: 1.15,
            letterSpacing: -0.8,
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 20),

        // Story Description
        Text(
          widget.story.description,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            height: 1.6,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 32),

        // "Learn more" Primary Pill Button
        _PrimaryPillButton(
          text: widget.story.buttonText,
          onTap: () {
            final link = widget.story.buttonLink.trim();
            if (link.isNotEmpty) {
              context.go(link);
            }
          },
        ),
      ],
    );
  }

  Widget _buildImageWithBadges(BuildContext context, {required bool isDesktop}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.maxWidth;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Base 1:1 Photo
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        widget.story.image,
                        fit: BoxFit.cover,
                        cacheWidth: 800,
                        gaplessPlayback: true,
                        errorBuilder: (context, error, stackTrace) => Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 48,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Floating Badge 1: "Wow" ─────────────────────────────
                  Positioned(
                    top: boxWidth * 0.10,
                    left: isDesktop ? (boxWidth * 0.04) : 0,
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _floatController,
                        builder: (context, child) {
                          final floatOffset =
                              math.sin(_floatController.value * 2 * math.pi) * 7.0;

                          return Transform.translate(
                            offset: Offset(0, floatOffset),
                            child: child,
                          );
                        },
                        child: Transform.rotate(
                          angle: 20 * math.pi / 180,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: _parseColor(
                                widget.story.badge1Color,
                                const Color(0xFFBDE6EE),
                              ),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.story.badge1Text,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Floating Badge 2: "Playful" ─────────────────────────
                  Positioned(
                    top: boxWidth * 0.65,
                    right: isDesktop ? (boxWidth * 0.02) : 0,
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _floatController,
                        builder: (context, child) {
                          // Counter-phase floating motion
                          final floatOffset =
                              -math.sin(_floatController.value * 2 * math.pi) * 7.0;

                          return Transform.translate(
                            offset: Offset(0, floatOffset),
                            child: child,
                          );
                        },
                        child: Transform.rotate(
                          angle: -24 * math.pi / 180,
                      child: Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: _parseColor(
                            widget.story.badge2Color,
                            const Color(0xFFFFC8C8),
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            widget.story.badge2Text,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _parseColor(String colorStr, Color fallback) {
    try {
      final hex = colorStr.replaceAll('#', '').trim();
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
      return fallback;
    } catch (_) {
      return fallback;
    }
  }
}

/// Black pill button with integrated white circular arrow badge
class _PrimaryPillButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _PrimaryPillButton({
    required this.text,
    required this.onTap,
  });

  @override
  State<_PrimaryPillButton> createState() => _PrimaryPillButtonState();
}

class _PrimaryPillButtonState extends State<_PrimaryPillButton> {
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.20 : 0.08),
                blurRadius: _isHovered ? 14 : 8,
                offset: Offset(0, _isHovered ? 6 : 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 200),
                    offset: _isHovered
                        ? const Offset(0.15, 0.0)
                        : const Offset(0.0, 0.0),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: Color(0xFF111111),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
