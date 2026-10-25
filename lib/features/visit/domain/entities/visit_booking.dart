import 'package:equatable/equatable.dart';

enum VisitType { inPerson, liveVideo }
enum VisitStatus { pending, confirmed, rescheduled, cancelled, completed }

/// Pure Dart entity representing a scheduled property visit or live video walkthrough.
class VisitBooking extends Equatable {
  const VisitBooking({
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

  @override
  List<Object?> get props => [
        id,
        propertyId,
        propertyTitle,
        area,
        scheduledDate,
        timeSlot,
        visitType,
        status,
        landlordName,
      ];
}
