import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class SendOtpRequestedEvent extends AuthEvent {
  const SendOtpRequestedEvent({required this.phoneNumber});
  final String phoneNumber;

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOtpRequestedEvent extends AuthEvent {
  const VerifyOtpRequestedEvent({
    required this.phoneNumber,
    required this.otpCode,
    this.role = UserRole.tenant,
  });

  final String phoneNumber;
  final String otpCode;
  final UserRole role;

  @override
  List<Object?> get props => [phoneNumber, otpCode, role];
}

class LoginWithPasswordRequestedEvent extends AuthEvent {
  const LoginWithPasswordRequestedEvent({
    required this.phoneNumber,
    required this.password,
    this.role,
  });

  final String phoneNumber;
  final String password;
  final UserRole? role;

  @override
  List<Object?> get props => [phoneNumber, password, role];
}

class RegisterRequestedEvent extends AuthEvent {
  const RegisterRequestedEvent({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.password,
    required this.role,
  });

  final String fullName;
  final String phoneNumber;
  final String email;
  final String password;
  final UserRole role;

  @override
  List<Object?> get props => [fullName, phoneNumber, email, password, role];
}

class ChangePasswordRequestedEvent extends AuthEvent {
  const ChangePasswordRequestedEvent({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class SubmitKycRequestedEvent extends AuthEvent {
  const SubmitKycRequestedEvent({
    required this.nidNumber,
    required this.presentAddress,
    required this.emergencyContact,
    this.nidFrontUrl,
    this.nidBackUrl,
    this.selfieUrl,
  });

  final String nidNumber;
  final String presentAddress;
  final String emergencyContact;
  final String? nidFrontUrl;
  final String? nidBackUrl;
  final String? selfieUrl;

  @override
  List<Object?> get props => [
        nidNumber,
        presentAddress,
        emergencyContact,
        nidFrontUrl,
        nidBackUrl,
        selfieUrl,
      ];
}

class UpdateProfileRequestedEvent extends AuthEvent {
  const UpdateProfileRequestedEvent({required this.profile});
  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

class SwitchRoleRequestedEvent extends AuthEvent {
  const SwitchRoleRequestedEvent({required this.newRole});
  final UserRole newRole;

  @override
  List<Object?> get props => [newRole];
}

class SignOutRequestedEvent extends AuthEvent {
  const SignOutRequestedEvent();
}
