import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/core/network/dio_client.dart';
import 'package:rentbd_app/features/auth/data/datasources/auth_remote_datasource.dart';

class MockDioClient extends Fake implements DioClient {
  String? lastPath;
  dynamic lastData;
  Map<String, dynamic>? lastHeaders;

  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    lastPath = path;
    lastData = data;
    lastHeaders = options?.headers;

    final mockResponse = {
      'id': 'user-123',
      'full_name': 'Test Landlord',
      'phone_number': '+8801700000000',
      'email': 'landlord@test.com',
      'role': 'landlord',
      'is_nid_verified': true,
      'is_phone_verified': true,
      'is_email_verified': true,
      'kyc_status': 'verified',
      'nid_number': '19942691234567890',
      'nid_front_url': 'https://api.rentbd.com/media/nid/front.jpg',
      'nid_back_url': 'https://api.rentbd.com/media/nid/back.jpg',
      'selfie_url': 'https://api.rentbd.com/media/nid/selfie.jpg',
      'present_address': 'House 1, Road 2, Dhaka',
      'emergency_contact': 'Father - 01711223344',
      'date_joined': '2026-01-01T00:00:00Z',
    };

    return Response<T>(
      data: mockResponse as T,
      statusCode: 200,
      requestOptions: RequestOptions(path: path),
    );
  }
}

void main() {
  group('AuthRemoteDataSource KYC Multipart Upload Tests', () {
    late MockDioClient mockDio;
    late AuthRemoteDataSource remoteDataSource;
    late Directory tempDir;

    setUp(() async {
      mockDio = MockDioClient();
      remoteDataSource = AuthRemoteDataSource(mockDio);
      tempDir = await Directory.systemTemp.createTemp('kyc_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'submitKyc sends FormData with MultipartFile when local image paths are provided',
      () async {
        // Create temporary mock files to simulate camera-captured images
        final frontFile = File('${tempDir.path}/test_nid_front.jpg');
        await frontFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);

        final backFile = File('${tempDir.path}/test_nid_back.jpg');
        await backFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);

        final selfieFile = File('${tempDir.path}/test_selfie.jpg');
        await selfieFile.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);

        final profile = await remoteDataSource.submitKyc(
          nidNumber: '19942691234567890',
          presentAddress: 'House 1, Road 2, Dhaka',
          emergencyContact: 'Father - 01711223344',
          nidFrontUrl: frontFile.path,
          nidBackUrl: backFile.path,
          selfieUrl: selfieFile.path,
        );

        expect(mockDio.lastPath, '/auth/nid-verify/');
        expect(mockDio.lastData, isA<FormData>());

        final formData = mockDio.lastData as FormData;
        final fieldNames = formData.fields.map((f) => f.key).toList();
        final fileNames = formData.files.map((f) => f.key).toList();

        expect(fieldNames, contains('nid_number'));
        expect(fieldNames, contains('present_address'));
        expect(fieldNames, contains('emergency_contact'));

        expect(fileNames, contains('nid_front'));
        expect(fileNames, contains('nid_back'));
        expect(fileNames, contains('selfie'));

        expect(profile.isNidVerified, isTrue);
      },
    );

    test('submitKyc sends json map when string URLs are provided', () async {
      final profile = await remoteDataSource.submitKyc(
        nidNumber: '19942691234567890',
        presentAddress: 'House 1, Road 2, Dhaka',
        emergencyContact: 'Father - 01711223344',
        nidFrontUrl: 'https://example.com/front.jpg',
        nidBackUrl: 'https://example.com/back.jpg',
        selfieUrl: 'https://example.com/selfie.jpg',
      );

      expect(mockDio.lastPath, '/auth/nid-verify/');
      expect(mockDio.lastData, isA<Map<String, dynamic>>());

      final mapData = mockDio.lastData as Map<String, dynamic>;
      expect(mapData['nid_front_url'], 'https://example.com/front.jpg');
      expect(mapData['nid_back_url'], 'https://example.com/back.jpg');
      expect(mapData['selfie_url'], 'https://example.com/selfie.jpg');

      expect(profile.isNidVerified, isTrue);
    });
  });
}
