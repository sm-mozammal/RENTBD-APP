import '../entities/tenant_inquiry.dart';
import '../entities/visit_booking.dart';
import '../repositories/visit_repository.dart';

class BookVisitUseCase {
  const BookVisitUseCase(this.repository);
  final VisitRepository repository;

  Future<VisitBooking> call({
    required String propertyId,
    required String scheduledDate,
    required String timeSlot,
    required VisitType visitType,
    String? propertyTitle,
    String? area,
    String? landlordName,
    String? notes,
  }) {
    return repository.bookVisit(
      propertyId: propertyId,
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      visitType: visitType,
      propertyTitle: propertyTitle,
      area: area,
      landlordName: landlordName,
      notes: notes,
    );
  }
}

class GetMyVisitsUseCase {
  const GetMyVisitsUseCase(this.repository);
  final VisitRepository repository;

  Future<List<VisitBooking>> call() => repository.getMyVisits();
}

class UpdateVisitStatusUseCase {
  const UpdateVisitStatusUseCase(this.repository);
  final VisitRepository repository;

  Future<VisitBooking> call(String visitId, VisitStatus status) =>
      repository.updateVisitStatus(visitId, status);
}

class SubmitInquiryUseCase {
  const SubmitInquiryUseCase(this.repository);
  final VisitRepository repository;

  Future<TenantInquiry> call(String propertyId, String message) =>
      repository.submitInquiry(propertyId, message);
}

class GetScreeningInboxUseCase {
  const GetScreeningInboxUseCase(this.repository);
  final VisitRepository repository;

  Future<List<TenantInquiry>> call() => repository.getLandlordScreeningInbox();
}
