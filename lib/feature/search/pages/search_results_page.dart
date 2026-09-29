import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/feature/content/models/content_models.dart';
import 'package:pebble_type/feature/content/providers/content_providers.dart';
import 'package:pebble_type/feature/products/widgets/product_card.dart';

/// Unified site search results (`/search?q=`).
class SearchResultsPage extends ConsumerWidget {
  final String? initialQuery;

  const SearchResultsPage({super.key, this.initialQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = GoRouterState.of(context).uri.queryParameters;
    final query = (params['q'] ?? initialQuery ?? '').trim();
    final resultsAsync = ref.watch(searchResultsProvider(query));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          query.isEmpty ? 'Search' : 'Results for “$query”',
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: query.isEmpty
          ? const Center(child: Text('Type a search term to begin.'))
          : resultsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Search failed.'),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(searchResultsProvider(query)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (results) => _SearchBody(results: results),
            ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  final SearchResultsModel results;

  const _SearchBody({required this.results});

  bool get _isEmpty =>
      results.products.isEmpty &&
      results.collections.isEmpty &&
      results.pages.isEmpty &&
      results.articles.isEmpty;

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      return Center(
        child: Text(
          'No results found for “${results.query}”.',
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cols = width >= 1200
            ? 4
            : width >= 900
                ? 3
                : 2;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (results.products.isNotEmpty) ...[
                _heading('Products'),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: cols,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 32,
                    childAspectRatio: cols == 4 ? 0.70 : (cols == 3 ? 0.72 : 0.68),
                  ),
                  itemCount: results.products.length,
                  itemBuilder: (_, i) => ProductCard(
                    product: results.products[i],
                    onTap: () =>
                        context.push('/products/${results.products[i].slug}'),
                  ),
                ),
                const SizedBox(height: 32),
              ],
              if (results.collections.isNotEmpty) ...[
                _heading('Collections'),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: results.collections
                      .map(
                        (c) => ActionChip(
                          label: Text('${c.name} (${c.productCount})'),
                          onPressed: () => context.go(
                            '/collections/${c.slug}',
                            extra: c.name,
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 32),
              ],
              if (results.pages.isNotEmpty) ...[
                _heading('Pages'),
                ...results.pages.map(
                  (p) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.article_outlined),
                    title: Text(p.title),
                    onTap: () => context.go('/pages/${p.slug}'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              if (results.articles.isNotEmpty) ...[
                _heading('Journal'),
                ...results.articles.map(
                  (a) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.menu_book_outlined),
                    title: Text(a.title),
                    subtitle: a.excerpt.isEmpty ? null : Text(a.excerpt, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => context.go('/blogs/news/${a.slug}'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          text,
          style: GoogleFonts.bricolageGrotesque(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      );
}
