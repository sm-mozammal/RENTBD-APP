import 'package:rentbd_app/core/config/app_environment.dart';
import 'package:rentbd_app/core/error/exceptions.dart';
import 'package:rentbd_app/core/error/failures.dart';
import '../../domain/entities/tenant_inquiry.dart';
import '../../domain/entities/visit_booking.dart';
import '../../domain/repositories/visit_repository.dart';
import '../datasources/visit_datasource.dart';

class VisitRepositoryImpl implements VisitRepository {
  VisitRepositoryImpl({
    required this.mockDataSource,
    required this.remoteDataSource,
  });

  final VisitDataSource mockDataSource;
  final VisitDataSource remoteDataSource;

  VisitDataSource get _activeDataSource =>
      AppEnvironment.useMockData ? mockDataSource : remoteDataSource;

  @override
  Future<VisitBooking> bookVisit({
    required String propertyId,
    required String scheduledDate,
    required String timeSlot,
    required VisitType visitType,
    String? propertyTitle,
    String? area,
    String? landlordName,
    String? notes,
  }) async {
    try {
      final model = await _activeDataSource.bookVisit({
        'property': propertyId,
        'property_id': propertyId,
        'visit_date': scheduledDate,
        'scheduled_date': scheduledDate,
        'time_slot': timeSlot,
        'visit_type': visitType == VisitType.liveVideo ? 'video' : 'in_person',
        'property_title': propertyTitle,
        'area': area,
        'landlord_name': landlordName,
        'notes': notes ?? '',
      });
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<List<VisitBooking>> getMyVisits() async {
    try {
      final models = await _activeDataSource.getMyVisits();
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<VisitBooking> updateVisitStatus(String visitId, VisitStatus status) async {
    try {
      String statusStr;
      switch (status) {
        case VisitStatus.confirmed:
          statusStr = 'confirmed';
          break;
        case VisitStatus.cancelled:
          statusStr = 'cancelled';
          break;
        case VisitStatus.completed:
          statusStr = 'completed';
          break;
        case VisitStatus.rescheduled:
          statusStr = 'rescheduled';
          break;
        case VisitStatus.pending:
          statusStr = 'pending';
          break;
      }
      final model = await _activeDataSource.updateVisitStatus(visitId, statusStr);
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<TenantInquiry> submitInquiry(String propertyId, String message) async {
    try {
      final model = await _activeDataSource.submitInquiry(propertyId, message);
      return model.toEntity();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }

  @override
  Future<List<TenantInquiry>> getLandlordScreeningInbox() async {
    try {
      final models = await _activeDataSource.getLandlordScreeningInbox();
      return models.map((m) => m.toEntity()).toList();
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw NetworkFailure(e.toString());
    }
  }
}
