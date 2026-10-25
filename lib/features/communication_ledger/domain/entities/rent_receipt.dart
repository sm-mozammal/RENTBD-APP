import 'package:equatable/equatable.dart';

class RentReceipt extends Equatable {
  const RentReceipt({
    required this.receiptNumber,
    required this.propertyTitle,
    required this.flatNumber,
    required this.tenantName,
    required this.landlordName,
    required this.billingMonth,
    required this.itemizedBreakdown,
    required this.totalPaid,
    required this.paymentMethod,
    required this.transactionId,
    required this.paidAt,
    required this.digitalSignatureHash,
  });

  final String receiptNumber;
  final String propertyTitle;
  final String flatNumber;
  final String tenantName;
  final String landlordName;
  final String billingMonth;
  final Map<String, dynamic> itemizedBreakdown;
  final double totalPaid;
  final String paymentMethod;
  final String transactionId;
  final DateTime paidAt;
  final String digitalSignatureHash;

  @override
  List<Object?> get props => [
        receiptNumber,
        propertyTitle,
        flatNumber,
        tenantName,
        landlordName,
        billingMonth,
        itemizedBreakdown,
        totalPaid,
        paymentMethod,
        transactionId,
        paidAt,
        digitalSignatureHash,
      ];
}
