// Full wishlist items provider (with product data)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pebble_type/core/constants/app_colors.dart';
import 'package:pebble_type/core/constants/app_dimensions.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/services/api_client.dart';
import 'package:pebble_type/core/services/storage_service.dart';
import 'package:pebble_type/core/theme/app_text_styles.dart';
import 'package:pebble_type/feature/products/models/product_model.dart';
import 'package:pebble_type/feature/products/widgets/product_card.dart';
import 'package:pebble_type/feature/wishlist/providers/wishlist_provider.dart';

final isUserLoggedInProvider = FutureProvider<bool>((ref) async {
  final token = await StorageService.getAccessToken();
  return token != null;
});

final wishlistItemsProvider = FutureProvider<List<ProductModel>>((ref) async {
  ref.watch(wishlistProvider); // rebuild when wishlist changes
  final token = await StorageService.getAccessToken();
  if (token == null) {
    return <ProductModel>[];
  }
  try {
    final response = await ApiClient.dio.get('wishlist/');
    return (response.data as List<dynamic>)
        .map((e) => ProductModel.fromJson(e['product'] as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return <ProductModel>[];
  }
});

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(isUserLoggedInProvider);
    final wishlistAsync = ref.watch(wishlistItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: const Text(
          'Wishlist',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: authAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (_, __) => _buildGuestPrompt(context),
        data: (isLoggedIn) {
          if (!isLoggedIn) {
            return _buildGuestPrompt(context);
          }
          return wishlistAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load wishlist.',
                    style: TextStyle(color: AppColors.error),
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  TextButton(
                    onPressed: () => ref.invalidate(wishlistItemsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (products) {
              if (products.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: AppColors.border,
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),
                      Text(
                        'No saved items',
                        style: AppTextStyles.bodyLg.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingSm),
                      Text(
                        'Tap ♡ on any product to save it',
                        style: AppTextStyles.bodyMd,
                      ),
                    ],
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppDimensions.spacingMd,
                  mainAxisSpacing: AppDimensions.spacingMd,
                  childAspectRatio: 0.62,
                ),
                itemCount: products.length,
                itemBuilder: (_, index) => ProductCard(
                  product: products[index],
                  onTap: () => context.push('/products/${products[index].slug}'),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGuestPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 64,
              color: AppColors.border,
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              'Sign in to see your wishlist',
              style: AppTextStyles.bodyLg.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              'Save items you love and revisit them anytime',
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingLg),
            ElevatedButton(
              onPressed: () => context.push(AppRoutes.login),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
