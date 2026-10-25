import '../entities/user_profile.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  const SendOtpUseCase(this._repository);
  final AuthRepository _repository;

  Future<bool> call(String phoneNumber) => _repository.sendOtp(phoneNumber);
}

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);
  final AuthRepository _repository;

  Future<UserProfile> call(
    String phoneNumber,
    String otpCode, {
    UserRole role = UserRole.tenant,
  }) =>
      _repository.verifyOtp(phoneNumber, otpCode, role: role);
}

class LoginWithPasswordUseCase {
  const LoginWithPasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<UserProfile> call({
    required String phoneNumber,
    required String password,
    UserRole? role,
  }) =>
      _repository.loginWithPassword(
        phoneNumber: phoneNumber,
        password: password,
        role: role,
      );
}

class GetProfileUseCase {
  const GetProfileUseCase(this._repository);
  final AuthRepository _repository;

  Future<UserProfile?> call() => _repository.getCurrentProfile();
}

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);
  final AuthRepository _repository;

  Future<UserProfile> call(UserProfile profile) => _repository.updateProfile(profile);
}

class RegisterUseCase {
  const RegisterUseCase(this._repository);
  final AuthRepository _repository;

  Future<UserProfile> call({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required UserRole role,
  }) =>
      _repository.register(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        role: role,
      );
}

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) =>
      _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
}

class SubmitKycUseCase {
  const SubmitKycUseCase(this._repository);
  final AuthRepository _repository;

  Future<UserProfile> call({
    required String nidNumber,
    required String presentAddress,
    required String emergencyContact,
    String? nidFrontUrl,
    String? nidBackUrl,
    String? selfieUrl,
  }) =>
      _repository.submitKyc(
        nidNumber: nidNumber,
        presentAddress: presentAddress,
        emergencyContact: emergencyContact,
        nidFrontUrl: nidFrontUrl,
        nidBackUrl: nidBackUrl,
        selfieUrl: selfieUrl,
      );
}

class SwitchRoleUseCase {
  const SwitchRoleUseCase(this._repository);
  final AuthRepository _repository;

  Future<UserProfile> call(UserRole newRole) => _repository.switchRole(newRole);
}

class SignOutUseCase {
  const SignOutUseCase(this._repository);
  final AuthRepository _repository;

  Future<void> call() => _repository.signOut();
}

