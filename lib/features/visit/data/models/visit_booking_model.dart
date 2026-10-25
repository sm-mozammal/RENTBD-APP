import '../../domain/entities/visit_booking.dart';

/// DTO mapping DRF snake_case JSON response for visit bookings.
class VisitBookingModel {
  const VisitBookingModel({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.area,
    required this.scheduledDate,
    required this.timeSlot,
    required this.visitType,
    required this.status,
    required this.landlordName,
    this.notes,
    this.createdAt,
  });

  factory VisitBookingModel.fromJson(Map<String, dynamic> json) {
    VisitType parseType(String? str) {
      if (str?.toUpperCase() == 'LIVE_VIDEO' || str?.toUpperCase() == 'VIDEO') {
        return VisitType.liveVideo;
      }
      return VisitType.inPerson;
    }

    VisitStatus parseStatus(String? str) {
      switch (str?.toUpperCase()) {
        case 'CONFIRMED':
          return VisitStatus.confirmed;
        case 'RESCHEDULED':
          return VisitStatus.rescheduled;
        case 'CANCELLED':
          return VisitStatus.cancelled;
        case 'COMPLETED':
          return VisitStatus.completed;
        default:
          return VisitStatus.pending;
      }
    }

    return VisitBookingModel(
      id: json['booking_id'] as String? ?? json['id'] as String? ?? '',
      propertyId: json['property_id'] as String? ?? json['property'] as String? ?? '',
      propertyTitle: json['property_title'] as String? ?? 'Rental Apartment',
      area: json['area'] as String? ?? json['property_area'] as String? ?? 'Dhaka',
      scheduledDate: json['scheduled_date'] as String? ?? json['visit_date'] as String? ?? '',
      timeSlot: json['time_slot'] as String? ?? '',
      visitType: parseType(json['visit_type'] as String?),
      status: parseStatus(json['status'] as String?),
      landlordName: json['landlord_name'] as String? ?? 'Property Landlord',
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  factory VisitBookingModel.fromEntity(VisitBooking entity) {
    return VisitBookingModel(
      id: entity.id,
      propertyId: entity.propertyId,
      propertyTitle: entity.propertyTitle,
      area: entity.area,
      scheduledDate: entity.scheduledDate,
      timeSlot: entity.timeSlot,
      visitType: entity.visitType,
      status: entity.status,
      landlordName: entity.landlordName,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  final String id;
  final String propertyId;
  final String propertyTitle;
  final String area;
  final String scheduledDate;
  final String timeSlot;
  final VisitType visitType;
  final VisitStatus status;
  final String landlordName;
  final String? notes;
  final DateTime? createdAt;

  Map<String, dynamic> toJson() {
    return {
      'property_id': propertyId,
      'scheduled_date': scheduledDate,
      'time_slot': timeSlot,
      'visit_type': visitType == VisitType.liveVideo ? 'LIVE_VIDEO' : 'IN_PERSON',
      'notes': notes ?? '',
    };
  }

  VisitBooking toEntity() {
    return VisitBooking(
      id: id,
      propertyId: propertyId,
      propertyTitle: propertyTitle,
      area: area,
      scheduledDate: scheduledDate,
      timeSlot: timeSlot,
      visitType: visitType,
      status: status,
      landlordName: landlordName,
      notes: notes,
      createdAt: createdAt,
    );
  }
}
