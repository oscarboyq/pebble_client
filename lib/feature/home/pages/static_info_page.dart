import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/utils/html_text.dart';
import 'package:pebble_type/feature/content/providers/content_providers.dart';

class StaticInfoPage extends ConsumerWidget {
  final String slug;

  const StaticInfoPage({super.key, required this.slug});

  String get _fallbackTitle {
    switch (slug) {
      case 'our-story':
        return 'Our Story';
      case 'faqs':
        return 'Frequently Asked Questions';
      case 'contact':
        return 'Contact Us';
      case 'find-a-store':
        return 'Find A Store';
      case 'our-journal':
        return 'Our Journal & News';
      case 'help-center':
        return 'Customer Help Center';
      case 'size-guide':
        return 'Size & Fit Guide';
      case 'returns-refunds':
        return 'Returns & Refunds Policy';
      default:
        return slug
            .split('-')
            .map(
              (w) =>
                  w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '',
            )
            .join(' ');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(pageDetailProvider(slug));
    if (pageAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (pageAsync.hasError || pageAsync.asData == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This page is unavailable.'),
              TextButton(
                onPressed: () => ref.invalidate(pageDetailProvider(slug)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    final backendPage = pageAsync.asData!.value;
    final title = backendPage.title.isNotEmpty
        ? backendPage.title
        : _fallbackTitle;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimensions.headerMaxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Breadcrumb ──────────────────────────────────────
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/'),
                        child: Text(
                          'Home',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '/',
                          style: TextStyle(color: AppColors.border),
                        ),
                      ),
                      Text(
                        'Pages',
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '/',
                          style: TextStyle(color: AppColors.border),
                        ),
                      ),
                      Text(
                        title,
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ── Main Header ─────────────────────────────────────
                  Text(
                    title,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 60,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.accentWarm,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Content ─────────────────────────────────────────
                  if (backendPage.body.isNotEmpty)
                    Text(
                      stripHtml(backendPage.body),
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 15,
                        height: 1.7,
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    const Text('This page has no published content yet.'),

                  const SizedBox(height: 60),
                  // ── CTA back to shopping ────────────────────────────
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => context.go('/products'),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: Text(
                      'Back to Shop',
                      style: GoogleFonts.bricolageGrotesque(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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
