import '../entities/rent_bill.dart';
import '../entities/rent_receipt.dart';
import '../entities/tenancy_contract.dart';
import '../repositories/ledger_repository.dart';

class CreateTenancyUseCase {
  const CreateTenancyUseCase(this.repository);
  final LedgerRepository repository;

  Future<TenancyContract> call({
    required String propertyId,
    required String tenantPhone,
    required String flatNumber,
    required double monthlyRent,
    required double serviceCharge,
    required double securityDeposit,
    required String contractStartDate,
    required String contractEndDate,
  }) {
    return repository.createTenancy(
      propertyId: propertyId,
      tenantPhone: tenantPhone,
      flatNumber: flatNumber,
      monthlyRent: monthlyRent,
      serviceCharge: serviceCharge,
      securityDeposit: securityDeposit,
      contractStartDate: contractStartDate,
      contractEndDate: contractEndDate,
    );
  }
}

class GetBillsUseCase {
  const GetBillsUseCase(this.repository);
  final LedgerRepository repository;

  Future<List<RentBill>> call({String? contractId}) =>
      repository.getBills(contractId: contractId);
}

class IssueBillUseCase {
  const IssueBillUseCase(this.repository);
  final LedgerRepository repository;

  Future<RentBill> call({
    required String contractId,
    required String billingMonth,
    required double rentAmount,
    double serviceCharge = 0.0,
    double electricityBill = 0.0,
    double gasBill = 0.0,
    double waterBill = 0.0,
    required String dueDate,
  }) {
    return repository.issueBill(
      contractId: contractId,
      billingMonth: billingMonth,
      rentAmount: rentAmount,
      serviceCharge: serviceCharge,
      electricityBill: electricityBill,
      gasBill: gasBill,
      waterBill: waterBill,
      dueDate: dueDate,
    );
  }
}

class MarkBillPaidUseCase {
  const MarkBillPaidUseCase(this.repository);
  final LedgerRepository repository;

  Future<RentReceipt> call(
    String billId, {
    required String paymentMethod,
    required String transactionId,
  }) {
    return repository.markBillPaid(
      billId,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
    );
  }
}

class GetReceiptUseCase {
  const GetReceiptUseCase(this.repository);
  final LedgerRepository repository;

  Future<RentReceipt> call(String billId) => repository.getReceipt(billId);
}
