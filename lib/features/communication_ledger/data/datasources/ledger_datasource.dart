import '../models/rent_bill_model.dart';
import '../models/rent_receipt_model.dart';
import '../models/tenancy_contract_model.dart';

abstract class LedgerDataSource {
  Future<TenancyContractModel> createTenancy(Map<String, dynamic> data);
  Future<List<TenancyContractModel>> getTenancies();
  Future<RentBillModel> issueBill(Map<String, dynamic> billData);
  Future<List<RentBillModel>> getBills({String? contractId});
  Future<RentReceiptModel> markBillPaid(String billId, {required String paymentMethod, required String transactionId});
  Future<RentReceiptModel> getReceipt(String billId);
}
