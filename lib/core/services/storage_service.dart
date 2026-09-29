import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  //key constants
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  static const _homeSnapshotKey = 'home_page_snapshot';
  static const _homeEtagKey = 'home_page_etag';

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshKey);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  static Future<void> saveHomeSnapshot(String jsonString, {String? etag}) async {
    await _storage.write(key: _homeSnapshotKey, value: jsonString);
    if (etag != null) {
      await _storage.write(key: _homeEtagKey, value: etag);
    }
  }

  static Future<String?> getHomeSnapshot() async {
    return await _storage.read(key: _homeSnapshotKey);
  }

  static Future<String?> getHomeEtag() async {
    return await _storage.read(key: _homeEtagKey);
  }

  static Future<void> clearHomeSnapshot() async {
    await _storage.delete(key: _homeSnapshotKey);
    await _storage.delete(key: _homeEtagKey);
  }
}
