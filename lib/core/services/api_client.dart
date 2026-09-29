import 'package:dio/dio.dart';
import 'package:pebble_type/core/config/api_config.dart';
import 'package:pebble_type/core/routes/app_router.dart';
import 'package:pebble_type/core/services/storage_service.dart';

class ApiClient {
  static final Dio dio = _createDio();

  static Dio _createDio() {
    final instance = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    instance.interceptors.add(_AuuthInterceptor());

    return instance;
  }
}

class _AuuthInterceptor extends Interceptor {
  // Separate plain Dio for refresh calls — avoids infinite loop
  final _refreshDIo = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await StorageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken != null) {
        try {
          final response = await _refreshDIo.post(
            'auth/token/refresh/',
            data: {'refresh': refreshToken},
          );
          final newAccess = response.data['access'] as String;
          // SimpleJWT only returns a new refresh if ROTATE_REFRESH_TOKENS=True
          final newRefresh = response.data['refresh'] as String?;
          await StorageService.saveTokens(
            accessToken: newAccess,
            refreshToken: newRefresh ?? refreshToken,
          );
          // Retry original request with new access token
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccess';
          final retryResponse = await ApiClient.dio.fetch(retryOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          // Refresh token also expired — clear tokens
          await StorageService.clearTokens();
          try {
            final loc = appRouter.routerDelegate.currentConfiguration.uri.path;
            final protectedPrefixes = [
              AppRoutes.checkout,
              AppRoutes.orders,
              AppRoutes.profile,
            ];
            if (protectedPrefixes.any((p) => loc.isNotEmpty && loc.startsWith(p))) {
              appRouter.go(AppRoutes.login);
            }
          } catch (_) {}
        }
      } else {
        await StorageService.clearTokens();
        // Guest user or unauthenticated request on public page — do NOT redirect
        try {
          final loc = appRouter.routerDelegate.currentConfiguration.uri.path;
          final protectedPrefixes = [
            AppRoutes.checkout,
            AppRoutes.orders,
            AppRoutes.profile,
          ];
          if (protectedPrefixes.any((p) => loc.isNotEmpty && loc.startsWith(p))) {
            appRouter.go(AppRoutes.login);
          }
        } catch (_) {}
      }
    }
    handler.next(err);
  }
}
