import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/core/error/error_formatter.dart';
import 'package:rentbd_app/core/error/exceptions.dart';
import 'package:rentbd_app/core/error/failures.dart';
import 'package:rentbd_app/core/widgets/bari_crash_recovery.dart';

void main() {
  group('RentBdErrorFormatter and ServerException Tests', () {
    test('formats Dio connection error without technical socket dump', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/api/v1/properties/'),
        type: DioExceptionType.connectionError,
        error: 'SocketException: Connection refused (OS Error: Connection refused, errno = 61)',
      );

      final message = RentBdErrorFormatter.format(dioError);
      expect(message.contains('সার্ভারের সাথে সংযোগ স্থাপন করা যায়নি'), true);
      expect(message.contains('errno = 61'), false);
      expect(message.contains('SocketException'), false);
    });

    test('formats Dio timeout errors politely', () {
      final dioTimeout = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/otp/request/'),
        type: DioExceptionType.connectionTimeout,
      );

      final message = RentBdErrorFormatter.format(dioTimeout);
      expect(message.contains('সার্ভার থেকে সাড়া পেতে সময় বেশি লাগছে'), true);
      expect(message.contains('Connection Timeout'), true);
    });

    test('sanitizes Django 500 HTML debug pages and never leaks raw HTML', () {
      const htmlBody = '''
<!DOCTYPE html>
<html lang="en">
<head><title>FieldError at /api/v1/properties/</title></head>
<body>
  <h1>FieldError at /api/v1/properties/</h1>
  <pre>Traceback (most recent call last):
    File ".../django/db/models/sql/query.py", line 1500
  </pre>
</body>
</html>
''';

      final dio500 = DioException(
        requestOptions: RequestOptions(path: '/api/v1/properties/'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/properties/'),
          statusCode: 500,
          data: htmlBody,
        ),
      );

      final exception = ServerException.fromDio(dio500);
      expect(exception.message.contains('<html'), false);
      expect(exception.message.contains('Traceback'), false);
      expect(exception.message.contains('Server Error'), true);
    });

    test('formats DRF validation field errors cleanly', () {
      final drfErrors = {
        'phone_number': ['Enter a valid mobile phone number.'],
        'password': ['Password must be at least 6 characters.'],
      };

      final formatted = RentBdErrorFormatter.format(drfErrors);
      expect(formatted.contains('মোবাইল নম্বর (Phone): Enter a valid mobile phone number.'), true);
      expect(formatted.contains('পাসওয়ার্ড (Password): Password must be at least 6 characters.'), true);
    });

    test('formats DRF non_field_errors without technical prefix', () {
      final drfNonField = {
        'non_field_errors': ['Unable to log in with provided credentials.'],
      };

      final formatted = RentBdErrorFormatter.format(drfNonField);
      expect(formatted.startsWith('non_field_errors:'), false);
      expect(formatted.contains('Unable to log in with provided credentials.'), true);
    });

    test('Failure and ServerException toString() return clean messages', () {
      const serverFail = ServerFailure('ভাড়া সংক্রান্ত তথ্য লোড করা যায়নি');
      expect(serverFail.toString(), 'ভাড়া সংক্রান্ত তথ্য লোড করা যায়নি');

      const serverException = ServerException(message: 'সার্ভার সমস্যা', statusCode: 500);
      expect(serverException.toString(), 'সার্ভার সমস্যা');
    });

    test('formats 401 Unauthorized with courteous session expiration message', () {
      final dio401 = DioException(
        requestOptions: RequestOptions(path: '/api/v1/auth/profile/'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/auth/profile/'),
          statusCode: 401,
          data: {'detail': 'Given token not valid for any token type'},
        ),
      );

      final exception = ServerException.fromDio(dio401);
      expect(exception.statusCode, 401);
      expect(exception.message.contains('লগইন সেশনের মেয়াদ শেষ হয়েছে'), true);
    });
  });

  group('BariCrashRecoveryWidget Tests', () {
    testWidgets('renders recovery widget with RentBD brand and action button', (tester) async {
      final errorDetails = FlutterErrorDetails(
        exception: Exception('Simulated widget build overflow'),
        stack: StackTrace.empty,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BariCrashRecoveryWidget(errorDetails: errorDetails),
        ),
      );

      expect(find.text('RentBD অ্যাপ্লিকেশন'), findsOneWidget);
      expect(find.text('হোম পেজে ফিরুন'), findsOneWidget);
      expect(find.byIcon(Icons.home_work_rounded), findsOneWidget);
    });
  });
}
