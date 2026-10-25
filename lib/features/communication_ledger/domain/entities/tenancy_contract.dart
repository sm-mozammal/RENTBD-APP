import 'package:equatable/equatable.dart';

class TenancyContract extends Equatable {
  const TenancyContract({
    required this.id,
    required this.propertyId,
    required this.tenantPhone,
    required this.flatNumber,
    required this.monthlyRent,
    required this.serviceCharge,
    required this.securityDeposit,
    required this.contractStartDate,
    required this.contractEndDate,
    this.isActive = true,
  });

  final String id;
  final String propertyId;
  final String tenantPhone;
  final String flatNumber;
  final double monthlyRent;
  final double serviceCharge;
  final double securityDeposit;
  final String contractStartDate;
  final String contractEndDate;
  final bool isActive;

  @override
  List<Object?> get props => [
        id,
        propertyId,
        tenantPhone,
        flatNumber,
        monthlyRent,
        serviceCharge,
        securityDeposit,
        contractStartDate,
        contractEndDate,
        isActive,
      ];
}
