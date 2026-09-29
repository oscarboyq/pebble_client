import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/widgets/pebble_image.dart';
import 'package:pebble_type/feature/content/models/content_models.dart';
import 'package:pebble_type/feature/content/providers/content_providers.dart';

/// Storefront index of all collections (`/collections`).
class CollectionsIndexPage extends ConsumerWidget {
  const CollectionsIndexPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          'Collections',
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
      body: collectionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load collections'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(collectionsIndexProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (collections) {
          if (collections.isEmpty) {
            return const Center(child: Text('No collections yet.'));
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final cols = width >= 1200
                  ? 4
                  : width >= 900
                      ? 3
                      : 2;
              return GridView.builder(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 24,
                  childAspectRatio: 0.72,
                ),
                itemCount: collections.length,
                itemBuilder: (context, index) =>
                    _CollectionCard(collection: collections[index]),
              );
            },
          );
        },
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final CollectionSummaryModel collection;

  const _CollectionCard({required this.collection});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.go(
        '/collections/${collection.slug}',
        extra: collection.name,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: collection.image != null && collection.image!.isNotEmpty
                  ? PebbleImage(
                      imageUrl: collection.image!,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: AppColors.surface,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.collections_outlined,
                        size: 36,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            collection.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${collection.productCount} products',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
