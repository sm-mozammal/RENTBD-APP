import '../../domain/entities/user_profile.dart';
import '../models/user_profile_model.dart';

/// Abstract DataSource contract for authentication.
abstract class AuthDataSource {
  Future<bool> sendOtp(String phoneNumber);
  Future<UserProfileModel> verifyOtp(
    String phoneNumber,
    String otpCode, {
    UserRole role = UserRole.tenant,
  });
  Future<UserProfileModel> loginWithPassword({
    required String phoneNumber,
    required String password,
    UserRole? role,
  });
  Future<UserProfileModel> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required UserRole role,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<UserProfileModel> submitKyc({
    required String nidNumber,
    required String presentAddress,
    required String emergencyContact,
    String? nidFrontUrl,
    String? nidBackUrl,
    String? selfieUrl,
  });
  Future<UserProfileModel?> getCurrentProfile();
  Future<UserProfileModel> updateProfile(UserProfileModel profile);
  Future<UserProfileModel> switchRole(UserRole newRole);
  Future<void> signOut();
}
