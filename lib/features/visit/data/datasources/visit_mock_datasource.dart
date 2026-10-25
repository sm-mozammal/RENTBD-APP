import 'package:rentbd_app/core/config/app_environment.dart';
import '../../domain/entities/visit_booking.dart';
import '../models/tenant_inquiry_model.dart';
import '../models/visit_booking_model.dart';
import 'visit_datasource.dart';

class VisitMockDataSource implements VisitDataSource {
  final List<VisitBookingModel> _visits = [
    VisitBookingModel(
      id: 'visit-01',
      propertyId: 'prop-mirpur-01',
      propertyTitle: 'Sunlit 2-BHK Bachelor Friendly Apartment',
      area: 'Mirpur 10',
      scheduledDate: '2026-10-25',
      timeSlot: '4:00 PM - 5:00 PM',
      visitType: VisitType.inPerson,
      status: VisitStatus.pending,
      landlordName: 'Engr. Farhan Kabir',
      notes: 'Coming with roommate to inspect kitchen and balcony.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    VisitBookingModel(
      id: 'visit-02',
      propertyId: 'prop-bash-01',
      propertyTitle: 'Modern 3-BHK Flat in Bashundhara R/A Block D',
      area: 'Bashundhara R/A',
      scheduledDate: '2026-10-26',
      timeSlot: '11:00 AM - 12:00 PM',
      visitType: VisitType.liveVideo,
      status: VisitStatus.confirmed,
      landlordName: 'Kamal Hossain',
      notes: 'Live video walkthrough via WhatsApp / App.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  final List<TenantInquiryModel> _inquiries = [
    TenantInquiryModel(
      id: 'inq-01',
      propertyId: 'prop-bash-01',
      propertyTitle: 'Modern 3-BHK Flat in Bashundhara R/A Block D',
      status: 'pending',
      message: 'Assalamu Alaikum. Is this flat available for family occupancy starting November 1st?',
      tenant: const ScreeningTenantInfoModel(
        fullName: 'Rahim Ahmed',
        phoneNumber: '+8801712345678',
        isNidVerified: true,
        occupation: 'Software Engineer',
        workplace: 'Brain Station 23',
        familyMembersCount: 3,
      ),
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  @override
  Future<VisitBookingModel> bookVisit(Map<String, dynamic> data) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final newVisit = VisitBookingModel(
      id: 'visit-${DateTime.now().millisecondsSinceEpoch}',
      propertyId: data['property'] as String? ?? data['property_id'] as String? ?? 'prop-default',
      propertyTitle: data['property_title'] as String? ?? 'Rental Apartment',
      area: data['area'] as String? ?? 'Dhaka',
      scheduledDate: data['visit_date'] as String? ?? data['scheduled_date'] as String? ?? '2026-11-01',
      timeSlot: data['time_slot'] as String? ?? '4:00 PM - 5:00 PM',
      visitType: (data['visit_type']?.toString().toLowerCase().contains('video') ?? false)
          ? VisitType.liveVideo
          : VisitType.inPerson,
      status: VisitStatus.pending,
      landlordName: data['landlord_name'] as String? ?? 'Property Owner',
      notes: data['notes'] as String?,
      createdAt: DateTime.now(),
    );
    _visits.insert(0, newVisit);
    return newVisit;
  }

  @override
  Future<List<VisitBookingModel>> getMyVisits() async {
    await Future.delayed(AppEnvironment.mockDelay);
    return List.from(_visits);
  }

  @override
  Future<VisitBookingModel> updateVisitStatus(String visitId, String status) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final idx = _visits.indexWhere((v) => v.id == visitId);
    if (idx != -1) {
      final current = _visits[idx];
      VisitStatus newStatus;
      switch (status.toUpperCase()) {
        case 'CONFIRMED':
          newStatus = VisitStatus.confirmed;
          break;
        case 'CANCELLED':
          newStatus = VisitStatus.cancelled;
          break;
        case 'COMPLETED':
          newStatus = VisitStatus.completed;
          break;
        default:
          newStatus = VisitStatus.pending;
      }
      final updated = VisitBookingModel(
        id: current.id,
        propertyId: current.propertyId,
        propertyTitle: current.propertyTitle,
        area: current.area,
        scheduledDate: current.scheduledDate,
        timeSlot: current.timeSlot,
        visitType: current.visitType,
        status: newStatus,
        landlordName: current.landlordName,
        notes: current.notes,
        createdAt: current.createdAt,
      );
      _visits[idx] = updated;
      return updated;
    }
    throw Exception('Visit not found');
  }

  @override
  Future<TenantInquiryModel> submitInquiry(String propertyId, String message) async {
    await Future.delayed(AppEnvironment.mockDelay);
    final newInquiry = TenantInquiryModel(
      id: 'inq-${DateTime.now().millisecondsSinceEpoch}',
      propertyId: propertyId,
      propertyTitle: 'Rental Flat',
      status: 'pending',
      message: message,
      tenant: const ScreeningTenantInfoModel(
        fullName: 'Logged In Tenant',
        phoneNumber: '+880 17•• ••••99',
        isNidVerified: true,
        occupation: 'Professional',
        workplace: 'Dhaka',
        familyMembersCount: 2,
      ),
      createdAt: DateTime.now(),
    );
    _inquiries.insert(0, newInquiry);
    return newInquiry;
  }

  @override
  Future<List<TenantInquiryModel>> getLandlordScreeningInbox() async {
    await Future.delayed(AppEnvironment.mockDelay);
    return List.from(_inquiries);
  }
}
