import 'package:equatable/equatable.dart';

class RentBill extends Equatable {
  const RentBill({
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

  bool get isPaid => status.toLowerCase() == 'paid';

  @override
  List<Object?> get props => [
        id,
        billingMonth,
        rentAmount,
        serviceCharge,
        electricityBill,
        gasBill,
        waterBill,
        totalAmount,
        status,
        dueDate,
        paidAt,
        receiptNumber,
      ];
}
