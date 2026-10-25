import 'package:dio/dio.dart';
import 'package:rentbd_app/core/error/exceptions.dart';
import 'package:rentbd_app/core/network/dio_client.dart';
import '../models/tenant_inquiry_model.dart';
import '../models/visit_booking_model.dart';
import 'visit_datasource.dart';

class VisitRemoteDataSource implements VisitDataSource {
  const VisitRemoteDataSource(this._dioClient);

  final DioClient _dioClient;

  @override
  Future<VisitBookingModel> bookVisit(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/inquiries/visits/', data: data);
      return VisitBookingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to book visit: $e');
    }
  }

  @override
  Future<List<VisitBookingModel>> getMyVisits() async {
    try {
      final response = await _dioClient.get('/inquiries/visits/');
      final list = (response.data is Map && response.data['results'] != null)
          ? response.data['results'] as List<dynamic>
          : response.data as List<dynamic>? ?? [];
      return list
          .map((item) => VisitBookingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch visits: $e');
    }
  }

  @override
  Future<VisitBookingModel> updateVisitStatus(String visitId, String status) async {
    try {
      final response = await _dioClient.patch(
        '/inquiries/visits/$visitId/',
        data: {'status': status},
      );
      return VisitBookingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to update visit status: $e');
    }
  }

  @override
  Future<TenantInquiryModel> submitInquiry(String propertyId, String message) async {
    try {
      final response = await _dioClient.post(
        '/inquiries/',
        data: {
          'property': propertyId,
          'message': message,
        },
      );
      return TenantInquiryModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to submit inquiry: $e');
    }
  }

  @override
  Future<List<TenantInquiryModel>> getLandlordScreeningInbox() async {
    try {
      final response = await _dioClient.get('/inquiries/landlord-inbox/');
      final list = (response.data is Map && response.data['results'] != null)
          ? response.data['results'] as List<dynamic>
          : response.data as List<dynamic>? ?? [];
      return list
          .map((item) => TenantInquiryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerException.fromDio(e);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch screening inbox: $e');
    }
  }
}
