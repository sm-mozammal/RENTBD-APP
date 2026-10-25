import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_environment.dart';
import 'token_manager.dart';

/// Interceptor that:
/// 1. Attaches the active JWT Bearer token to requests.
/// 2. Intercepts HTTP 401 Unauthorized errors and attempts token refresh via
///    `POST /auth/token/refresh/` using [TokenManager.refreshToken].
/// 3. Safely queues concurrent 401 requests using a single in-flight Completer,
///    preventing multiple redundant refresh calls.
/// 4. Replays original failed requests with the freshly minted access token upon success.
/// 5. If token refresh fails (e.g. invalid/expired refresh token or network failure),
///    clears all session data and logs the user out via [TokenManager.clear()]
///    and invokes [onSignOut].
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    this.dio,
    this.getToken,
    this.onSignOut,
    String? baseUrl,
    Dio? refreshDio,
  }) {
    _refreshDio = refreshDio ??
        Dio(
          BaseOptions(
            baseUrl: baseUrl ?? AppEnvironment.baseUrl,
            connectTimeout: AppEnvironment.connectTimeout,
            receiveTimeout: AppEnvironment.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
  }

  /// The main Dio client used to replay failed requests.
  final Dio? dio;

  /// Optional custom token supplier.
  final Future<String?> Function()? getToken;

  /// Optional callback invoked when session expires and logout is triggered.
  final Future<void> Function()? onSignOut;

  /// Dedicated Dio instance for making token refresh calls, isolated from this interceptor.
  late final Dio _refreshDio;

  /// Completer to serialize multiple concurrent refresh requests.
  Completer<String?>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // If request already has an explicitly injected retry token, preserve it.
    if (options.extra['_isRetry'] == true &&
        options.headers.containsKey('Authorization')) {
      options.headers['Accept'] = 'application/json';
      return handler.next(options);
    }

    final token = getToken != null
        ? await getToken!()
        : TokenManager.accessToken;

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    if (response?.statusCode != 401) {
      return handler.next(err);
    }

    final path = err.requestOptions.path;

    // Do NOT attempt token refresh for auth endpoints or if already retried
    final isAuthEndpoint = path.contains('/auth/token/refresh') ||
        path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/otp');

    final isAlreadyRetried = err.requestOptions.extra['_isRetry'] == true;

    if (isAuthEndpoint || isAlreadyRetried) {
      // If the refresh endpoint itself failed with 401 or a retried request failed again:
      if (path.contains('/auth/token/refresh') || isAlreadyRetried) {
        await _clearSessionAndLogout();
      }
      return handler.next(err);
    }

    final currentRefreshToken = TokenManager.refreshToken;
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      await _clearSessionAndLogout();
      return handler.next(err);
    }

    try {
      final newAccessToken = await _getOrRefreshToken(currentRefreshToken);

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        final retryResponse = await _replayRequest(err.requestOptions, newAccessToken);
        return handler.resolve(retryResponse);
      } else {
        await _clearSessionAndLogout();
        return handler.next(err);
      }
    } catch (_) {
      await _clearSessionAndLogout();
      return handler.next(err);
    }
  }

  /// Thread-safe token refresh coordinator using Completer.
  Future<String?> _getOrRefreshToken(String refreshToken) async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final newToken = await _performTokenRefresh(refreshToken);
      completer.complete(newToken);
      return newToken;
    } catch (e) {
      completer.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// Performs the actual POST request to the token refresh endpoint.
  Future<String?> _performTokenRefresh(String refreshToken) async {
    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        '/auth/token/refresh/',
        data: {'refresh': refreshToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final data = response.data;
      if (data == null) return null;

      String? newAccess;
      String? newRefresh;

      if (data['tokens'] is Map<String, dynamic>) {
        final tokens = data['tokens'] as Map<String, dynamic>;
        newAccess = tokens['access'] as String? ?? tokens['access_token'] as String?;
        newRefresh = tokens['refresh'] as String? ?? tokens['refresh_token'] as String?;
      } else {
        newAccess = data['access'] as String? ?? data['access_token'] as String?;
        newRefresh = data['refresh'] as String? ?? data['refresh_token'] as String?;
      }

      if (newAccess != null && newAccess.isNotEmpty) {
        await TokenManager.saveSession(
          access: newAccess,
          refresh: (newRefresh != null && newRefresh.isNotEmpty) ? newRefresh : refreshToken,
        );
        return newAccess;
      }

      return null;
    } catch (e) {
      debugPrint('AuthInterceptor: Token refresh failed: $e');
      return null;
    }
  }

  /// Replays the failed request with the new access token.
  Future<Response<dynamic>> _replayRequest(
    RequestOptions requestOptions,
    String newAccessToken,
  ) {
    final client = dio ?? Dio();
    final newHeaders = Map<String, dynamic>.from(requestOptions.headers)
      ..['Authorization'] = 'Bearer $newAccessToken';

    final options = Options(
      method: requestOptions.method,
      headers: newHeaders,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      validateStatus: requestOptions.validateStatus,
      receiveTimeout: requestOptions.receiveTimeout,
      sendTimeout: requestOptions.sendTimeout,
      extra: Map<String, dynamic>.from(requestOptions.extra)
        ..['_isRetry'] = true,
    );

    return client.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
      cancelToken: requestOptions.cancelToken,
    );
  }

  /// Clears all session tokens and triggers sign out listeners.
  Future<void> _clearSessionAndLogout() async {
    try {
      await TokenManager.clear();
      if (onSignOut != null) {
        await onSignOut!();
      }
    } catch (e) {
      debugPrint('AuthInterceptor: Error during clear session: $e');
    }
  }
}
