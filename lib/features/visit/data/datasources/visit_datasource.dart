import '../models/tenant_inquiry_model.dart';
import '../models/visit_booking_model.dart';

abstract class VisitDataSource {
  Future<VisitBookingModel> bookVisit(Map<String, dynamic> data);
  Future<List<VisitBookingModel>> getMyVisits();
  Future<VisitBookingModel> updateVisitStatus(String visitId, String status);
  Future<TenantInquiryModel> submitInquiry(String propertyId, String message);
  Future<List<TenantInquiryModel>> getLandlordScreeningInbox();
}
