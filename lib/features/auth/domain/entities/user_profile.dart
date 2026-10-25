import 'package:equatable/equatable.dart';

enum UserRole { tenant, landlord, dual }

enum KycStatus { notSubmitted, pending, verified, rejected }

/// Pure Dart entity representing a verified RentBD user.
/// Presentation and UI layers consume ONLY this domain entity.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.role,
    this.email = '',
    this.occupation = '',
    this.workplace = '',
    this.familySize = 1,
    this.nidNumber = '',
    this.isNidVerified = false,
    this.kycStatus = KycStatus.notSubmitted,
    this.presentAddress = '',
    this.emergencyContact = '',
    this.nidFrontUrl,
    this.nidBackUrl,
    this.selfieUrl,
    this.avatarUrl,
    this.rentalRating = 5.0,
    this.completedRentals = 0,
  });

  final String id;
  final String phoneNumber;
  final String fullName;
  final UserRole role;
  final String email;
  final String occupation;
  final String workplace;
  final int familySize;
  final String nidNumber;
  final bool isNidVerified;
  final KycStatus kycStatus;
  final String presentAddress;
  final String emergencyContact;
  final String? nidFrontUrl;
  final String? nidBackUrl;
  final String? selfieUrl;
  final String? avatarUrl;
  final double rentalRating;
  final int completedRentals;

  bool get isLandlord => role == UserRole.landlord || role == UserRole.dual;
  bool get isTenant => role == UserRole.tenant || role == UserRole.dual;
  bool get isKycCompleted => isNidVerified || kycStatus == KycStatus.verified;

  UserProfile copyWith({
    String? id,
    String? phoneNumber,
    String? fullName,
    UserRole? role,
    String? email,
    String? occupation,
    String? workplace,
    int? familySize,
    String? nidNumber,
    bool? isNidVerified,
    KycStatus? kycStatus,
    String? presentAddress,
    String? emergencyContact,
    String? nidFrontUrl,
    String? nidBackUrl,
    String? selfieUrl,
    String? avatarUrl,
    double? rentalRating,
    int? completedRentals,
  }) {
    return UserProfile(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      email: email ?? this.email,
      occupation: occupation ?? this.occupation,
      workplace: workplace ?? this.workplace,
      familySize: familySize ?? this.familySize,
      nidNumber: nidNumber ?? this.nidNumber,
      isNidVerified: isNidVerified ?? this.isNidVerified,
      kycStatus: kycStatus ?? this.kycStatus,
      presentAddress: presentAddress ?? this.presentAddress,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      nidFrontUrl: nidFrontUrl ?? this.nidFrontUrl,
      nidBackUrl: nidBackUrl ?? this.nidBackUrl,
      selfieUrl: selfieUrl ?? this.selfieUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rentalRating: rentalRating ?? this.rentalRating,
      completedRentals: completedRentals ?? this.completedRentals,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        fullName,
        role,
        email,
        occupation,
        workplace,
        familySize,
        nidNumber,
        isNidVerified,
        kycStatus,
        presentAddress,
        emergencyContact,
        nidFrontUrl,
        nidBackUrl,
        selfieUrl,
        avatarUrl,
        rentalRating,
        completedRentals,
      ];
}
