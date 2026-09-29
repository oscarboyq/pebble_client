import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/widgets/pebble_image.dart';
import 'package:pebble_type/feature/content/providers/content_providers.dart';

/// Journal / blog listing (`/blogs/news`).
class BlogListPage extends ConsumerWidget {
  final String blog;

  const BlogListPage({super.key, this.blog = 'news'});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(articlesProvider(blog));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          'Our Journal',
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: articlesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load articles'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(articlesProvider(blog)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (articles) {
          if (articles.isEmpty) {
            return const Center(child: Text('No articles yet.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final cols = width >= 1000
                  ? 3
                  : width >= 640
                      ? 2
                      : 1;
              return GridView.builder(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 28,
                  childAspectRatio: 0.82,
                ),
                itemCount: articles.length,
                itemBuilder: (context, i) {
                  final article = articles[i];
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.go('/blogs/$blog/${article.slug}'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: article.coverImage != null &&
                                    article.coverImage!.isNotEmpty
                                ? PebbleImage(
                                    imageUrl: article.coverImage!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(color: AppColors.surface),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.bricolageGrotesque(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (article.excerpt.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            article.excerpt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.bricolageGrotesque(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
