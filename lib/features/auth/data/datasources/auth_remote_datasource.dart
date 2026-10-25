import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:rentbd_app/core/error/exceptions.dart';
import 'package:rentbd_app/core/network/dio_client.dart';
import 'package:rentbd_app/core/network/token_manager.dart';
import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';
import 'auth_datasource.dart';

/// Real remote data source talking directly to Django REST Framework backend.
class AuthRemoteDataSource implements AuthDataSource {
  const AuthRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<bool> sendOtp(String phoneNumber) async {
    try {
      final response = await _dioClient.post(
        '/auth/otp/request/',
        data: {'phone_number': phoneNumber},
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to send OTP: $e');
    }
  }

  @override
  Future<UserProfileModel> verifyOtp(
    String phoneNumber,
    String otpCode, {
    UserRole role = UserRole.tenant,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/otp/verify/',
        data: {
          'phone_number': phoneNumber,
          'otp_code': otpCode,
          'role': role == UserRole.landlord ? 'landlord' : 'tenant',
        },
      );
      final data = response.data as Map<String, dynamic>;
      await _extractAndSaveTokens(data);

      try {
        final liveProfile = await getCurrentProfile();
        if (liveProfile != null) {
          return liveProfile;
        }
      } catch (_) {}

      final Map<String, dynamic> userJson = Map<String, dynamic>.from(data);
      if (data['user'] is Map<String, dynamic>) {
        userJson.addAll(data['user'] as Map<String, dynamic>);
      } else if (data['data'] is Map<String, dynamic>) {
        userJson.addAll(data['data'] as Map<String, dynamic>);
      }
      return UserProfileModel.fromJson(userJson);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to verify OTP: $e');
    }
  }

  @override
  Future<UserProfileModel> loginWithPassword({
    required String phoneNumber,
    required String password,
    UserRole? role,
  }) async {
    try {
      final payload = <String, dynamic>{
        'phone_number': phoneNumber,
        'password': password,
      };
      if (role != null) {
        payload['role'] = role == UserRole.landlord ? 'landlord' : 'tenant';
      }
      final response = await _dioClient.post(
        '/auth/login/',
        data: payload,
      );
      final data = response.data as Map<String, dynamic>;
      await _extractAndSaveTokens(data);

      try {
        final liveProfile = await getCurrentProfile();
        if (liveProfile != null) {
          return liveProfile;
        }
      } catch (_) {}

      final Map<String, dynamic> userJson = Map<String, dynamic>.from(data);
      if (data['user'] is Map<String, dynamic>) {
        userJson.addAll(data['user'] as Map<String, dynamic>);
      } else if (data['data'] is Map<String, dynamic>) {
        userJson.addAll(data['data'] as Map<String, dynamic>);
      }
      return UserProfileModel.fromJson(userJson);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to login with password: $e');
    }
  }

  @override
  Future<UserProfileModel> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/register/',
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
          'email': email,
          'password': password,
          'role': role == UserRole.landlord ? 'landlord' : 'tenant',
        },
      );
      final data = response.data as Map<String, dynamic>;
      await _extractAndSaveTokens(data);

      try {
        final liveProfile = await getCurrentProfile();
        if (liveProfile != null) {
          return liveProfile;
        }
      } catch (_) {}

      final Map<String, dynamic> userJson = Map<String, dynamic>.from(data);
      if (data['user'] is Map<String, dynamic>) {
        userJson.addAll(data['user'] as Map<String, dynamic>);
      } else if (data['data'] is Map<String, dynamic>) {
        userJson.addAll(data['data'] as Map<String, dynamic>);
      }
      return UserProfileModel.fromJson(userJson);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to register account: $e');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dioClient.post(
        '/auth/password/change/',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to change password: $e');
    }
  }

  @override
  Future<UserProfileModel> submitKyc({
    required String nidNumber,
    required String presentAddress,
    required String emergencyContact,
    String? nidFrontUrl,
    String? nidBackUrl,
    String? selfieUrl,
  }) async {
    try {
      final Map<String, dynamic> bodyData = {
        'nid_number': nidNumber,
        'present_address': presentAddress,
        'emergency_contact': emergencyContact,
      };

      bool hasFiles = false;

      if (nidFrontUrl != null && nidFrontUrl.isNotEmpty) {
        if (!nidFrontUrl.startsWith('http')) {
          bodyData['nid_front'] = await MultipartFile.fromFile(
            nidFrontUrl,
            filename: 'nid_front.jpg',
          );
          hasFiles = true;
        } else {
          bodyData['nid_front_url'] = nidFrontUrl;
        }
      }

      if (nidBackUrl != null && nidBackUrl.isNotEmpty) {
        if (!nidBackUrl.startsWith('http')) {
          bodyData['nid_back'] = await MultipartFile.fromFile(
            nidBackUrl,
            filename: 'nid_back.jpg',
          );
          hasFiles = true;
        } else {
          bodyData['nid_back_url'] = nidBackUrl;
        }
      }

      if (selfieUrl != null && selfieUrl.isNotEmpty) {
        if (!selfieUrl.startsWith('http')) {
          bodyData['selfie'] = await MultipartFile.fromFile(
            selfieUrl,
            filename: 'selfie.jpg',
          );
          hasFiles = true;
        } else {
          bodyData['selfie_url'] = selfieUrl;
        }
      }

      final dynamic payload = hasFiles ? FormData.fromMap(bodyData) : bodyData;

      Response response;
      try {
        response = await _dioClient.post(
          '/auth/nid-verify/',
          data: payload,
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          response = await _dioClient.post(
            '/auth/kyc/submit/',
            data: payload,
          );
        } else {
          rethrow;
        }
      }
      final data = response.data as Map<String, dynamic>;
      final updatedProfile = await getCurrentProfile();
      final base = updatedProfile ?? UserProfileModel.fromJson(data);
      final verifiedProfile = UserProfileModel.fromEntity(
        base.toEntity().copyWith(
          isNidVerified: true,
          kycStatus: KycStatus.verified,
          nidNumber: nidNumber,
          presentAddress: presentAddress,
          emergencyContact: emergencyContact,
        ),
      );

      if (TokenManager.accessToken != null) {
        await TokenManager.saveSession(
          access: TokenManager.accessToken!,
          refresh: TokenManager.refreshToken,
          userId: verifiedProfile.id,
          userRole: verifiedProfile.role.name,
          userJson: verifiedProfile.toJson(),
        );
      }
      return verifiedProfile;
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to submit KYC verification: $e');
    }
  }

  @override
  Future<UserProfileModel?> getCurrentProfile() async {
    if (!TokenManager.hasToken) {
      return null;
    }
    try {
      final response = await _dioClient.get('/auth/profile/');
      if (response.data == null) return null;
      final data = response.data as Map<String, dynamic>;

      final Map<String, dynamic> userJson = Map<String, dynamic>.from(data);
      if (data['user'] is Map<String, dynamic>) {
        userJson.addAll(data['user'] as Map<String, dynamic>);
      } else if (data['data'] is Map<String, dynamic>) {
        userJson.addAll(data['data'] as Map<String, dynamic>);
      }
      final profile = UserProfileModel.fromJson(userJson);

      // Refresh cached user info & role in TokenManager
      if (TokenManager.accessToken != null) {
        await TokenManager.saveSession(
          access: TokenManager.accessToken!,
          refresh: TokenManager.refreshToken,
          userId: profile.id,
          userRole: profile.role.name,
          userJson: userJson,
        );
      }

      return profile;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await TokenManager.clear();
        return null;
      }
      if (TokenManager.cachedUserProfileJson != null) {
        try {
          final cached = jsonDecode(TokenManager.cachedUserProfileJson!) as Map<String, dynamic>;
          return UserProfileModel.fromJson(cached);
        } catch (_) {}
      }
      throw ServerException.fromDio(e);
    } catch (e) {
      if (TokenManager.cachedUserProfileJson != null) {
        try {
          final cached = jsonDecode(TokenManager.cachedUserProfileJson!) as Map<String, dynamic>;
          return UserProfileModel.fromJson(cached);
        } catch (_) {}
      }
      throw ServerException(message: 'Failed to fetch user profile: $e');
    }
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    try {
      final response = await _dioClient.patch(
        '/auth/profile/',
        data: profile.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      final userJson = (data['user'] ?? data) as Map<String, dynamic>;
      final updated = UserProfileModel.fromJson(userJson);

      if (TokenManager.accessToken != null) {
        await TokenManager.saveSession(
          access: TokenManager.accessToken!,
          refresh: TokenManager.refreshToken,
          userId: updated.id,
          userRole: updated.role.name,
          userJson: userJson,
        );
      }

      return updated;
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to update profile: $e');
    }
  }

  @override
  Future<UserProfileModel> switchRole(UserRole newRole) async {
    try {
      final response = await _dioClient.post(
        '/auth/role/switch/',
        data: {
          'role': newRole == UserRole.landlord ? 'landlord' : 'tenant',
        },
      );
      final data = response.data as Map<String, dynamic>;
      UserProfileModel result;
      if (data['user'] != null && data['user'] is Map<String, dynamic>) {
        result = UserProfileModel.fromJson(data['user'] as Map<String, dynamic>);
      } else {
        // Refetch current profile to obtain full user model under new role
        final updatedProfile = await getCurrentProfile();
        result = updatedProfile ?? UserProfileModel.fromJson(data);
      }

      if (TokenManager.accessToken != null) {
        await TokenManager.saveSession(
          access: TokenManager.accessToken!,
          refresh: TokenManager.refreshToken,
          userId: result.id,
          userRole: result.role.name,
          userJson: result.toJson(),
        );
      }

      return result;
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to switch role: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final refreshToken = TokenManager.refreshToken;
      await _dioClient.post(
        '/auth/logout/',
        data: refreshToken != null ? {'refresh': refreshToken} : null,
      );
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await TokenManager.clear();
    }
  }

  Future<void> _extractAndSaveTokens(Map<String, dynamic> data) async {
    String? access;
    String? refresh;

    if (data['tokens'] != null && data['tokens'] is Map<String, dynamic>) {
      final tokens = data['tokens'] as Map<String, dynamic>;
      access = tokens['access'] as String? ?? tokens['access_token'] as String?;
      refresh = tokens['refresh'] as String? ?? tokens['refresh_token'] as String?;
    } else {
      access = data['access'] as String? ?? data['access_token'] as String? ?? data['token'] as String?;
      refresh = data['refresh'] as String? ?? data['refresh_token'] as String?;
    }

    final userJson = data['user'] is Map<String, dynamic>
        ? data['user'] as Map<String, dynamic>
        : (data['id'] != null ? data : null);

    final userId = userJson?['id'] as String?;
    final userRole = userJson?['role'] as String?;

    if (access != null && access.isNotEmpty) {
      await TokenManager.saveSession(
        access: access,
        refresh: refresh,
        userId: userId,
        userRole: userRole,
        userJson: userJson,
      );
    }
  }
}

