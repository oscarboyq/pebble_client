import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pebble_type/core/services/home_service.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';

class HomeNotifier extends AsyncNotifier<HomePageData> {
  @override
  FutureOr<HomePageData> build() {
    final cached = HomeService.cachedData;
    if (cached != null) {
      // Stale-While-Revalidate: Return cached snapshot synchronously in 0ms,
      // then revalidate with API in background.
      _revalidate();
      return cached;
    }
    return _fetchInitial();
  }

  Future<HomePageData> _fetchInitial() async {
    return await HomeService.getHomePageData();
  }

  Future<void> _revalidate() async {
    final fresh = await HomeService.fetchFreshData();
    if (fresh != null && state.hasValue) {
      state = AsyncData(fresh);
    }
  }

  Future<void> refresh() async {
    final previousData = state.value ?? HomeService.cachedData;
    try {
      final fresh = await HomeService.fetchFreshData();
      if (fresh != null) {
        state = AsyncData(fresh);
      } else if (previousData != null) {
        state = AsyncData(previousData);
      }
    } catch (e, st) {
      if (previousData != null) {
        state = AsyncData(previousData);
      } else {
        state = AsyncError(e, st);
      }
    }
  }
}

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomePageData>(
  HomeNotifier.new,
);
