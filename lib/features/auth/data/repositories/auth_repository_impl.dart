import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:rentbd_app/core/error/exceptions.dart';
import 'package:rentbd_app/core/error/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../models/user_profile_model.dart';

/// Clean Architecture Repository implementation for Auth.
/// Dynamically toggles between Mock and Remote datasources based on [AppEnvironment.useMockData].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.mockDataSource,
    required this.remoteDataSource,
  });

  final AuthDataSource mockDataSource;
  final AuthDataSource remoteDataSource;

  AuthDataSource get _activeDataSource =>
      AppEnvironment.useMockData ? mockDataSource : remoteDataSource;

  @override
  Future<bool> sendOtp(String phoneNumber) async {
    try {
      return await _activeDataSource.sendOtp(phoneNumber);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<UserProfile> verifyOtp(
    String phoneNumber,
    String otpCode, {
    UserRole role = UserRole.tenant,
  }) async {
    try {
      final model = await _activeDataSource.verifyOtp(phoneNumber, otpCode, role: role);
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<UserProfile> loginWithPassword({
    required String phoneNumber,
    required String password,
    UserRole? role,
  }) async {
    try {
      final model = await _activeDataSource.loginWithPassword(
        phoneNumber: phoneNumber,
        password: password,
        role: role,
      );
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<UserProfile> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final model = await _activeDataSource.register(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        role: role,
      );
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _activeDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<UserProfile> submitKyc({
    required String nidNumber,
    required String presentAddress,
    required String emergencyContact,
    String? nidFrontUrl,
    String? nidBackUrl,
    String? selfieUrl,
  }) async {
    try {
      final model = await _activeDataSource.submitKyc(
        nidNumber: nidNumber,
        presentAddress: presentAddress,
        emergencyContact: emergencyContact,
        nidFrontUrl: nidFrontUrl,
        nidBackUrl: nidBackUrl,
        selfieUrl: selfieUrl,
      );
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<UserProfile?> getCurrentProfile() async {
    try {
      final model = await _activeDataSource.getCurrentProfile();
      return model?.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserProfile> updateProfile(UserProfile updatedProfile) async {
    try {
      final model = UserProfileModel.fromEntity(updatedProfile);
      final resultModel = await _activeDataSource.updateProfile(model);
      return resultModel.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<UserProfile> switchRole(UserRole newRole) async {
    try {
      final model = await _activeDataSource.switchRole(newRole);
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _activeDataSource.signOut();
  }
}
