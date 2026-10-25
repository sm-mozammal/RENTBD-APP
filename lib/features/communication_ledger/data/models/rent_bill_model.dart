import '../../domain/entities/rent_bill.dart';

class RentBillModel {
  const RentBillModel({
    required this.id,
    required this.billingMonth,
    required this.rentAmount,
    this.serviceCharge = 0.0,
    this.electricityBill = 0.0,
    this.gasBill = 0.0,
    this.waterBill = 0.0,
    required this.totalAmount,
    required this.status,
    required this.dueDate,
    this.paidAt,
    this.receiptNumber,
  });

  factory RentBillModel.fromJson(Map<String, dynamic> json) {
    final rent = (json['rent_amount'] as num?)?.toDouble() ??
        (json['rent'] as num?)?.toDouble() ??
        0.0;
    final sc = (json['service_charge'] as num?)?.toDouble() ?? 0.0;
    final elec = (json['electricity_bill'] as num?)?.toDouble() ?? 0.0;
    final gas = (json['gas_bill'] as num?)?.toDouble() ?? 0.0;
    final water = (json['water_bill'] as num?)?.toDouble() ?? 0.0;
    final total = (json['total_amount'] as num?)?.toDouble() ??
        (rent + sc + elec + gas + water);

    return RentBillModel(
      id: json['id'] as String? ?? '',
      billingMonth: json['billing_month'] as String? ?? '',
      rentAmount: rent,
      serviceCharge: sc,
      electricityBill: elec,
      gasBill: gas,
      waterBill: water,
      totalAmount: total,
      status: json['status'] as String? ?? 'unpaid',
      dueDate: json['due_date'] as String? ?? '',
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'] as String)
          : null,
      receiptNumber: json['receipt_number'] as String?,
    );
  }

  final String id;
  final String billingMonth;
  final double rentAmount;
  final double serviceCharge;
  final double electricityBill;
  final double gasBill;
  final double waterBill;
  final double totalAmount;
  final String status;
  final String dueDate;
  final DateTime? paidAt;
  final String? receiptNumber;

  Map<String, dynamic> toJson() => {
        'billing_month': billingMonth,
        'rent_amount': rentAmount,
        'service_charge': serviceCharge,
        'electricity_bill': electricityBill,
        'gas_bill': gasBill,
        'water_bill': waterBill,
        'total_amount': totalAmount,
        'status': status,
        'due_date': dueDate,
      };

  RentBill toEntity() => RentBill(
        id: id,
        billingMonth: billingMonth,
        rentAmount: rentAmount,
        serviceCharge: serviceCharge,
        electricityBill: electricityBill,
        gasBill: gasBill,
        waterBill: waterBill,
        totalAmount: totalAmount,
        status: status,
        dueDate: dueDate,
        paidAt: paidAt,
        receiptNumber: receiptNumber,
      );
}
