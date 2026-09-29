import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/utils/html_text.dart';
import 'package:pebble_type/core/widgets/pebble_image.dart';
import 'package:pebble_type/feature/content/providers/content_providers.dart';

/// A single journal article (`/blogs/:blog/:slug`).
class ArticlePage extends ConsumerWidget {
  final String blog;
  final String slug;

  const ArticlePage({super.key, required this.slug, this.blog = 'news'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articleAsync = ref.watch(
      articleDetailProvider((blog: blog, slug: slug)),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: articleAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('Failed to load article: $e')),
        data: (article) {
          if (article == null) {
            return const Center(child: Text('Article not found.'));
          }
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimensions.headerMaxWidth,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/blogs/$blog'),
                        child: Text(
                          '← Back to Journal',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        article.title,
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (article.authorName.isNotEmpty)
                        Text(
                          'By ${article.authorName}',
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      if (article.coverImage != null &&
                          article.coverImage!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: PebbleImage(
                            imageUrl: article.coverImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        stripHtml(article.body ?? article.excerpt),
                        style: GoogleFonts.bricolageGrotesque(
                          fontSize: 15,
                          height: 1.7,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
