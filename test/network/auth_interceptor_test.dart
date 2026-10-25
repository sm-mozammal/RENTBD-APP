import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/core/network/auth_interceptor.dart';
import 'package:rentbd_app/core/network/token_manager.dart';

class MockHttpClientAdapter implements HttpClientAdapter {
  MockHttpClientAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUp(() async {
    await TokenManager.clear();
  });

  tearDown(() async {
    await TokenManager.clear();
  });

  group('AuthInterceptor onRequest Tests', () {
    test('attaches Bearer token when TokenManager has access token', () async {
      await TokenManager.saveSession(
        access: 'test-valid-jwt-token',
        userId: 'usr-123',
        userRole: 'tenant',
      );

      final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1'));
      dio.interceptors.add(AuthInterceptor());

      String? capturedAuthHeader;
      dio.httpClientAdapter = MockHttpClientAdapter((options) async {
        capturedAuthHeader = options.headers['Authorization'] as String?;
        return ResponseBody.fromString('[]', 200);
      });

      await dio.get('/properties/');

      expect(capturedAuthHeader, equals('Bearer test-valid-jwt-token'));
    });

    test('does not attach Authorization header when token is null or empty', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1'));
      dio.interceptors.add(AuthInterceptor());

      bool hasAuthHeader = true;
      dio.httpClientAdapter = MockHttpClientAdapter((options) async {
        hasAuthHeader = options.headers.containsKey('Authorization');
        return ResponseBody.fromString('[]', 200);
      });

      await dio.get('/properties/');

      expect(hasAuthHeader, isFalse);
    });

    test('preserves existing Authorization header if _isRetry is true', () async {
      final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1'));
      dio.interceptors.add(AuthInterceptor());

      String? capturedAuthHeader;
      dio.httpClientAdapter = MockHttpClientAdapter((options) async {
        capturedAuthHeader = options.headers['Authorization'] as String?;
        return ResponseBody.fromString('[]', 200);
      });

      await dio.get(
        '/properties/',
        options: Options(
          headers: {'Authorization': 'Bearer retried-token-999'},
          extra: {'_isRetry': true},
        ),
      );

      expect(capturedAuthHeader, equals('Bearer retried-token-999'));
    });
  });

  group('AuthInterceptor 401 & Token Refresh Tests', () {
    test('non-401 errors pass through without triggering refresh or logout', () async {
      await TokenManager.saveSession(
        access: 'access-123',
        refresh: 'refresh-123',
      );

      bool signedOut = false;
      final dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1'));
      dio.interceptors.add(
        AuthInterceptor(
          onSignOut: () async {
            signedOut = true;
          },
        ),
      );

      dio.httpClientAdapter = MockHttpClientAdapter((options) async {
        return ResponseBody.fromString('Server Error', 500);
      });

      expect(
        () => dio.get('/properties/'),
        throwsA(isA<DioException>()),
      );

      expect(TokenManager.hasToken, isTrue);
      expect(signedOut, isFalse);
    });

    test('401 error with valid refresh token refreshes token and replays request', () async {
      await TokenManager.saveSession(
        access: 'expired-access-token',
        refresh: 'valid-refresh-token',
        userId: 'u1',
        userRole: 'tenant',
      );

      int refreshCallsCount = 0;
      final mockRefreshDio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1'));
      mockRefreshDio.httpClientAdapter = MockHttpClientAdapter((options) async {
        if (options.path.contains('/auth/token/refresh/')) {
          refreshCallsCount++;
          final body = jsonEncode({
            'access': 'new-fresh-access-token-777',
            'refresh': 'new-rotated-refresh-token-888',
          });
          return ResponseBody.fromString(
            body,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('Not Found', 404);
      });

      int requestCallsCount = 0;
      String? lastAuthHeader;
      final mainDio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1'));
      final authInterceptor = AuthInterceptor(
        dio: mainDio,
        refreshDio: mockRefreshDio,
      );
      mainDio.interceptors.add(authInterceptor);

      mainDio.httpClientAdapter = MockHttpClientAdapter((options) async {
        requestCallsCount++;
        lastAuthHeader = options.headers['Authorization'] as String?;

        if (options.extra['_isRetry'] == true) {
          final body = jsonEncode([
            {'id': 'p1', 'title': 'Mirpur Apartment'}
          ]);
          return ResponseBody.fromString(
            body,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }

        // First call returns 401 Unauthorized
        return ResponseBody.fromString(
          jsonEncode({'detail': 'Given token not valid for any token type'}),
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final response = await mainDio.get<List<dynamic>>('/properties/');

      expect(response.statusCode, equals(200));
      expect(refreshCallsCount, equals(1));
      expect(requestCallsCount, equals(2)); // 1 failed + 1 replayed
      expect(lastAuthHeader, equals('Bearer new-fresh-access-token-777'));
      expect(TokenManager.accessToken, equals('new-fresh-access-token-777'));
      expect(TokenManager.refreshToken, equals('new-rotated-refresh-token-888'));
    });

    test('401 error when refresh fails clears session data and calls onSignOut', () async {
      await TokenManager.saveSession(
        access: 'expired-access',
        refresh: 'expired-or-revoked-refresh',
        userId: 'u1',
        userRole: 'tenant',
      );

      final mockRefreshDio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1'));
      mockRefreshDio.httpClientAdapter = MockHttpClientAdapter((options) async {
        return ResponseBody.fromString(
          jsonEncode({'detail': 'Token is invalid or expired', 'code': 'token_not_valid'}),
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      bool signOutCalled = false;
      final mainDio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1'));
      final authInterceptor = AuthInterceptor(
        dio: mainDio,
        refreshDio: mockRefreshDio,
        onSignOut: () async {
          signOutCalled = true;
        },
      );
      mainDio.interceptors.add(authInterceptor);

      mainDio.httpClientAdapter = MockHttpClientAdapter((options) async {
        return ResponseBody.fromString(
          jsonEncode({'detail': 'Authentication credentials were not provided.'}),
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      try {
        await mainDio.get('/properties/');
        fail('Should throw DioException on failed refresh');
      } on DioException catch (e) {
        expect(e.response?.statusCode, equals(401));
      }

      expect(TokenManager.hasToken, isFalse);
      expect(TokenManager.accessToken, isNull);
      expect(TokenManager.refreshToken, isNull);
      expect(signOutCalled, isTrue);
    });

    test('401 error when no refresh token exists clears session immediately without network call', () async {
      await TokenManager.saveSession(
        access: 'access-without-refresh',
        userId: 'u1',
        userRole: 'tenant',
      );
      expect(TokenManager.refreshToken, isNull);

      bool signOutCalled = false;
      int refreshNetworkCalls = 0;

      final mockRefreshDio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1'));
      mockRefreshDio.httpClientAdapter = MockHttpClientAdapter((options) async {
        refreshNetworkCalls++;
        return ResponseBody.fromString('{}', 200);
      });

      final mainDio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1'));
      final authInterceptor = AuthInterceptor(
        dio: mainDio,
        refreshDio: mockRefreshDio,
        onSignOut: () async {
          signOutCalled = true;
        },
      );
      mainDio.interceptors.add(authInterceptor);

      mainDio.httpClientAdapter = MockHttpClientAdapter((options) async {
        return ResponseBody.fromString(
          jsonEncode({'detail': 'Token expired'}),
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      try {
        await mainDio.get('/properties/');
        fail('Should throw DioException');
      } on DioException catch (e) {
        expect(e.response?.statusCode, equals(401));
      }

      expect(refreshNetworkCalls, equals(0));
      expect(TokenManager.hasToken, isFalse);
      expect(signOutCalled, isTrue);
    });

    test('simultaneous 401 requests trigger only one token refresh call and replay all', () async {
      await TokenManager.saveSession(
        access: 'expired-access',
        refresh: 'valid-refresh',
        userId: 'u1',
      );

      int refreshCallsCount = 0;
      final mockRefreshDio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1'));
      mockRefreshDio.httpClientAdapter = MockHttpClientAdapter((options) async {
        refreshCallsCount++;
        // Add simulated network latency to test concurrency queue
        await Future.delayed(const Duration(milliseconds: 30));
        return ResponseBody.fromString(
          jsonEncode({
            'access': 'new-concurrent-access-token',
            'refresh': 'new-concurrent-refresh-token',
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      int replayCount = 0;
      final mainDio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/api/v1'));
      final authInterceptor = AuthInterceptor(
        dio: mainDio,
        refreshDio: mockRefreshDio,
      );
      mainDio.interceptors.add(authInterceptor);

      mainDio.httpClientAdapter = MockHttpClientAdapter((options) async {
        if (options.extra['_isRetry'] == true) {
          replayCount++;
          return ResponseBody.fromString(
            jsonEncode({'path': options.path, 'status': 'replayed_ok'}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          jsonEncode({'detail': 'Token expired'}),
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      // Fire both 401 requests simultaneously
      final responses = await Future.wait([
        mainDio.get('/properties/'),
        mainDio.get('/profile/'),
      ]);

      expect(responses[0].statusCode, equals(200));
      expect(responses[1].statusCode, equals(200));
      expect(refreshCallsCount, equals(1));
      expect(replayCount, equals(2));
      expect(TokenManager.accessToken, equals('new-concurrent-access-token'));
      expect(TokenManager.refreshToken, equals('new-concurrent-refresh-token'));
    });
  });
}
