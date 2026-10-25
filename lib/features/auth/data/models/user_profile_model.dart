import '../../domain/entities/user_profile.dart';

/// Django REST Framework DTO for User Profile.
/// Matches Django snake_case JSON schema:
/// ```json
/// {
///   "id": "uuid",
///   "phone_number": "+88017...",
///   "full_name": "Tanvir Hasan",
///   "role": "TENANT",
///   "occupation": "Software Engineer",
///   "workplace": "Brain Station 23",
///   "family_size": 3,
///   "nid_number": "1994...",
///   "is_nid_verified": true,
///   "avatar_url": "...",
///   "rental_rating": 4.9,
///   "completed_rentals": 2
/// }
/// ```
class UserProfileModel {
  const UserProfileModel({
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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Unnest if wrapped in "user" or "data"
    final Map<String, dynamic> effectiveJson = Map<String, dynamic>.from(json);
    if (json['user'] is Map<String, dynamic>) {
      effectiveJson.addAll(json['user'] as Map<String, dynamic>);
    } else if (json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap['user'] is Map<String, dynamic>) {
        effectiveJson.addAll(dataMap['user'] as Map<String, dynamic>);
      }
      effectiveJson.addAll(dataMap);
    }

    UserRole parseRole(String? roleStr) {
      switch (roleStr?.toUpperCase()) {
        case 'LANDLORD':
          return UserRole.landlord;
        case 'DUAL':
          return UserRole.dual;
        case 'TENANT':
        default:
          return UserRole.tenant;
      }
    }

    bool? parseBool(dynamic val) {
      if (val == null) return null;
      if (val is bool) return val;
      if (val is num) return val == 1;
      if (val is String) {
        final lower = val.toLowerCase().trim();
        return lower == 'true' ||
            lower == '1' ||
            lower == 'verified' ||
            lower == 'approved' ||
            lower == 'completed' ||
            lower == 'complete' ||
            lower == 'passed' ||
            lower == 'yes' ||
            lower == 'y';
      }
      return null;
    }

    KycStatus parseKycStatus(String? statusStr) {
      if (statusStr == null) return KycStatus.notSubmitted;
      switch (statusStr.toUpperCase().trim()) {
        case 'VERIFIED':
        case 'APPROVED':
        case 'ACCEPTED':
        case 'SUCCESS':
        case 'TRUE':
        case 'COMPLETED':
        case 'COMPLETE':
        case 'PASSED':
        case 'VALIDATED':
        case 'DONE':
          return KycStatus.verified;
        case 'PENDING':
        case 'SUBMITTED':
        case 'IN_REVIEW':
        case 'PROCESSING':
        case 'UNDER_REVIEW':
          return KycStatus.pending;
        case 'REJECTED':
        case 'DECLINED':
        case 'FAILED':
          return KycStatus.rejected;
        case 'NOT_SUBMITTED':
        case 'NONE':
        default:
          return KycStatus.notSubmitted;
      }
    }

    // Support nested DRF profiles (tenant_profile, landlord_profile, profile, user_profile, landlord, tenant)
    final profileMap = effectiveJson['profile'] is Map<String, dynamic>
        ? effectiveJson['profile'] as Map<String, dynamic>
        : (effectiveJson['user_profile'] is Map<String, dynamic>
            ? effectiveJson['user_profile'] as Map<String, dynamic>
            : null);
    final tenantProfile = effectiveJson['tenant_profile'] is Map<String, dynamic>
        ? effectiveJson['tenant_profile'] as Map<String, dynamic>
        : (effectiveJson['tenant'] is Map<String, dynamic>
            ? effectiveJson['tenant'] as Map<String, dynamic>
            : null);
    final landlordProfile = effectiveJson['landlord_profile'] is Map<String, dynamic>
        ? effectiveJson['landlord_profile'] as Map<String, dynamic>
        : (effectiveJson['landlord'] is Map<String, dynamic>
            ? effectiveJson['landlord'] as Map<String, dynamic>
            : null);

    final occupation = (effectiveJson['occupation'] as String?)?.isNotEmpty == true
        ? effectiveJson['occupation'] as String
        : (tenantProfile?['occupation'] as String? ?? profileMap?['occupation'] as String? ?? '');

    final workplace = (effectiveJson['workplace'] as String?)?.isNotEmpty == true
        ? effectiveJson['workplace'] as String
        : (tenantProfile?['workplace'] as String? ?? profileMap?['workplace'] as String? ?? '');

    final familySize = effectiveJson['family_size'] as int? ??
        effectiveJson['familySize'] as int? ??
        tenantProfile?['family_members_count'] as int? ??
        profileMap?['family_members_count'] as int? ??
        1;

    final nidNumber = (effectiveJson['nid_number'] as String?)?.isNotEmpty == true
        ? effectiveJson['nid_number'] as String
        : (effectiveJson['nidNumber'] as String?)?.isNotEmpty == true
            ? effectiveJson['nidNumber'] as String
            : (landlordProfile?['nid_number'] as String?)?.isNotEmpty == true
                ? landlordProfile!['nid_number'] as String
                : (profileMap?['nid_number'] as String?)?.isNotEmpty == true
                    ? profileMap!['nid_number'] as String
                    : (tenantProfile?['nid_number'] as String? ?? '');

    final kycStatusRaw = effectiveJson['kyc_status'] as String? ??
        effectiveJson['kycStatus'] as String? ??
        effectiveJson['nid_status'] as String? ??
        effectiveJson['nidStatus'] as String? ??
        effectiveJson['verification_status'] as String? ??
        effectiveJson['status'] as String? ??
        landlordProfile?['kyc_status'] as String? ??
        landlordProfile?['nid_status'] as String? ??
        landlordProfile?['verification_status'] as String? ??
        landlordProfile?['status'] as String? ??
        profileMap?['kyc_status'] as String? ??
        profileMap?['nid_status'] as String? ??
        profileMap?['verification_status'] as String? ??
        profileMap?['status'] as String? ??
        tenantProfile?['kyc_status'] as String? ??
        tenantProfile?['nid_status'] as String? ??
        tenantProfile?['verification_status'] as String?;
    final kycStatusParsed = parseKycStatus(kycStatusRaw);

    final isNidVerifiedRaw = parseBool(effectiveJson['is_nid_verified']) ??
        parseBool(effectiveJson['isNidVerified']) ??
        parseBool(effectiveJson['is_verified']) ??
        parseBool(effectiveJson['isVerified']) ??
        parseBool(effectiveJson['is_kyc_verified']) ??
        parseBool(effectiveJson['isKycVerified']) ??
        parseBool(effectiveJson['kyc_verified']) ??
        parseBool(effectiveJson['nid_verified']) ??
        parseBool(effectiveJson['is_approved']) ??
        parseBool(effectiveJson['is_kyc_completed']) ??
        parseBool(effectiveJson['kyc_completed']) ??
        parseBool(effectiveJson['landlord_is_nid_verified']) ??
        parseBool(effectiveJson['landlordIsNidVerified']) ??
        parseBool(effectiveJson['tenant_is_nid_verified']) ??
        parseBool(effectiveJson['tenantIsNidVerified']) ??
        parseBool(landlordProfile?['is_nid_verified']) ??
        parseBool(landlordProfile?['isNidVerified']) ??
        parseBool(landlordProfile?['is_verified']) ??
        parseBool(landlordProfile?['isVerified']) ??
        parseBool(landlordProfile?['is_kyc_verified']) ??
        parseBool(landlordProfile?['kyc_verified']) ??
        parseBool(landlordProfile?['nid_verified']) ??
        parseBool(landlordProfile?['is_approved']) ??
        parseBool(landlordProfile?['is_kyc_completed']) ??
        parseBool(profileMap?['is_nid_verified']) ??
        parseBool(profileMap?['isNidVerified']) ??
        parseBool(profileMap?['is_verified']) ??
        parseBool(profileMap?['isVerified']) ??
        parseBool(profileMap?['is_kyc_verified']) ??
        parseBool(profileMap?['kyc_verified']) ??
        parseBool(profileMap?['nid_verified']) ??
        parseBool(profileMap?['is_approved']) ??
        parseBool(profileMap?['is_kyc_completed']) ??
        parseBool(tenantProfile?['is_nid_verified']) ??
        parseBool(tenantProfile?['isNidVerified']) ??
        parseBool(tenantProfile?['is_verified']);

    final hasValidNidNumber = nidNumber.replaceAll(RegExp(r'\D'), '').length >= 10;
    final isNidVerified = isNidVerifiedRaw ??
        (kycStatusParsed == KycStatus.verified ||
            (hasValidNidNumber && kycStatusParsed != KycStatus.rejected));
    final kycStatus = (isNidVerified && kycStatusParsed == KycStatus.notSubmitted)
        ? KycStatus.verified
        : kycStatusParsed;

    final avatarUrl = effectiveJson['avatar_url'] as String? ??
        effectiveJson['avatarUrl'] as String? ??
        effectiveJson['avatar'] as String?;

    final completedRentals = effectiveJson['completed_rentals'] as int? ??
        effectiveJson['completedRentals'] as int? ??
        landlordProfile?['total_properties'] as int? ??
        profileMap?['total_properties'] as int? ??
        0;

    final phoneNumber = effectiveJson['phone_number'] as String? ??
        effectiveJson['phoneNumber'] as String? ??
        '';

    final fullName = effectiveJson['full_name'] as String? ??
        effectiveJson['fullName'] as String? ??
        '';

    final presentAddress = effectiveJson['present_address'] as String? ??
        effectiveJson['presentAddress'] as String? ??
        landlordProfile?['present_address'] as String? ??
        landlordProfile?['presentAddress'] as String? ??
        profileMap?['present_address'] as String? ??
        profileMap?['presentAddress'] as String? ??
        tenantProfile?['present_address'] as String? ??
        '';

    final emergencyContact = effectiveJson['emergency_contact'] as String? ??
        effectiveJson['emergencyContact'] as String? ??
        effectiveJson['cims_emergency_contact'] as String? ??
        landlordProfile?['emergency_contact'] as String? ??
        landlordProfile?['cims_emergency_contact'] as String? ??
        profileMap?['emergency_contact'] as String? ??
        tenantProfile?['emergency_contact'] as String? ??
        '';

    final nidFrontUrl = effectiveJson['nid_front_url'] as String? ??
        effectiveJson['nidFrontUrl'] as String? ??
        effectiveJson['nid_front'] as String? ??
        landlordProfile?['nid_front_url'] as String? ??
        landlordProfile?['nid_front'] as String? ??
        profileMap?['nid_front_url'] as String? ??
        profileMap?['nid_front'] as String?;

    final nidBackUrl = effectiveJson['nid_back_url'] as String? ??
        effectiveJson['nidBackUrl'] as String? ??
        effectiveJson['nid_back'] as String? ??
        landlordProfile?['nid_back_url'] as String? ??
        landlordProfile?['nid_back'] as String? ??
        profileMap?['nid_back_url'] as String? ??
        profileMap?['nid_back'] as String?;

    final selfieUrl = effectiveJson['selfie_url'] as String? ??
        effectiveJson['selfieUrl'] as String? ??
        effectiveJson['selfie'] as String? ??
        landlordProfile?['selfie_url'] as String? ??
        landlordProfile?['selfie'] as String? ??
        profileMap?['selfie_url'] as String? ??
        profileMap?['selfie'] as String?;

    return UserProfileModel(
      id: effectiveJson['id']?.toString() ?? '',
      phoneNumber: phoneNumber,
      fullName: fullName,
      role: parseRole(effectiveJson['role'] as String?),
      email: effectiveJson['email'] as String? ?? '',
      occupation: occupation,
      workplace: workplace,
      familySize: familySize,
      nidNumber: nidNumber,
      isNidVerified: isNidVerified,
      kycStatus: kycStatus,
      presentAddress: presentAddress,
      emergencyContact: emergencyContact,
      nidFrontUrl: nidFrontUrl,
      nidBackUrl: nidBackUrl,
      selfieUrl: selfieUrl,
      avatarUrl: avatarUrl,
      rentalRating: (json['rental_rating'] as num?)?.toDouble() ??
          (json['rentalRating'] as num?)?.toDouble() ??
          5.0,
      completedRentals: completedRentals,
    );
  }

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      phoneNumber: entity.phoneNumber,
      fullName: entity.fullName,
      role: entity.role,
      email: entity.email,
      occupation: entity.occupation,
      workplace: entity.workplace,
      familySize: entity.familySize,
      nidNumber: entity.nidNumber,
      isNidVerified: entity.isNidVerified,
      kycStatus: entity.kycStatus,
      presentAddress: entity.presentAddress,
      emergencyContact: entity.emergencyContact,
      nidFrontUrl: entity.nidFrontUrl,
      nidBackUrl: entity.nidBackUrl,
      selfieUrl: entity.selfieUrl,
      avatarUrl: entity.avatarUrl,
      rentalRating: entity.rentalRating,
      completedRentals: entity.completedRentals,
    );
  }

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

  Map<String, dynamic> toJson() {
    String serializeRole(UserRole role) {
      switch (role) {
        case UserRole.landlord:
          return 'LANDLORD';
        case UserRole.dual:
          return 'DUAL';
        case UserRole.tenant:
          return 'TENANT';
      }
    }

    String serializeKycStatus(KycStatus status) {
      switch (status) {
        case KycStatus.verified:
          return 'VERIFIED';
        case KycStatus.pending:
          return 'PENDING';
        case KycStatus.rejected:
          return 'REJECTED';
        case KycStatus.notSubmitted:
          return 'NOT_SUBMITTED';
      }
    }

    return {
      'id': id,
      'phone_number': phoneNumber,
      'full_name': fullName,
      'role': serializeRole(role).toLowerCase(),
      'email': email,
      'occupation': occupation,
      'workplace': workplace,
      'family_size': familySize,
      'nid_number': nidNumber,
      'is_nid_verified': isNidVerified,
      'kyc_status': serializeKycStatus(kycStatus).toLowerCase(),
      'present_address': presentAddress,
      'emergency_contact': emergencyContact,
      'nid_front_url': nidFrontUrl,
      'nid_back_url': nidBackUrl,
      'selfie_url': selfieUrl,
      'avatar_url': avatarUrl,
      'rental_rating': rentalRating,
      'completed_rentals': completedRentals,
      'tenant_profile': {
        'occupation': occupation,
        'workplace': workplace,
        'family_members_count': familySize,
        'nid_number': nidNumber,
        'nid_status': serializeKycStatus(kycStatus).toLowerCase(),
      },
      'landlord_profile': {
        'total_properties': completedRentals,
      },
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      phoneNumber: phoneNumber,
      fullName: fullName,
      role: role,
      email: email,
      occupation: occupation,
      workplace: workplace,
      familySize: familySize,
      nidNumber: nidNumber,
      isNidVerified: isNidVerified,
      kycStatus: kycStatus,
      presentAddress: presentAddress,
      emergencyContact: emergencyContact,
      nidFrontUrl: nidFrontUrl,
      nidBackUrl: nidBackUrl,
      selfieUrl: selfieUrl,
      avatarUrl: avatarUrl,
      rentalRating: rentalRating,
      completedRentals: completedRentals,
    );
  }
}
