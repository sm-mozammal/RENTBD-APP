import 'package:flutter_test/flutter_test.dart';
import 'package:rentbd_app/features/visit/data/models/tenant_inquiry_model.dart';
import 'package:rentbd_app/features/visit/data/models/visit_booking_model.dart';
import 'package:rentbd_app/features/visit/domain/entities/visit_booking.dart';

void main() {
  group('Visit & Inquiry Model DRF JSON Serialization', () {
    test('should parse DRF visit booking JSON correctly', () {
      final json = {
        'id': 'v71a-uuid',
        'property': '4b7e8d02-15d9-4cf5-992a-fa13de5518b2',
        'visit_date': '2026-10-25',
        'time_slot': '4:00 PM - 5:00 PM',
        'visit_type': 'in_person',
        'status': 'confirmed',
        'notes': 'Will come with my family to view the flat.',
      };

      final model = VisitBookingModel.fromJson(json);

      expect(model.id, 'v71a-uuid');
      expect(model.scheduledDate, '2026-10-25');
      expect(model.timeSlot, '4:00 PM - 5:00 PM');
      expect(model.visitType, VisitType.inPerson);
      expect(model.status, VisitStatus.confirmed);
      expect(model.notes, 'Will come with my family to view the flat.');

      final entity = model.toEntity();
      expect(entity.id, model.id);
      expect(entity.visitType, VisitType.inPerson);
    });

    test('should parse DRF screening inbox inquiry JSON correctly', () {
      final json = {
        'id': 'e30f-uuid',
        'property': '4b7e8d02-15d9-4cf5-992a-fa13de5518b2',
        'property_title': 'Modern 3-BHK Flat in Bashundhara R/A Block D',
        'status': 'pending',
        'tenant': {
          'full_name': 'Rahim Ahmed',
          'phone_number': '+8801712345678',
          'is_nid_verified': true,
          'occupation': 'Software Engineer',
          'workplace': 'Brain Station 23',
          'family_members_count': 3,
        },
        'message': 'Assalamu Alaikum. Is this flat available?',
        'created_at': '2026-10-21T00:00:00Z',
      };

      final model = TenantInquiryModel.fromJson(json);

      expect(model.id, 'e30f-uuid');
      expect(model.propertyTitle, 'Modern 3-BHK Flat in Bashundhara R/A Block D');
      expect(model.tenant?.fullName, 'Rahim Ahmed');
      expect(model.tenant?.isNidVerified, true);
      expect(model.tenant?.familyMembersCount, 3);
      expect(model.message, 'Assalamu Alaikum. Is this flat available?');
    });
  });
}
