import '../entities/tenant_inquiry.dart';
import '../entities/visit_booking.dart';

abstract class VisitRepository {
  Future<VisitBooking> bookVisit({
    required String propertyId,
    required String scheduledDate,
    required String timeSlot,
    required VisitType visitType,
    String? propertyTitle,
    String? area,
    String? landlordName,
    String? notes,
  });

  Future<List<VisitBooking>> getMyVisits();

  Future<VisitBooking> updateVisitStatus(String visitId, VisitStatus status);

  Future<TenantInquiry> submitInquiry(String propertyId, String message);

  Future<List<TenantInquiry>> getLandlordScreeningInbox();
}
