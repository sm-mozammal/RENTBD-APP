import 'package:dio/dio.dart';
import 'error_formatter.dart';

/// Exception thrown when a server or API returns an error response.
class ServerException implements Exception {
  const ServerException({
    required this.message,
    this.statusCode,
    this.errorDetails,
  });

  final String message;
  final int? statusCode;
  final dynamic errorDetails;

  /// Factory constructor to convert DioException or dynamic error into a polite,
  /// structured [ServerException] with clean Bangla/English messaging.
  factory ServerException.fromDio(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      // 1. Handle Network Timeouts
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return ServerException(
          message: 'সার্ভার থেকে সাড়া পেতে সময় বেশি লাগছে। ইন্টারনেট সংযোগ চেক করে আবার চেষ্টা করুন। (Connection Timeout)',
          statusCode: statusCode ?? 408,
          errorDetails: data,
        );
      }

      // 2. Handle Connection Error / Refusal / Host Unreachable
      if (error.type == DioExceptionType.connectionError) {
        return ServerException(
          message: 'সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি। ইন্টারনেট সংযোগ অথবা সার্ভার সচল আছে কিনা যাচাই করুন। (Server Unreachable)',
          statusCode: statusCode ?? 503,
          errorDetails: data,
        );
      }

      // 3. Handle Cancelled Requests
      if (error.type == DioExceptionType.cancel) {
        return ServerException(
          message: 'অনুরোধটি বাতিল করা হয়েছে। (Request Cancelled)',
          statusCode: statusCode,
          errorDetails: data,
        );
      }

      // 4. Handle Bad Certificate
      if (error.type == DioExceptionType.badCertificate) {
        return ServerException(
          message: 'সার্ভারের সিকিউরিটি সার্টিফিকেট যাচাই করা যায়নি। (SSL Certificate Error)',
          statusCode: statusCode,
          errorDetails: data,
        );
      }

      // 5. Handle HTTP Status Code Responses
      if (statusCode != null) {
        if (statusCode == 401) {
          return ServerException(
            message: 'আপনার লগইন সেশনের মেয়াদ শেষ হয়েছে। অনুগ্রহ করে পুনরায় সাইন ইন করুন। (Session Expired)',
            statusCode: 401,
            errorDetails: data,
          );
        }

        if (statusCode == 403) {
          return ServerException(
            message: 'এই কাজটি করার অনুমতি আপনার নেই। (Access Denied / 403 Forbidden)',
            statusCode: 403,
            errorDetails: data,
          );
        }

        if (statusCode == 404) {
          return ServerException(
            message: 'অনুরোধকৃত তথ্যটি সার্ভারে খুঁজে পাওয়া যায়নি। (Resource Not Found / 404)',
            statusCode: 404,
            errorDetails: data,
          );
        }

        if (statusCode >= 500) {
          return ServerException(
            message: 'সার্ভারে সাময়িক সমস্যা হচ্ছে (HTTP $statusCode)। অনুগ্রহ করে কিছুক্ষণ পর চেষ্টা করুন। (Server Error)',
            statusCode: statusCode,
            errorDetails: data,
          );
        }
      }

      // 6. Handle Response Body (DRF JSON / Text / Field Errors)
      if (data != null) {
        final cleanMsg = RentBdErrorFormatter.format(data);
        return ServerException(
          message: cleanMsg,
          statusCode: statusCode,
          errorDetails: data,
        );
      }

      // Fallback for DioException
      final underlyingError = error.error ?? error.message ?? error;
      return ServerException(
        message: RentBdErrorFormatter.format(underlyingError),
        statusCode: statusCode,
        errorDetails: data,
      );
    }

    // Dynamic error fallback
    return ServerException(
      message: RentBdErrorFormatter.format(error),
      statusCode: null,
      errorDetails: error,
    );
  }

  @override
  String toString() => message;
}

/// Exception thrown when no internet connection or network failure occurs.
class NetworkException implements Exception {
  const NetworkException([this.message = 'ইন্টারনেট সংযোগ ব্যর্থ হয়েছে। অনুগ্রহ করে কানেকশন চেক করুন।']);
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when authentication or token validation fails.
class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = 'আপনার সেশনের মেয়াদ শেষ হয়েছে। অনুগ্রহ করে লগইন করুন।']);
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when local cache or storage fails.
class CacheException implements Exception {
  const CacheException([this.message = 'স্থানীয় ক্যাশ তথ্য লোড করা যায়নি।']);
  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when form or model validation fails.
class ValidationException implements Exception {
  const ValidationException({
    required this.message,
    this.fieldErrors = const {},
  });

  final String message;
  final Map<String, List<String>> fieldErrors;

  @override
  String toString() => message;
}
