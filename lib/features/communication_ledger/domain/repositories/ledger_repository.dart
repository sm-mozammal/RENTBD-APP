import '../entities/rent_bill.dart';
import '../entities/rent_receipt.dart';
import '../entities/tenancy_contract.dart';

abstract class LedgerRepository {
  Future<TenancyContract> createTenancy({
    required String propertyId,
    required String tenantPhone,
    required String flatNumber,
    required double monthlyRent,
    required double serviceCharge,
    required double securityDeposit,
    required String contractStartDate,
    required String contractEndDate,
  });

  Future<List<TenancyContract>> getTenancies();

  Future<RentBill> issueBill({
    required String contractId,
    required String billingMonth,
    required double rentAmount,
    double serviceCharge = 0.0,
    double electricityBill = 0.0,
    double gasBill = 0.0,
    double waterBill = 0.0,
    required String dueDate,
  });

  Future<List<RentBill>> getBills({String? contractId});

  Future<RentReceipt> markBillPaid(
    String billId, {
    required String paymentMethod,
    required String transactionId,
  });

  Future<RentReceipt> getReceipt(String billId);
}
