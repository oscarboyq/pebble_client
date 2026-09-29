import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/utils/responsive.dart';
import 'package:pebble_type/core/widgets/auto_pause_visibility.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/widgets/quick_view_sheet.dart';
import 'package:video_player/video_player.dart';

/// "Shop The Winter Set" Products Highlight Section
/// Recreates Shopify reference `products_highlight_mTi6q7`
/// Features split desktop layout with editorial header, interactive product
/// carousel, progress bar pagination, and floating video overlay with sound/pause controls.
class ProductsHighlightSection extends StatefulWidget {
  final ProductsHighlightModel highlight;

  const ProductsHighlightSection({
    super.key,
    required this.highlight,
  });

  @override
  State<ProductsHighlightSection> createState() =>
      _ProductsHighlightSectionState();
}

class _ProductsHighlightSectionState extends State<ProductsHighlightSection> {
  int _currentSlide = 0;
  int _selectedColorIndex = 0; // 0 = Forest Green (#22584A), 1 = Dusty Rose (#B46B70)

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isPlaying = true;
  bool _isMuted = true;
  bool _isVisible = true;

  static const List<Color> _swatchColors = [
    Color(0xFF22584A), // Forest Green / Teal
    Color(0xFFB46B70), // Dusty Rose / Pink
  ];

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _onVisibilityChanged(bool isVisible) {
    _isVisible = isVisible;
    if (_videoController == null || !_isVideoInitialized) return;
    if (isVisible) {
      if (_isPlaying && !_videoController!.value.isPlaying) {
        _videoController!.play();
      }
    } else {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      }
    }
  }

  Future<void> _initVideo() async {
    final videoUrl = widget.highlight.videoUrl;
    if (videoUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(videoUrl);
        _videoController = VideoPlayerController.networkUrl(uri);
        await _videoController!.initialize();
        _videoController!.setLooping(true);
        _videoController!.setVolume(0.0);
        if (_isVisible && _isPlaying) {
          await _videoController!.play();
        }
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
            _isMuted = true;
          });
        }
      } catch (e) {
        debugPrint('Video init failed, falling back to poster: $e');
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_videoController == null || !_isVideoInitialized) return;
    setState(() {
      if (_isPlaying) {
        _videoController!.pause();
        _isPlaying = false;
      } else {
        _videoController!.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleMute() {
    if (_videoController == null || !_isVideoInitialized) return;
    setState(() {
      if (_isMuted) {
        _videoController!.setVolume(1.0);
        _isMuted = false;
      } else {
        _videoController!.setVolume(0.0);
        _isMuted = true;
      }
    });
  }

  void _nextSlide(int total) {
    if (total <= 1) return;
    setState(() {
      _currentSlide = (_currentSlide + 1) % total;
      _selectedColorIndex = 0;
    });
  }

  void _prevSlide(int total) {
    if (total <= 1) return;
    setState(() {
      _currentSlide = (_currentSlide - 1 + total) % total;
      _selectedColorIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = context.isWide;
    final screenWidth = MediaQuery.of(context).size.width;
    final products = widget.highlight.carouselProducts;

    final vPadding = (screenWidth * 0.05).clamp(48.0, 96.0);
    final hPadding = isWide ? (screenWidth * 0.06).clamp(32.0, 80.0) : 20.0;

    return AutoPauseVisibility(
      onVisibilityChanged: _onVisibilityChanged,
      child: Container(
        width: double.infinity,
        color: AppColors.background,
        padding: EdgeInsets.symmetric(vertical: vPadding, horizontal: hPadding),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Left Column: Editorial & Product Carousel (45%) ───────
                  Expanded(
                    flex: 9,
                    child: _buildLeftColumn(context, products, true),
                  ),
                  const SizedBox(width: 48),

                  // ── Right Column: Hero Banner & Floating Video (55%) ─────
                  Expanded(
                    flex: 11,
                    child: _buildRightColumn(context, true),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Right Column on mobile sits on top or bottom
                  _buildRightColumn(context, false),
                  const SizedBox(height: 36),
                  _buildLeftColumn(context, products, false),
                ],
              ),
      ),
    );
  }

  Widget _buildLeftColumn(
      BuildContext context, List<ProductModel> products, bool isWide) {
    final headingFontSize = isWide ? 54.0 : 32.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Tag / Subheading
        Text(
          widget.highlight.tag.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Display Heading
        Text(
          widget.highlight.heading,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: headingFontSize,
            fontWeight: FontWeight.w800,
            height: 1.08,
            color: AppColors.textPrimary,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 20),

        // Description paragraph
        if (widget.highlight.description.isNotEmpty)
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Text(
              widget.highlight.description,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        const SizedBox(height: 28),

        // "Shop now >" Pill CTA Button
        _buildShopNowButton(context),

        const SizedBox(height: 44),

        // Interactive Product Carousel Card
        if (products.isNotEmpty) ...[
          _buildProductCard(context, products[_currentSlide % products.length]),
          const SizedBox(height: 24),
          _buildPaginationControls(products.length),
        ],
      ],
    );
  }

  Widget _buildShopNowButton(BuildContext context) {
    return InkWell(
      onTap: () {
        final link = widget.highlight.buttonLink;
        if (link.isNotEmpty) context.go(link);
      },
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.highlight.buttonText,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Colors.black,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    // Resolve image: if swatches exist, index 0 is green, index 1 is pink
    String imageUrl = product.primaryImageUrl ?? '';
    if (product.images.length > 1 && _selectedColorIndex == 1) {
      imageUrl = product.images[1].image;
    } else if (product.images.isNotEmpty) {
      imageUrl = product.images[0].image;
    }

    final parsedPrice = double.tryParse(product.price);
    final displayPrice = parsedPrice != null
        ? '\$${parsedPrice.toStringAsFixed(2)}'
        : '\$${product.price}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 96,
              height: 96,
              color: const Color(0xFFF6F6F6),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      cacheWidth: 200,
                      gaplessPlayback: true,
                      errorBuilder: (ctx, err, stack) =>
                          const Icon(Icons.broken_image_outlined, size: 36),
                    )
                  : const Icon(Icons.image_outlined, size: 36),
            ),
          ),
          const SizedBox(width: 18),

          // Title, Price, Color Swatches
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  displayPrice,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                // Color Swatches
                Row(
                  children: List.generate(_swatchColors.length, (idx) {
                    final isSelected = _selectedColorIndex == idx;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColorIndex = idx),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: _swatchColors[idx],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Circular Cart Button
          GestureDetector(
            onTap: () => showQuickView(context, product.slug),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(int total) {
    final progressRatio = total > 0 ? (_currentSlide + 1) / total : 1.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Counter "1 / 2"
        Text(
          '${_currentSlide + 1} / $total',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 16),

        // Progress bar track
        SizedBox(
          width: 80,
          height: 2,
          child: Stack(
            children: [
              Container(
                width: 80,
                height: 2,
                color: const Color(0xFFE0E0E0),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: 80 * progressRatio,
                height: 2,
                color: Colors.black,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),

        // Left Arrow
        InkWell(
          onTap: () => _prevSlide(total),
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.all(6.0),
            child: Icon(Icons.chevron_left, size: 20),
          ),
        ),

        // Right Arrow
        InkWell(
          onTap: () => _nextSlide(total),
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.all(6.0),
            child: Icon(Icons.chevron_right, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context, bool isWide) {
    final bannerImage = widget.highlight.bannerImage;
    final videoPoster = widget.highlight.videoPoster;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 0.855,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. Meadow Banner Image ──────────────────────────────────
            if (bannerImage.isNotEmpty)
              Image.network(
                bannerImage,
                fit: BoxFit.cover,
                cacheWidth: 1200,
                gaplessPlayback: true,
                errorBuilder: (ctx, err, stack) => Container(
                  color: const Color(0xFFE5E5E5),
                ),
              )
            else
              Container(color: const Color(0xFFE5E5E5)),

            // ── 2. Centered Floating Video Card ─────────────────────────
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.58,
                child: AspectRatio(
                  aspectRatio: 0.72,
                  child: RepaintBoundary(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.28),
                            blurRadius: 32,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Video player or poster fallback
                          if (_isVideoInitialized && _videoController != null)
                            FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _videoController!.value.size.width,
                                height: _videoController!.value.size.height,
                                child: VideoPlayer(_videoController!),
                              ),
                            )
                          else if (videoPoster.isNotEmpty)
                            Image.network(
                              videoPoster,
                              fit: BoxFit.cover,
                              cacheWidth: 800,
                              gaplessPlayback: true,
                              errorBuilder: (ctx, err, stack) => Container(
                                color: const Color(0xFFD4E0D8),
                              ),
                            )
                          else
                            Container(color: const Color(0xFFD4E0D8)),

                          // Floating Bottom-Right Video Controls
                          Positioned(
                            bottom: 14,
                            right: 14,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Mute / Unmute Button
                                GestureDetector(
                                  onTap: _toggleMute,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.55),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isMuted
                                          ? Icons.volume_off_rounded
                                          : Icons.volume_up_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Play / Pause Button
                                GestureDetector(
                                  onTap: _togglePlayPause,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.55),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
  );
  }
}
