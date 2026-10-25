import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_environment.dart';
import 'auth_interceptor.dart';
import 'dio_logger_interceptor.dart';

/// Preconfigured Dio HTTP Client prepared for Django REST Framework APIs.
/// Includes Chucker API Inspector and Green ANSI Console Logger in debug mode.
class DioClient {
  DioClient({
    Dio? dio,
    String? baseUrl,
    Future<String?> Function()? getToken,
    Future<void> Function()? onSignOut,
    Dio? refreshDio,
  }) : _dio = dio ??
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
            ) {
    _authInterceptor = AuthInterceptor(
      dio: _dio,
      getToken: getToken,
      onSignOut: onSignOut,
      baseUrl: baseUrl ?? AppEnvironment.baseUrl,
      refreshDio: refreshDio,
    );
    _dio.interceptors.add(_authInterceptor);

    // Chucker HTTP Inspector for visual API inspection in Debug mode
    if (kDebugMode) {
      _dio.interceptors.add(ChuckerDioInterceptor());
    }

    // Emerald Green ANSI Logger for styled, readable terminal output
    _dio.interceptors.add(
      RentBdDioLogger(
        enabled: kDebugMode,
        printHeaders: true,
        printRequestBody: true,
        printResponseBody: true,
      ),
    );
  }

  final Dio _dio;
  late final AuthInterceptor _authInterceptor;

  Dio get instance => _dio;
  AuthInterceptor get authInterceptor => _authInterceptor;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
