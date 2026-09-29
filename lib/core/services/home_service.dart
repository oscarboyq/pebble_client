import 'dart:convert';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pebble_type/core/services/api_client.dart';
import 'package:pebble_type/core/services/storage_service.dart';
import 'package:pebble_type/feature/home/models/home_model.dart';

class HomeService {
  static HomePageData? _cachedData;
  static String? _cachedEtag;
  static bool _isInitialized = false;

  static HomePageData? get cachedData => _cachedData;
  static String? get cachedEtag => _cachedEtag;

  @visibleForTesting
  static void setMockCache({HomePageData? data, String? etag}) {
    _cachedData = data;
    _cachedEtag = etag;
    _isInitialized = true;
  }

  @visibleForTesting
  static void clearCache() {
    _cachedData = null;
    _cachedEtag = null;
    _isInitialized = false;
  }

  /// Initializes in-memory snapshot cache from persistent local storage.
  static Future<void> initMemoryCache() async {
    if (_isInitialized) return;
    _isInitialized = true;
    try {
      final jsonStr = await StorageService.getHomeSnapshot();
      final etag = await StorageService.getHomeEtag();
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final rawData = jsonDecode(jsonStr) as Map<String, dynamic>;
        _cachedData = HomePageData.fromJson(rawData);
        _cachedEtag = etag;
      }
    } catch (_) {
      // Graceful fallback on corrupted storage
      _cachedData = null;
      _cachedEtag = null;
    }
  }

  /// Fetches fresh data from API using HTTP conditional GET with ETag.
  /// Returns null if server responds with 304 Not Modified.
  /// Returns fresh HomePageData if server responds with 200 OK.
  static Future<HomePageData?> fetchFreshData() async {
    try {
      final headers = <String, dynamic>{};
      if (_cachedEtag != null && _cachedEtag!.isNotEmpty) {
        headers['If-None-Match'] = _cachedEtag;
      }

      final response = await ApiClient.dio.get(
        'home/',
        options: Options(
          headers: headers,
          validateStatus: (status) =>
              status != null && ((status >= 200 && status < 300) || status == 304),
        ),
      );

      if (response.statusCode == 304) {
        // Data has not changed on server (HTTP 304 Not Modified)
        return null;
      }

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final rawData = response.data as Map<String, dynamic>;
        final newEtag = response.headers.value('etag');

        final freshData = kIsWeb
            ? HomePageData.fromJson(rawData)
            : await Isolate.run(() => HomePageData.fromJson(rawData));

        _cachedData = freshData;
        _cachedEtag = newEtag;

        // Persist to local storage in background
        _persistSnapshot(rawData, newEtag);

        return freshData;
      }
    } catch (_) {
      // Fall back silently to cachedData on network failure
    }
    return null;
  }

  static void _persistSnapshot(Map<String, dynamic> rawData, String? etag) {
    Future.microtask(() async {
      try {
        final jsonStr = jsonEncode(rawData);
        await StorageService.saveHomeSnapshot(jsonStr, etag: etag);
      } catch (_) {}
    });
  }

  /// Returns home page data using the Stale-While-Revalidate pattern.
  /// If cached snapshot is present, returns it immediately and revalidates in background.
  /// Otherwise performs initial network fetch.
  static Future<HomePageData> getHomePageData() async {
    if (_cachedData != null) {
      // Trigger background revalidation without waiting
      fetchFreshData();
      return _cachedData!;
    }

    if (!_isInitialized) {
      await initMemoryCache();
      if (_cachedData != null) {
        fetchFreshData();
        return _cachedData!;
      }
    }

    final fresh = await fetchFreshData();
    if (fresh != null) return fresh;
    if (_cachedData != null) return _cachedData!;

    throw Exception('Failed to load home page data');
  }
}
