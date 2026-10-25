import '../../domain/entities/tenant_inquiry.dart';

class ScreeningTenantInfoModel {
  const ScreeningTenantInfoModel({
    required this.fullName,
    required this.phoneNumber,
    this.isNidVerified = true,
    this.occupation = '',
    this.workplace = '',
    this.familyMembersCount = 1,
  });

  factory ScreeningTenantInfoModel.fromJson(Map<String, dynamic> json) {
    return ScreeningTenantInfoModel(
      fullName: json['full_name'] as String? ?? 'Verified Tenant',
      phoneNumber: json['phone_number'] as String? ?? '',
      isNidVerified: json['is_nid_verified'] as bool? ?? true,
      occupation: json['occupation'] as String? ?? '',
      workplace: json['workplace'] as String? ?? '',
      familyMembersCount: json['family_members_count'] as int? ?? 1,
    );
  }

  final String fullName;
  final String phoneNumber;
  final bool isNidVerified;
  final String occupation;
  final String workplace;
  final int familyMembersCount;

  ScreeningTenantInfo toEntity() => ScreeningTenantInfo(
        fullName: fullName,
        phoneNumber: phoneNumber,
        isNidVerified: isNidVerified,
        occupation: occupation,
        workplace: workplace,
        familyMembersCount: familyMembersCount,
      );
}

class TenantInquiryModel {
  const TenantInquiryModel({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.status,
    required this.message,
    this.tenant,
    this.createdAt,
  });

  factory TenantInquiryModel.fromJson(Map<String, dynamic> json) {
    ScreeningTenantInfoModel? tenantInfo;
    if (json['tenant'] is Map<String, dynamic>) {
      tenantInfo = ScreeningTenantInfoModel.fromJson(
          json['tenant'] as Map<String, dynamic>);
    }

    return TenantInquiryModel(
      id: json['id'] as String? ?? '',
      propertyId: json['property'] as String? ?? json['property_id'] as String? ?? '',
      propertyTitle: json['property_title'] as String? ?? 'Rental Property',
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String? ?? '',
      tenant: tenantInfo,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  final String id;
  final String propertyId;
  final String propertyTitle;
  final String status;
  final String message;
  final ScreeningTenantInfoModel? tenant;
  final DateTime? createdAt;

  TenantInquiry toEntity() => TenantInquiry(
        id: id,
        propertyId: propertyId,
        propertyTitle: propertyTitle,
        status: status,
        message: message,
        tenant: tenant?.toEntity(),
        createdAt: createdAt,
      );
}
