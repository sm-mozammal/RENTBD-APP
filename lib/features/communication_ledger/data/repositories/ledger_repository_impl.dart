import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:rentbd_app/core/error/exceptions.dart';
import 'package:rentbd_app/core/error/failures.dart';
import '../../domain/entities/rent_bill.dart';
import '../../domain/entities/rent_receipt.dart';
import '../../domain/entities/tenancy_contract.dart';
import '../../domain/repositories/ledger_repository.dart';
import '../datasources/ledger_datasource.dart';

class LedgerRepositoryImpl implements LedgerRepository {
  LedgerRepositoryImpl({
    required this.mockDataSource,
    required this.remoteDataSource,
  });

  final LedgerDataSource mockDataSource;
  final LedgerDataSource remoteDataSource;

  LedgerDataSource get _activeDataSource =>
      AppEnvironment.useMockData ? mockDataSource : remoteDataSource;

  @override
  Future<TenancyContract> createTenancy({
    required String propertyId,
    required String tenantPhone,
    required String flatNumber,
    required double monthlyRent,
    required double serviceCharge,
    required double securityDeposit,
    required String contractStartDate,
    required String contractEndDate,
  }) async {
    try {
      final model = await _activeDataSource.createTenancy({
        'property': propertyId,
        'tenant_phone': tenantPhone,
        'flat_number': flatNumber,
        'monthly_rent': monthlyRent,
        'service_charge': serviceCharge,
        'security_deposit': securityDeposit,
        'contract_start_date': contractStartDate,
        'contract_end_date': contractEndDate,
      });
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<List<TenancyContract>> getTenancies() async {
    try {
      final models = await _activeDataSource.getTenancies();
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<RentBill> issueBill({
    required String contractId,
    required String billingMonth,
    required double rentAmount,
    double serviceCharge = 0.0,
    double electricityBill = 0.0,
    double gasBill = 0.0,
    double waterBill = 0.0,
    required String dueDate,
  }) async {
    try {
      final model = await _activeDataSource.issueBill({
        'contract': contractId,
        'billing_month': billingMonth,
        'rent_amount': rentAmount,
        'service_charge': serviceCharge,
        'electricity_bill': electricityBill,
        'gas_bill': gasBill,
        'water_bill': waterBill,
        'due_date': dueDate,
      });
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<List<RentBill>> getBills({String? contractId}) async {
    try {
      final models = await _activeDataSource.getBills(contractId: contractId);
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<RentReceipt> markBillPaid(
    String billId, {
    required String paymentMethod,
    required String transactionId,
  }) async {
    try {
      final model = await _activeDataSource.markBillPaid(
        billId,
        paymentMethod: paymentMethod,
        transactionId: transactionId,
      );
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<RentReceipt> getReceipt(String billId) async {
    try {
      final model = await _activeDataSource.getReceipt(billId);
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }
}
