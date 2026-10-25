import '../../domain/entities/tenancy_contract.dart';

class TenancyContractModel {
  const TenancyContractModel({
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

  factory TenancyContractModel.fromJson(Map<String, dynamic> json) {
    return TenancyContractModel(
      id: json['id'] as String? ?? '',
      propertyId: json['property'] as String? ?? json['property_id'] as String? ?? '',
      tenantPhone: json['tenant_phone'] as String? ?? '',
      flatNumber: json['flat_number'] as String? ?? '',
      monthlyRent: (json['monthly_rent'] as num?)?.toDouble() ?? 0.0,
      serviceCharge: (json['service_charge'] as num?)?.toDouble() ?? 0.0,
      securityDeposit: (json['security_deposit'] as num?)?.toDouble() ?? 0.0,
      contractStartDate: json['contract_start_date'] as String? ?? '',
      contractEndDate: json['contract_end_date'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

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

  Map<String, dynamic> toJson() => {
        'property': propertyId,
        'tenant_phone': tenantPhone,
        'flat_number': flatNumber,
        'monthly_rent': monthlyRent,
        'service_charge': serviceCharge,
        'security_deposit': securityDeposit,
        'contract_start_date': contractStartDate,
        'contract_end_date': contractEndDate,
      };

  TenancyContract toEntity() => TenancyContract(
        id: id,
        propertyId: propertyId,
        tenantPhone: tenantPhone,
        flatNumber: flatNumber,
        monthlyRent: monthlyRent,
        serviceCharge: serviceCharge,
        securityDeposit: securityDeposit,
        contractStartDate: contractStartDate,
        contractEndDate: contractEndDate,
        isActive: isActive,
      );
}
