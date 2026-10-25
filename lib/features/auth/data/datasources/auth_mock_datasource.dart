import 'dart:async';
import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:rentbd_app/core/network/token_manager.dart';
import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';
import 'auth_datasource.dart';

/// High-fidelity mock datasource providing realistic Bangladeshi user profiles.
class AuthMockDataSource implements AuthDataSource {
  static const UserProfileModel defaultTenant = UserProfileModel(
    id: 'usr-dhaka-tenant-001',
    phoneNumber: '+8801712345678',
    fullName: 'Tanvir Ahmed (Tenant)',
    role: UserRole.tenant,
    email: 'tanvir.engineer@gmail.com',
    occupation: 'Lead Software Engineer',
    workplace: 'Brain Station 23, Mohakhali',
    familySize: 3,
    nidNumber: '',
    isNidVerified: false,
    kycStatus: KycStatus.notSubmitted,
    presentAddress: 'Road 11, Banani, Dhaka',
    emergencyContact: '+8801799887766',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
    rentalRating: 4.9,
    completedRentals: 3,
  );

  static const UserProfileModel defaultLandlord = UserProfileModel(
    id: 'usr-dhaka-landlord-001',
    phoneNumber: '+8801812345678',
    fullName: 'Haji Mohammad Rafiq (Owner)',
    role: UserRole.landlord,
    email: 'rafiq.properties@dhakagroup.com',
    occupation: 'Property Owner & Developer',
    workplace: 'Rafiq Heights, Dhanmondi 27',
    familySize: 4,
    nidNumber: '19842691234567890',
    isNidVerified: true,
    kycStatus: KycStatus.verified,
    presentAddress: 'House 42, Road 27, Dhanmondi, Dhaka',
    emergencyContact: 'Mohammad Ali (Brother) - 01855443322',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
    rentalRating: 4.8,
    completedRentals: 14,
  );

  UserProfileModel _currentUser = defaultTenant;
  bool _isAuthenticated = true;

  @override
  Future<bool> sendOtp(String phoneNumber) async {
    await Future.delayed(AppEnvironment.mockDelay);
    return true;
  }

  @override
  Future<UserProfileModel> verifyOtp(
    String phoneNumber,
    String otpCode, {
    UserRole role = UserRole.tenant,
  }) async {
    await Future.delayed(AppEnvironment.mockDelay);
    _isAuthenticated = true;

    final base = role == UserRole.landlord ? defaultLandlord : defaultTenant;
    _currentUser = UserProfileModel.fromEntity(
      base.toEntity().copyWith(
        phoneNumber: phoneNumber,
        role: role,
      ),
    );
    await TokenManager.saveSession(
      access: 'mock-jwt-access-${_currentUser.id}',
      refresh: 'mock-jwt-refresh-${_currentUser.id}',
      userId: _currentUser.id,
      userRole: _currentUser.role.name,
      userJson: _currentUser.toJson(),
    );
    return _currentUser;
  }

  @override
  Future<UserProfileModel> loginWithPassword({
    required String phoneNumber,
    required String password,
    UserRole? role,
  }) async {
    await Future.delayed(AppEnvironment.mockDelay);
    _isAuthenticated = true;

    final targetRole = role ?? (phoneNumber.contains('18') ? UserRole.landlord : UserRole.tenant);
    final base = targetRole == UserRole.landlord ? defaultLandlord : defaultTenant;
    _currentUser = UserProfileModel.fromEntity(
      base.toEntity().copyWith(
        phoneNumber: phoneNumber,
        role: targetRole,
      ),
    );
    await TokenManager.saveSession(
      access: 'mock-jwt-access-${_currentUser.id}',
      refresh: 'mock-jwt-refresh-${_currentUser.id}',
      userId: _currentUser.id,
      userRole: _currentUser.role.name,
      userJson: _currentUser.toJson(),
    );
    return _currentUser;
  }

  @override
  Future<UserProfileModel> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(AppEnvironment.mockDelay);
    _isAuthenticated = true;
    _currentUser = UserProfileModel(
      id: 'usr-dhaka-${DateTime.now().millisecondsSinceEpoch}',
      phoneNumber: phoneNumber,
      fullName: fullName,
      role: role,
      email: email,
      occupation: role == UserRole.landlord ? 'Property Owner' : 'Service Holder',
      workplace: role == UserRole.landlord ? 'Real Estate' : 'Dhaka Corporate Office',
      familySize: 2,
      nidNumber: '',
      isNidVerified: false,
      kycStatus: KycStatus.notSubmitted,
      presentAddress: '',
      emergencyContact: '',
      rentalRating: 5.0,
      completedRentals: 0,
    );
    await TokenManager.saveSession(
      access: 'mock-jwt-access-${_currentUser.id}',
      refresh: 'mock-jwt-refresh-${_currentUser.id}',
      userId: _currentUser.id,
      userRole: _currentUser.role.name,
      userJson: _currentUser.toJson(),
    );
    return _currentUser;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(AppEnvironment.mockDelay);
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
    await Future.delayed(AppEnvironment.mockDelay);
    _currentUser = UserProfileModel.fromEntity(
      _currentUser.toEntity().copyWith(
        nidNumber: nidNumber,
        presentAddress: presentAddress,
        emergencyContact: emergencyContact,
        isNidVerified: true,
        kycStatus: KycStatus.verified,
        nidFrontUrl: nidFrontUrl ?? 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f',
        nidBackUrl: nidBackUrl ?? 'https://images.unsplash.com/photo-1589829545856-d10d557cf95f',
        selfieUrl: selfieUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
      ),
    );
    if (TokenManager.hasToken) {
      await TokenManager.saveSession(
        access: TokenManager.accessToken!,
        refresh: TokenManager.refreshToken,
        userId: _currentUser.id,
        userRole: _currentUser.role.name,
        userJson: _currentUser.toJson(),
      );
    }
    return _currentUser;
  }

  @override
  Future<UserProfileModel?> getCurrentProfile() async {
    await Future.delayed(AppEnvironment.mockDelay);
    return _isAuthenticated ? _currentUser : null;
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    await Future.delayed(AppEnvironment.mockDelay);
    _currentUser = profile;
    if (TokenManager.hasToken) {
      await TokenManager.saveSession(
        access: TokenManager.accessToken!,
        refresh: TokenManager.refreshToken,
        userId: _currentUser.id,
        userRole: _currentUser.role.name,
        userJson: _currentUser.toJson(),
      );
    }
    return _currentUser;
  }

  @override
  Future<UserProfileModel> switchRole(UserRole newRole) async {
    await Future.delayed(AppEnvironment.mockDelay);
    if (newRole == UserRole.landlord) {
      _currentUser = defaultLandlord;
    } else {
      _currentUser = defaultTenant;
    }
    if (TokenManager.hasToken) {
      await TokenManager.saveSession(
        access: TokenManager.accessToken!,
        refresh: TokenManager.refreshToken,
        userId: _currentUser.id,
        userRole: _currentUser.role.name,
        userJson: _currentUser.toJson(),
      );
    }
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(AppEnvironment.mockDelay);
    _isAuthenticated = false;
    await TokenManager.clear();
  }
}
