import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://pebble-backend-0n9w.onrender.com/api/';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/';
    } else {
      return 'http://localhost:8000/api/';
    }
  }

  /// Converts a relative media path (e.g. /media/images/foo.jpg) returned by
  /// the backend into a fully-qualified URL suitable for Image.network().
  static String resolveImageUrl(String url) {
    if (url.isEmpty) return url;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    // Strip the trailing /api/ to get the host root, then append the path.
    final host = baseUrl.replaceAll(RegExp(r'api/$'), '');
    return '$host${url.startsWith('/') ? url.substring(1) : url}';
  }

  static String? resolveImageUrlNullable(String? url) {
    if (url == null || url.isEmpty) return null;
    return resolveImageUrl(url);
  }
}
