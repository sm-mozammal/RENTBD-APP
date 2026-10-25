import 'package:dio/dio.dart';
import 'package:rentbd_app/core/error/exceptions.dart';
import 'package:rentbd_app/core/network/dio_client.dart';
import '../models/rent_bill_model.dart';
import '../models/rent_receipt_model.dart';
import '../models/tenancy_contract_model.dart';
import 'ledger_datasource.dart';

class LedgerRemoteDataSource implements LedgerDataSource {
  const LedgerRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<TenancyContractModel> createTenancy(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/ledger/tenancies/', data: data);
      return TenancyContractModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to create tenancy: $e');
    }
  }

  @override
  Future<List<TenancyContractModel>> getTenancies() async {
    try {
      final response = await _dioClient.get('/ledger/tenancies/');
      final list = (response.data is Map && response.data['results'] != null)
          ? response.data['results'] as List<dynamic>
          : response.data as List<dynamic>? ?? [];
      return list
          .map((item) => TenancyContractModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch tenancies: $e');
    }
  }

  @override
  Future<RentBillModel> issueBill(Map<String, dynamic> billData) async {
    try {
      final response = await _dioClient.post('/ledger/bills/', data: billData);
      return RentBillModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to issue rent bill: $e');
    }
  }

  @override
  Future<List<RentBillModel>> getBills({String? contractId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (contractId != null) queryParams['contract'] = contractId;

      final response = await _dioClient.get('/ledger/bills/', queryParameters: queryParams);
      final list = (response.data is Map && response.data['results'] != null)
          ? response.data['results'] as List<dynamic>
          : response.data as List<dynamic>? ?? [];
      return list
          .map((item) => RentBillModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch bills: $e');
    }
  }

  @override
  Future<RentReceiptModel> markBillPaid(
    String billId, {
    required String paymentMethod,
    required String transactionId,
  }) async {
    try {
      final response = await _dioClient.post(
        '/ledger/bills/$billId/mark-paid/',
        data: {
          'payment_method': paymentMethod,
          'transaction_id': transactionId,
        },
      );
      final data = response.data as Map<String, dynamic>;
      // If receipt is embedded or fetch receipt
      if (data.containsKey('receipt_number')) {
        return RentReceiptModel.fromJson(data);
      }
      return await getReceipt(billId);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to mark bill paid: $e');
    }
  }

  @override
  Future<RentReceiptModel> getReceipt(String billId) async {
    try {
      final response = await _dioClient.get('/ledger/bills/$billId/receipt/');
      return RentReceiptModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch digital receipt: $e');
    }
  }
}
