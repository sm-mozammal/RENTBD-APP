import 'package:rentbd_app/core/config/app_environment.dart';
import '../models/rent_bill_model.dart';
import '../models/rent_receipt_model.dart';
import '../models/tenancy_contract_model.dart';
import 'ledger_datasource.dart';

class LedgerMockDataSource implements LedgerDataSource {
  final List<TenancyContractModel> _contracts = [
    const TenancyContractModel(
      id: 'contract-01',
      propertyId: 'prop-mirpur-01',
      tenantPhone: '+8801712345678',
      flatNumber: '4B',
      monthlyRent: 16500,
      serviceCharge: 2500,
      securityDeposit: 33000,
      contractStartDate: '2026-08-01',
      contractEndDate: '2027-07-31',
    ),
  ];

  final List<RentBillModel> _bills = [
    RentBillModel(
      id: 'bill-2026-10',
      billingMonth: 'October 2026 (Current)',
      rentAmount: 16500,
      serviceCharge: 2500,
      electricityBill: 1200,
      gasBill: 1080,
      waterBill: 500,
      totalAmount: 21780,
      status: 'unpaid',
      dueDate: '2026-10-10',
      receiptNumber: 'REC-2026-10-88',
    ),
    RentBillModel(
      id: 'bill-2026-09',
      billingMonth: 'September 2026',
      rentAmount: 16500,
      serviceCharge: 2500,
      electricityBill: 1450,
      gasBill: 1080,
      waterBill: 500,
      totalAmount: 22030,
      status: 'paid',
      dueDate: '2026-09-10',
      paidAt: DateTime(2026, 9, 3),
      receiptNumber: 'REC-2026-09-41',
    ),
    RentBillModel(
      id: 'bill-2026-08',
      billingMonth: 'August 2026',
      rentAmount: 16500,
      serviceCharge: 2500,
      electricityBill: 1380,
      gasBill: 1080,
      waterBill: 500,
      totalAmount: 21960,
      status: 'paid',
      dueDate: '2026-08-10',
      paidAt: DateTime(2026, 8, 4),
      receiptNumber: 'REC-2026-08-19',
    ),
  ];

  @override
  Future<TenancyContractModel> createTenancy(Map<String, dynamic> data) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final newContract = TenancyContractModel.fromJson({
      'id': 'contract-${DateTime.now().millisecondsSinceEpoch}',
      ...data,
    });
    _contracts.insert(0, newContract);
    return newContract;
  }

  @override
  Future<List<TenancyContractModel>> getTenancies() async {
    await Future.delayed(AppEnvironment.mockDelay);
    return List.from(_contracts);
  }

  @override
  Future<RentBillModel> issueBill(Map<String, dynamic> billData) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final newBill = RentBillModel.fromJson({
      'id': 'bill-${DateTime.now().millisecondsSinceEpoch}',
      ...billData,
    });
    _bills.insert(0, newBill);
    return newBill;
  }

  @override
  Future<List<RentBillModel>> getBills({String? contractId}) async {
    await Future.delayed(AppEnvironment.mockDelay);
    return List.from(_bills);
  }

  @override
  Future<RentReceiptModel> markBillPaid(
    String billId, {
    required String paymentMethod,
    required String transactionId,
  }) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final idx = _bills.indexWhere((b) => b.id == billId);
    if (idx != -1) {
      final current = _bills[idx];
      final recNum = 'REC-${DateTime.now().year}${DateTime.now().month}-${billId.substring(billId.length - 4)}';
      _bills[idx] = RentBillModel(
        id: current.id,
        billingMonth: current.billingMonth,
        rentAmount: current.rentAmount,
        serviceCharge: current.serviceCharge,
        electricityBill: current.electricityBill,
        gasBill: current.gasBill,
        waterBill: current.waterBill,
        totalAmount: current.totalAmount,
        status: 'paid',
        dueDate: current.dueDate,
        paidAt: DateTime.now(),
        receiptNumber: recNum,
      );
      return RentReceiptModel(
        receiptNumber: recNum,
        propertyTitle: 'Modern Flat in Mirpur 10',
        flatNumber: '4B',
        tenantName: 'Rahim Ahmed',
        landlordName: 'Kamal Hossain',
        billingMonth: current.billingMonth,
        itemizedBreakdown: {
          'rent': current.rentAmount,
          'service_charge': current.serviceCharge,
          'electricity': current.electricityBill,
          'gas': current.gasBill,
          'water': current.waterBill,
        },
        totalPaid: current.totalAmount,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
        paidAt: DateTime.now(),
        digitalSignatureHash: 'sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    }
    throw Exception('Bill not found');
  }

  @override
  Future<RentReceiptModel> getReceipt(String billId) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final bill = _bills.firstWhere(
      (b) => b.id == billId,
      orElse: () => _bills.first,
    );
    return RentReceiptModel(
      receiptNumber: bill.receiptNumber ?? 'REC-202611-4B92',
      propertyTitle: 'Modern Flat in Mirpur 10',
      flatNumber: '4B',
      tenantName: 'Rahim Ahmed',
      landlordName: 'Kamal Hossain',
      billingMonth: bill.billingMonth,
      itemizedBreakdown: {
        'rent': bill.rentAmount,
        'service_charge': bill.serviceCharge,
        'electricity': bill.electricityBill,
        'gas': bill.gasBill,
        'water': bill.waterBill,
      },
      totalPaid: bill.totalAmount,
      paymentMethod: 'bKash',
      transactionId: 'BK89239102',
      paidAt: bill.paidAt ?? DateTime.now(),
      digitalSignatureHash: 'sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    );
  }
}
