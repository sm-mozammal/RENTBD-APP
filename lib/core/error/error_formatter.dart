import 'package:dio/dio.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Centralized error formatting engine for RentBD.
/// Ensures all errors across Network, BLoC, and UI layers are converted into
/// clean, friendly, bilingual (Bangla + English) messages without exposing
/// raw technical stack traces, socket errors, HTML pages, or ugly prefixes.
class RentBdErrorFormatter {
  const RentBdErrorFormatter._();

  /// Converts any exception, failure, or dynamic error into a polite, user-friendly message.
  static String format(dynamic error) {
    if (error == null) {
      return 'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে। অনুগ্রহ করে আবার চেষ্টা করুন। (An unexpected error occurred)';
    }

    // 1. Direct Typed Failures & Exceptions
    if (error is Failure) {
      return _cleanString(error.message);
    }
    if (error is ServerException) {
      return _cleanString(error.message);
    }
    if (error is NetworkException) {
      return _cleanString(error.message);
    }
    if (error is UnauthorizedException) {
      return _cleanString(error.message);
    }
    if (error is ValidationException) {
      return _cleanString(error.message);
    }
    if (error is DioException) {
      return ServerException.fromDio(error).message;
    }

    // 2. Parse from Raw Map (e.g., DRF field errors or error responses)
    if (error is Map<String, dynamic>) {
      return _formatDrfMap(error);
    }

    // 3. String & Generic Object Cleaning
    final rawText = error.toString();
    return _cleanString(rawText);
  }

  /// Formats a DRF JSON error map into a readable message.
  static String _formatDrfMap(Map<String, dynamic> map) {
    if (map.containsKey('detail')) {
      return _cleanString(map['detail'].toString());
    }
    if (map.containsKey('error') && map['error'] is String) {
      return _cleanString(map['error'].toString());
    }
    if (map.containsKey('message') && map['message'] is String) {
      return _cleanString(map['message'].toString());
    }

    final buffer = StringBuffer();
    map.forEach((key, value) {
      final cleanKey = _mapFieldLabel(key);
      String valStr = '';

      if (value is List) {
        valStr = value.map((v) => v.toString().trim()).join(' ');
      } else {
        valStr = value.toString().trim();
      }

      if (cleanKey.isEmpty) {
        buffer.writeln(valStr);
      } else {
        buffer.writeln('$cleanKey: $valStr');
      }
    });

    final result = buffer.toString().trim();
    return result.isNotEmpty ? _cleanString(result) : 'সার্ভার থেকে ত্রুটি বার্তা এসেছে।';
  }

  /// Maps DRF backend field keys to user-friendly Bangla/English labels.
  static String _mapFieldLabel(String key) {
    switch (key.toLowerCase()) {
      case 'non_field_errors':
      case 'detail':
      case 'error':
      case 'message':
        return '';
      case 'phone_number':
      case 'phone':
        return 'মোবাইল নম্বর (Phone)';
      case 'password':
        return 'পাসওয়ার্ড (Password)';
      case 'email':
        return 'ইমেইল (Email)';
      case 'nid_number':
        return 'এনআইডি নম্বর (NID)';
      case 'otp_code':
      case 'otp':
        return 'ওটিপি কোড (OTP)';
      case 'full_name':
        return 'নাম (Full Name)';
      case 'rent_amount':
        return 'ভাড়া (Rent)';
      case 'bedrooms':
        return 'বেডরুম (Bedrooms)';
      case 'area':
        return 'এলাকা (Area)';
      default:
        // Format snake_case to Title Case
        return key.split('_').map((w) {
          if (w.isEmpty) return '';
          return '${w[0].toUpperCase()}${w.substring(1)}';
        }).join(' ');
    }
  }

  /// Cleans technical prefixes, removes HTML dumps, translates socket errors, and trims output.
  static String _cleanString(String raw) {
    var text = raw.trim();

    // 1. Guard against HTML error pages (e.g. Django debug 500 error pages)
    if (text.startsWith('<!DOCTYPE') ||
        text.startsWith('<html') ||
        text.contains('<body') ||
        text.contains('<title>Server Error') ||
        text.contains('Traceback (most recent call last)')) {
      return 'সার্ভারে সাময়িক অভ্যন্তরীণ সমস্যা হয়েছে (Server Error 500)। অনুগ্রহ করে কিছুক্ষণ পর আবার চেষ্টা করুন।';
    }

    // 2. Remove common Dart/Dio prefixes
    final prefixesToRemove = [
      'ServerException: ',
      'ServerFailure: ',
      'NetworkFailure: ',
      'AuthFailure: ',
      'NetworkException: ',
      'UnauthorizedException: ',
      'ValidationException: ',
      'Exception: ',
      'DioException: ',
      'DioException [bad response]: ',
      'DioException [connection error]: ',
      'DioException [connection timeout]: ',
      'DioException [send timeout]: ',
      'DioException [receive timeout]: ',
      'DioException [unknown]: ',
      'Error: ',
    ];

    bool changed = true;
    while (changed) {
      changed = false;
      for (final prefix in prefixesToRemove) {
        if (text.startsWith(prefix)) {
          text = text.substring(prefix.length).trim();
          changed = true;
        }
      }
    }

    // 3. Remove curly braces if a stringified map escaped
    if (text.startsWith('{') && text.endsWith('}')) {
      text = text.substring(1, text.length - 1).trim();
    }
    if (text.startsWith('non_field_errors:')) {
      text = text.replaceFirst('non_field_errors:', '').trim();
    }
    if (text.startsWith('[') && text.endsWith(']')) {
      text = text.substring(1, text.length - 1).trim();
    }

    // 4. Translate raw network/socket phrases to courteous Bengali + English
    final lower = text.toLowerCase();
    if (lower.contains('connection refused') ||
        lower.contains('errno = 61') ||
        lower.contains('errno = 111') ||
        lower.contains('failed host lookup') ||
        lower.contains('network is unreachable') ||
        lower.contains('no route to host') ||
        lower.contains('cleartext') ||
        lower.contains('socketexception')) {
      return 'সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি। ইন্টারনেট সংযোগ অথবা সার্ভার সচল আছে কিনা যাচাই করুন। (Server Unreachable)';
    }

    if (lower.contains('timed out') || lower.contains('timeout')) {
      return 'সার্ভার থেকে সাড়া পেতে বেশি সময় লেগেছে। অনুগ্রহ করে পুনরায় চেষ্টা করুন। (Connection Timeout)';
    }

    if (lower.contains('credentials were not provided') ||
        lower.contains('given token not valid') ||
        lower.contains('token is invalid') ||
        lower.contains('authentication credentials')) {
      return 'আপনার লগইন সেশনের মেয়াদ শেষ হয়েছে। অনুগ্রহ করে পুনরায় সাইন ইন করুন। (Session Expired)';
    }

    // 5. Cap excessively long strings to protect UI layouts
    if (text.length > 220) {
      text = '${text.substring(0, 217)}...';
    }

    return text.isEmpty
        ? 'একটি অপ্রত্যাশিত ত্রুটি ঘটেছে। অনুগ্রহ করে পুনরায় চেষ্টা করুন।'
        : text;
  }
}
