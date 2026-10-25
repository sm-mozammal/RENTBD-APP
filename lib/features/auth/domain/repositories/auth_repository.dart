import '../entities/user_profile.dart';

/// Abstract contract for authentication and profile management.
abstract class AuthRepository {
  /// Request an OTP to be sent via SMS to [phoneNumber]
  Future<bool> sendOtp(String phoneNumber);

  /// Verify [otpCode] against [phoneNumber] and return active [UserProfile] with selected role
  Future<UserProfile> verifyOtp(
    String phoneNumber,
    String otpCode, {
    UserRole role = UserRole.tenant,
  });

  /// Authenticate with mobile number and password
  Future<UserProfile> loginWithPassword({
    required String phoneNumber,
    required String password,
    UserRole? role,
  });

  /// Register a new user profile with selected role
  Future<UserProfile> register({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required UserRole role,
  });

  /// Change active user password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Submit KYC verification details (NID, Dhaka address, emergency contact)
  Future<UserProfile> submitKyc({
    required String nidNumber,
    required String presentAddress,
    required String emergencyContact,
    String? nidFrontUrl,
    String? nidBackUrl,
    String? selfieUrl,
  });

  /// Fetch currently authenticated user profile
  Future<UserProfile?> getCurrentProfile();

  /// Update user profile details (occupation, workplace, family size, NID)
  Future<UserProfile> updateProfile(UserProfile updatedProfile);

  /// Switch active operational role (Tenant <-> Landlord)
  Future<UserProfile> switchRole(UserRole newRole);

  /// Sign out current user
  Future<void> signOut();
}
