import 'package:equatable/equatable.dart';

class ScreeningTenantInfo extends Equatable {
  const ScreeningTenantInfo({
    required this.fullName,
    required this.phoneNumber,
    this.isNidVerified = true,
    this.occupation = '',
    this.workplace = '',
    this.familyMembersCount = 1,
  });

  final String fullName;
  final String phoneNumber;
  final bool isNidVerified;
  final String occupation;
  final String workplace;
  final int familyMembersCount;

  @override
  List<Object?> get props => [
        fullName,
        phoneNumber,
        isNidVerified,
        occupation,
        workplace,
        familyMembersCount,
      ];
}

class TenantInquiry extends Equatable {
  const TenantInquiry({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.status,
    required this.message,
    this.tenant,
    this.createdAt,
  });

  final String id;
  final String propertyId;
  final String propertyTitle;
  final String status;
  final String message;
  final ScreeningTenantInfo? tenant;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        propertyId,
        propertyTitle,
        status,
        message,
        tenant,
        createdAt,
      ];
}
