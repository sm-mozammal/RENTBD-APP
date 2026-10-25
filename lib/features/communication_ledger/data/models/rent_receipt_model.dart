import '../../domain/entities/rent_receipt.dart';

class RentReceiptModel {
  const RentReceiptModel({
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

  factory RentReceiptModel.fromJson(Map<String, dynamic> json) {
    return RentReceiptModel(
      receiptNumber: json['receipt_number'] as String? ?? 'REC-PENDING',
      propertyTitle: json['property_title'] as String? ?? 'Residential Flat',
      flatNumber: json['flat_number'] as String? ?? '',
      tenantName: json['tenant_name'] as String? ?? '',
      landlordName: json['landlord_name'] as String? ?? '',
      billingMonth: json['billing_month'] as String? ?? '',
      itemizedBreakdown: json['itemized_breakdown'] as Map<String, dynamic>? ?? {},
      totalPaid: (json['total_paid'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String? ?? 'bKash',
      transactionId: json['transaction_id'] as String? ?? '',
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      digitalSignatureHash: json['digital_signature_hash'] as String? ?? '',
    );
  }

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

  RentReceipt toEntity() => RentReceipt(
        receiptNumber: receiptNumber,
        propertyTitle: propertyTitle,
        flatNumber: flatNumber,
        tenantName: tenantName,
        landlordName: landlordName,
        billingMonth: billingMonth,
        itemizedBreakdown: itemizedBreakdown,
        totalPaid: totalPaid,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        paidAt: paidAt,
        digitalSignatureHash: digitalSignatureHash,
      );
}
