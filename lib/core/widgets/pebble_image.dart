import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pebble_type/core/config/api_config.dart';

/// Semantic presets for decoded texture sizes to prevent memory ballooning.
enum PebbleImageSize {
  /// Mini thumbnails (badges, swatches, avatars, cart icons): ~160px decode width.
  thumbnail(160),

  /// Standard product & category cards: ~600px decode width (~500 KB texture).
  card(600),

  /// Large showcase, lifestyle story, and layered cards: ~900px decode width (~1.2 MB texture).
  showcase(900),

  /// Full-bleed hero banners and headers: ~1600px decode width (~4 MB texture max).
  banner(1600);

  final int defaultCacheWidth;
  const PebbleImageSize(this.defaultCacheWidth);
}

/// A high-performance, memory-optimized image widget.
///
/// Automatically constrains decode dimensions via [cacheWidth] and [cacheHeight]
/// to prevent multi-gigabyte uncompressed RGBA texture allocations.
class PebbleImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Alignment alignment;
  final int? cacheWidth;
  final int? cacheHeight;
  final PebbleImageSize? preset;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool gaplessPlayback;
  final FilterQuality filterQuality;
  final Color? color;
  final BlendMode? colorBlendMode;

  const PebbleImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.cacheWidth,
    this.cacheHeight,
    this.preset,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.gaplessPlayback = true,
    this.filterQuality = FilterQuality.medium,
    this.color,
    this.colorBlendMode,
  });

  /// Factory helper for thumbnail images (50–100px display size).
  const PebbleImage.thumbnail({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.gaplessPlayback = true,
    this.filterQuality = FilterQuality.low,
    this.color,
    this.colorBlendMode,
  })  : cacheWidth = 160,
        cacheHeight = null,
        preset = PebbleImageSize.thumbnail;

  /// Factory helper for product cards (200–350px display size).
  const PebbleImage.card({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.gaplessPlayback = true,
    this.filterQuality = FilterQuality.medium,
    this.color,
    this.colorBlendMode,
  })  : cacheWidth = 600,
        cacheHeight = null,
        preset = PebbleImageSize.card;

  /// Factory helper for showcase / lifestyle cards (600–900px display size).
  const PebbleImage.showcase({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.gaplessPlayback = true,
    this.filterQuality = FilterQuality.medium,
    this.color,
    this.colorBlendMode,
  })  : cacheWidth = 900,
        cacheHeight = null,
        preset = PebbleImageSize.showcase;

  /// Factory helper for full-bleed hero banners.
  const PebbleImage.banner({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.gaplessPlayback = true,
    this.filterQuality = FilterQuality.medium,
    this.color,
    this.colorBlendMode,
  })  : cacheWidth = 1600,
        cacheHeight = null,
        preset = PebbleImageSize.banner;

  /// Returns an [ImageProvider] wrapped with [ResizeImage] for use in
  /// [DecorationImage], [CircleAvatar], or other non-widget image slots.
  static ImageProvider provider(
    String url, {
    int? cacheWidth,
    int? cacheHeight,
    PebbleImageSize? preset,
  }) {
    final imageProvider = NetworkImage(url);
    if (kIsWeb) return imageProvider;
    final targetWidth = cacheWidth ?? preset?.defaultCacheWidth;
    if (targetWidth != null || cacheHeight != null) {
      return ResizeImage(
        imageProvider,
        width: targetWidth,
        height: cacheHeight,
      );
    }
    // Default safe constraint of 800px so raw 4K images are never decoded unconstrained
    return ResizeImage(imageProvider, width: 800);
  }

  int? _resolveCacheWidth() {
    if (kIsWeb) return null;
    if (cacheWidth != null) return cacheWidth;
    if (preset != null) return preset!.defaultCacheWidth;
    if (width != null && width!.isFinite && width! > 0) {
      // 1.5x retina scaling clamped safely
      return (width! * 1.5).round().clamp(60, 1920);
    }
    if (cacheHeight == null) {
      // Safe fallback ceiling so no image ever decodes unconstrained
      return 800;
    }
    return null;
  }

  int? _resolveCacheHeight() {
    if (kIsWeb) return null;
    if (cacheHeight != null) return cacheHeight;
    if (height != null && height!.isFinite && height! > 0 && cacheWidth == null) {
      return (height! * 1.5).round().clamp(60, 1920);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final rawUrl = imageUrl?.trim();
    final url = (rawUrl != null && rawUrl.isNotEmpty)
        ? ApiConfig.resolveImageUrl(rawUrl)
        : null;

    Widget content;
    if (url == null || url.isEmpty) {
      content = placeholder ?? _defaultPlaceholder();
    } else {
      content = Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        cacheWidth: _resolveCacheWidth(),
        cacheHeight: _resolveCacheHeight(),
        gaplessPlayback: gaplessPlayback,
        filterQuality: filterQuality,
        color: color,
        colorBlendMode: colorBlendMode,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }
          return placeholder ?? _defaultPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _defaultError();
        },
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return content;
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF1EFEA),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: Color(0xFFC7C3B8),
          size: 28,
        ),
      ),
    );
  }

  Widget _defaultError() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF5F3EF),
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Color(0xFFB5B0A6),
          size: 26,
        ),
      ),
    );
  }
}
