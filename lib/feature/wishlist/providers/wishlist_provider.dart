import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pebble_type/core/services/storage_service.dart';
import 'package:pebble_type/core/services/wishlist_service.dart';

class WishlistNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    final token = await StorageService.getAccessToken();
    if (token == null) {
      return <String>{};
    }
    try {
      final slugs = await WishlistService.getWishlistSlugs();
      return slugs.toSet();
    } catch (_) {
      return <String>{};
    }
  }

  Future<bool> toggle(String slug) async {
    final token = await StorageService.getAccessToken();
    if (token == null) {
      return false;
    }
    final current = state.value ?? {};
    // Optimistic update
    state = AsyncValue.data(
      current.contains(slug)
          ? (Set.from(current)..remove(slug))
          : (Set.from(current)..add(slug)),
    );
    try {
      await WishlistService.toggle(slug);
      return true;
    } catch (_) {
      // Rollback on failure
      state = AsyncValue.data(current);
      return false;
    }
  }

  bool isWishlisted(String slug) => state.value?.contains(slug) ?? false;
}

final wishlistProvider = AsyncNotifierProvider<WishlistNotifier, Set<String>>(
  WishlistNotifier.new,
);
